import 'dart:async';
import 'dart:typed_data';

import 'package:budgetbook_2026/app/core/auth/firebase_token_service.dart';
import 'package:budgetbook_2026/app/core/network/api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FirebaseTokenService', () {
    late _FakeTokenSource source;
    late FirebaseTokenService service;

    setUp(() {
      source = _FakeTokenSource();
      service = FirebaseTokenService(source: source);
    });

    tearDown(() async {
      await service.dispose();
      await source.close();
    });

    test('gets a fresh SDK token value on each normal request', () async {
      expect(await service.getIdToken(), 'token-1');
      source.token = 'token-2';
      expect(await service.getIdToken(), 'token-2');
      expect(source.normalReadCount, 2);
      expect(source.refreshCount, 0);
    });

    test('coalesces concurrent forced refreshes for the same user', () async {
      source.refreshCompleter = Completer<String?>();

      final first = service.getIdToken(forceRefresh: true);
      final second = service.getIdToken(forceRefresh: true);
      expect(source.refreshCount, 1);

      source.refreshCompleter!.complete('refreshed-token');
      expect(await first, 'refreshed-token');
      expect(await second, 'refreshed-token');
    });

    test('rejects token requests when signed out', () async {
      source.userId = null;

      await expectLater(
        service.getIdToken(),
        throwsA(
          isA<FirebaseTokenException>().having(
            (error) => error.failure,
            'failure',
            FirebaseTokenFailure.signedOut,
          ),
        ),
      );
    });

    test(
      'uses the newly signed-in account and rejects a stale account',
      () async {
        source.userId = 'user-b';
        source.userChanges.add('user-b');

        expect(await service.getIdToken(), 'token-1');
        await expectLater(
          service.getIdToken(expectedUserId: 'user-a'),
          throwsA(
            isA<FirebaseTokenException>().having(
              (error) => error.failure,
              'failure',
              FirebaseTokenFailure.userChanged,
            ),
          ),
        );
      },
    );
  });

  group('ApiClient Firebase authentication', () {
    late _FakeTokenSource source;
    late FirebaseTokenService tokenService;
    late _QueueAdapter adapter;
    late Dio dio;
    var authenticationRequiredCount = 0;
    var invalidationCount = 0;

    setUp(() {
      source = _FakeTokenSource();
      tokenService = FirebaseTokenService(source: source);
      adapter = _QueueAdapter();
      dio = Dio(BaseOptions(baseUrl: 'https://api.example.test'));
      dio.httpClientAdapter = adapter;
      authenticationRequiredCount = 0;
      invalidationCount = 0;
      ApiClient.withDependencies(
        tokenService: tokenService,
        onAuthenticationRequired: () async {
          authenticationRequiredCount++;
        },
        onAuthenticationInvalidated: () async {
          invalidationCount++;
        },
        dio: dio,
      );
    });

    tearDown(() async {
      dio.close(force: true);
      await tokenService.dispose();
      await source.close();
    });

    test('attaches the current Firebase token on every request', () async {
      adapter.statuses.addAll([200, 200]);

      await dio.get<dynamic>('/private');
      source.token = 'new-sdk-token';
      await dio.get<dynamic>('/private');

      expect(
        adapter.requests.map((request) => request.headers['Authorization']),
        ['Bearer token-1', 'Bearer new-sdk-token'],
      );
    });

    test(
      'retries an explicitly invalid-token response once with refreshed token',
      () async {
        adapter.statuses.addAll([401, 200]);

        final response = await dio.post<dynamic>(
          '/private',
          data: <String, Object?>{'amount': 12},
          queryParameters: <String, Object?>{'page': 3},
          options: Options(
            headers: const {'X-Request-ID': 'request-123'},
            extra: const {'traceTag': 'test'},
          ),
          cancelToken: CancelToken(),
        );

        expect(response.statusCode, 200);
        expect(adapter.requests, hasLength(2));
        expect(adapter.requests[0].method, 'POST');
        expect(adapter.requests[1].method, 'POST');
        expect(adapter.requests[1].data, <String, Object?>{'amount': 12});
        expect(adapter.requests[1].queryParameters, {'page': 3});
        expect(adapter.requests[1].headers['X-Request-ID'], 'request-123');
        expect(adapter.requests[1].extra['traceTag'], 'test');
        expect(
          adapter.requests[1].cancelToken,
          same(adapter.requests[0].cancelToken),
        );
        expect(
          adapter.requests.map((request) => request.headers['Authorization']),
          ['Bearer token-1', 'Bearer refreshed-token'],
        );
        expect(source.refreshCount, 1);
        expect(invalidationCount, 0);
      },
    );

    test(
      'does not refresh or log out for unrelated authorization failures',
      () async {
        adapter.statuses.add(401);
        adapter.errorBodies.add('Insufficient permissions for this resource.');

        await expectLater(
          dio.get<dynamic>('/private'),
          throwsA(isA<DioException>()),
        );

        expect(adapter.requests, hasLength(1));
        expect(source.refreshCount, 0);
        expect(invalidationCount, 0);
      },
    );

    test(
      'does not attach Firebase auth to explicitly public requests',
      () async {
        source.userId = null;
        adapter.statuses.add(200);

        await dio.get<dynamic>(
          '/public',
          options: Options(
            extra: const {ApiClient.requiresAuthExtraKey: false},
          ),
        );

        expect(adapter.requests.single.headers['Authorization'], isNull);
        expect(authenticationRequiredCount, 0);
      },
    );

    test(
      'invalidates authentication if the one retry still has an invalid token',
      () async {
        adapter.statuses.addAll([401, 401]);

        await expectLater(
          dio.get<dynamic>('/private'),
          throwsA(isA<DioException>()),
        );

        expect(adapter.requests, hasLength(2));
        expect(source.refreshCount, 1);
        expect(invalidationCount, 1);
      },
    );

    test('invalidates authentication when forced refresh fails', () async {
      adapter.statuses.add(401);
      source.failRefresh = true;

      await expectLater(
        dio.get<dynamic>('/private'),
        throwsA(isA<DioException>()),
      );

      expect(adapter.requests, hasLength(1));
      expect(invalidationCount, 1);
    });

    test(
      'coalesces refreshes from concurrent invalid-token responses',
      () async {
        adapter.statuses.addAll([401, 401, 200, 200]);
        source.refreshCompleter = Completer<String?>();

        final first = dio.get<dynamic>('/private/first');
        final second = dio.get<dynamic>('/private/second');
        await source.refreshStarted.future.timeout(const Duration(seconds: 2));
        expect(source.refreshCount, 1);

        source.refreshCompleter!.complete('shared-refreshed-token');
        await Future.wait([first, second]);

        expect(adapter.requests, hasLength(4));
        expect(invalidationCount, 0);
        expect(
          adapter.requests
              .skip(2)
              .map((request) => request.headers['Authorization']),
          everyElement('Bearer shared-refreshed-token'),
        );
      },
    );

    test(
      'invalidates a concurrent failed retry only once per authenticated user',
      () async {
        adapter.statuses.addAll([401, 401, 401, 401]);
        source.refreshCompleter = Completer<String?>();

        final first = dio.get<dynamic>('/private/first');
        final second = dio.get<dynamic>('/private/second');
        await source.refreshStarted.future.timeout(const Duration(seconds: 2));
        source.refreshCompleter!.complete('refreshed-token');
        await Future.wait([
          expectLater(first, throwsA(isA<DioException>())),
          expectLater(second, throwsA(isA<DioException>())),
        ]);

        expect(adapter.requests, hasLength(4));
        expect(source.refreshCount, 1);
        expect(invalidationCount, 1);
      },
    );

    test(
      'redirects and fails before sending when there is no Firebase user',
      () async {
        source.userId = null;

        await expectLater(
          dio.get<dynamic>('/private'),
          throwsA(isA<DioException>()),
        );

        expect(authenticationRequiredCount, 1);
        expect(adapter.requests, isEmpty);
      },
    );
  });
}

class _FakeTokenSource implements FirebaseIdTokenSource {
  String? userId = 'user-a';
  String token = 'token-1';
  int normalReadCount = 0;
  int refreshCount = 0;
  bool failRefresh = false;
  Completer<String?>? refreshCompleter;
  final Completer<void> refreshStarted = Completer<void>();
  final StreamController<String?> userChanges =
      StreamController<String?>.broadcast();

  @override
  String? get currentUserId => userId;

  @override
  Stream<String?> get userIdChanges => userChanges.stream;

  @override
  Future<String?> getIdToken(
    String expectedUserId, {
    required bool forceRefresh,
  }) async {
    if (expectedUserId != userId) {
      throw const FirebaseTokenException(FirebaseTokenFailure.userChanged);
    }
    if (!forceRefresh) {
      normalReadCount++;
      return token;
    }

    refreshCount++;
    if (!refreshStarted.isCompleted) refreshStarted.complete();
    if (failRefresh) throw StateError('refresh failed');
    if (refreshCompleter != null) {
      final refreshedToken = await refreshCompleter!.future;
      token = refreshedToken ?? '';
      return refreshedToken;
    }
    token = 'refreshed-token';
    return token;
  }

  @override
  Future<void> signOut() async {
    userId = null;
  }

  Future<void> close() => userChanges.close();
}

class _QueueAdapter implements HttpClientAdapter {
  final List<int> statuses = [];
  final List<String> errorBodies = [];
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final status = statuses.removeAt(0);
    final body = status == 401
        ? (errorBodies.isEmpty
              ? '{"message":"Invalid or expired Firebase ID token"}'
              : errorBodies.removeAt(0))
        : '{"ok":true}';
    return ResponseBody.fromString(
      body,
      status,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
