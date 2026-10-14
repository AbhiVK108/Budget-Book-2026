import 'package:budgetbook_2026/app/core/auth/firebase_token_service.dart';
import 'package:budgetbook_2026/app/core/constant/app_url.dart';
import 'package:budgetbook_2026/app/core/network/api_exception.dart';
import 'package:budgetbook_2026/app/routes/app_pages.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide FormData, Response;

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  static const requiresAuthExtraKey = 'requiresAuth';
  static const _requestUserIdKey = '_firebaseRequestUserId';
  static const _requestTokenKey = '_firebaseRequestToken';
  static const _retriedKey = '_firebaseTokenRetryAttempted';

  late final Dio dio;
  final FirebaseTokenService _tokenService;
  final Future<void> Function() _onAuthenticationRequired;
  final Future<void> Function() _onAuthenticationInvalidated;
  Future<void>? _invalidationInFlight;
  String? _invalidatedUserId;

  ApiClient._internal()
    : dio = Dio(_baseOptions()),
      _tokenService = FirebaseTokenService(),
      _onAuthenticationRequired = _redirectToLogin,
      _onAuthenticationInvalidated = _invalidateAuthentication {
    _installInterceptors();
  }

  @visibleForTesting
  ApiClient.withDependencies({
    required FirebaseTokenService tokenService,
    required Future<void> Function() onAuthenticationRequired,
    required Future<void> Function() onAuthenticationInvalidated,
    Dio? dio,
  }) : dio = dio ?? Dio(_baseOptions()),
       _tokenService = tokenService,
       _onAuthenticationRequired = onAuthenticationRequired,
       _onAuthenticationInvalidated = onAuthenticationInvalidated {
    _installInterceptors();
  }

  static BaseOptions _baseOptions() => BaseOptions(
    baseUrl: AppUrl.baseUrl,
    connectTimeout: Duration(seconds: AppUrl.timeout),
    receiveTimeout: Duration(seconds: AppUrl.timeout),
    headers: const {'Accept': 'application/json'},
  );

  void _installInterceptors() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (options.extra[requiresAuthExtraKey] == false) {
            handler.next(options);
            return;
          }

          if (options.extra[_retriedKey] == true) {
            final expectedUserId = options.extra[_requestUserIdKey] as String?;
            if (expectedUserId == null ||
                _tokenService.currentUserId != expectedUserId) {
              handler.reject(
                DioException(
                  requestOptions: options,
                  error: const FirebaseTokenException(
                    FirebaseTokenFailure.userChanged,
                  ),
                ),
              );
              return;
            }
            handler.next(options);
            return;
          }

          final userId = _tokenService.currentUserId;
          if (userId == null) {
            await _onAuthenticationRequired();
            handler.reject(
              DioException(
                requestOptions: options,
                error: const FirebaseTokenException(
                  FirebaseTokenFailure.signedOut,
                ),
              ),
            );
            return;
          }

          try {
            final token = await _tokenService.getIdToken(
              expectedUserId: userId,
            );
            if (_invalidationInFlight == null) _invalidatedUserId = null;
            options.headers['Authorization'] = 'Bearer $token';
            options.extra[_requestUserIdKey] = userId;
            options.extra[_requestTokenKey] = token;
          } on FirebaseTokenException catch (error) {
            if (error.failure == FirebaseTokenFailure.signedOut) {
              await _onAuthenticationRequired();
            }
            handler.reject(DioException(requestOptions: options, error: error));
            return;
          } on FirebaseAuthException catch (error) {
            if (kDebugMode) {
              debugPrint('Firebase ID token retrieval failed (${error.code}).');
            }
            handler.reject(DioException(requestOptions: options, error: error));
            return;
          } catch (error) {
            if (kDebugMode) {
              debugPrint(
                'Firebase ID token retrieval failed '
                '(${error.runtimeType}).',
              );
            }
            handler.reject(DioException(requestOptions: options, error: error));
            return;
          }

          if (kDebugMode) {
            debugPrint(
              'API request: ${options.method} '
              '${options.baseUrl}${options.path}',
            );
            final safeHeaders = Map<String, dynamic>.from(options.headers);
            if (safeHeaders.containsKey('Authorization')) {
              safeHeaders['Authorization'] = '<redacted>';
            }
            debugPrint('API request headers: $safeHeaders');
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            debugPrint('API response: HTTP ${response.statusCode}');
          }
          handler.next(response);
        },
        onError: (error, handler) async {
          final requestOptions = error.requestOptions;
          final isAuthenticated =
              requestOptions.extra[requiresAuthExtraKey] != false;
          final invalidTokenResponse =
              isAuthenticated &&
              error.response?.statusCode == 401 &&
              _identifiesInvalidFirebaseToken(error.response?.data);

          if (invalidTokenResponse) {
            if (requestOptions.extra[_retriedKey] == true) {
              await _invalidateAuthenticationOnce(
                requestOptions.extra[_requestUserIdKey] as String?,
              );
            } else {
              final requestUserId =
                  requestOptions.extra[_requestUserIdKey] as String?;
              try {
                final originalToken =
                    requestOptions.extra[_requestTokenKey] as String?;
                final latestToken = await _tokenService.getIdToken(
                  expectedUserId: requestUserId,
                );
                final refreshedToken =
                    originalToken != null && latestToken != originalToken
                    ? latestToken
                    : await _tokenService.getIdToken(
                        forceRefresh: true,
                        expectedUserId: requestUserId,
                      );
                final retryOptions = requestOptions.copyWith(
                  data: _copyRequestData(requestOptions.data),
                  headers: <String, dynamic>{
                    ...requestOptions.headers,
                    'Authorization': 'Bearer $refreshedToken',
                  },
                  extra: <String, dynamic>{
                    ...requestOptions.extra,
                    _requestTokenKey: refreshedToken,
                    _retriedKey: true,
                  },
                );
                try {
                  final response = await dio.fetch<dynamic>(retryOptions);
                  handler.resolve(response);
                  return;
                } on DioException catch (retryError) {
                  handler.reject(_toApiException(retryError));
                  return;
                }
              } on FirebaseTokenException catch (refreshError) {
                if (refreshError.failure != FirebaseTokenFailure.userChanged) {
                  await _invalidateAuthenticationOnce(requestUserId);
                }
              } on FirebaseAuthException catch (refreshError) {
                if (kDebugMode) {
                  debugPrint(
                    'Firebase ID token refresh failed '
                    '(${refreshError.code}).',
                  );
                }
                await _invalidateAuthenticationOnce(requestUserId);
              } catch (refreshError) {
                if (kDebugMode) {
                  debugPrint(
                    'Firebase ID token refresh failed '
                    '(${refreshError.runtimeType}).',
                  );
                }
                await _invalidateAuthenticationOnce(requestUserId);
              }
            }
          }

          if (kDebugMode && error.response != null) {
            debugPrint(
              'API error response: HTTP ${error.response?.statusCode}',
            );
          }
          handler.reject(_toApiException(error));
        },
      ),
    );
  }

  static dynamic _copyRequestData(dynamic data) {
    if (data is FormData) return data.clone();
    return data;
  }

  Future<void> _invalidateAuthenticationOnce(String? userId) async {
    if (userId != null && _invalidatedUserId == userId) return;
    final activeInvalidation = _invalidationInFlight;
    if (activeInvalidation != null) {
      await activeInvalidation;
      return;
    }

    if (userId != null) _invalidatedUserId = userId;
    final invalidation = _onAuthenticationInvalidated();
    _invalidationInFlight = invalidation;
    try {
      await invalidation;
    } finally {
      if (identical(_invalidationInFlight, invalidation)) {
        _invalidationInFlight = null;
      }
    }
  }

  static bool _identifiesInvalidFirebaseToken(dynamic data) {
    final text = data is String ? data : data.toString();
    return RegExp(
      r'(?:(?:firebase.{0,40}id.?token|id.?token.{0,40}firebase).{0,100}(?:invalid|expired)|(?:invalid|expired).{0,100}(?:firebase.{0,40}id.?token|id.?token.{0,40}firebase))',
      caseSensitive: false,
      dotAll: true,
    ).hasMatch(text);
  }

  static DioException _toApiException(DioException error) {
    var message = 'Something went wrong';
    final data = error.response?.data;
    if (data is Map) {
      message = data['message']?.toString() ?? message;
    } else if (data is String && data.isNotEmpty) {
      message = data;
    } else if (error.type == DioExceptionType.connectionTimeout) {
      message = 'Connection timeout';
    } else if (error.type == DioExceptionType.connectionError) {
      message = 'No internet connection';
    } else if (error.error is FirebaseTokenException) {
      final tokenError = error.error as FirebaseTokenException;
      message = tokenError.failure == FirebaseTokenFailure.signedOut
          ? 'Authentication required. Please sign in.'
          : 'Unable to obtain a Firebase ID token.';
    }

    return DioException(
      requestOptions: error.requestOptions,
      response: error.response,
      type: error.type,
      error: ApiException(message),
      stackTrace: error.stackTrace,
    );
  }

  static Future<void> _redirectToLogin() async {
    if (Get.currentRoute != Routes.Login) {
      Get.offAllNamed(Routes.Login);
    }
  }

  static Future<void> _invalidateAuthentication() async {
    try {
      await FirebaseAuth.instance.signOut();
    } on FirebaseAuthException catch (error) {
      if (kDebugMode) {
        debugPrint('Firebase sign-out failed (${error.code}).');
      }
    } finally {
      await _redirectToLogin();
    }
  }

  Future<Response> post(String endpoint, {dynamic data}) async {
    try {
      return await dio.post(endpoint, data: data);
    } on DioException catch (error) {
      throw ApiException(error.error.toString());
    }
  }

  Future<Response> get(String endpoint) async {
    try {
      return await dio.get(endpoint);
    } on DioException catch (error) {
      throw ApiException(error.error.toString());
    }
  }

  Future<Response> delete(String endpoint, {dynamic data}) async {
    try {
      return await dio.delete(endpoint, data: data);
    } on DioException catch (error) {
      throw ApiException(error.error.toString());
    }
  }
}
