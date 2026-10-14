import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

abstract interface class FirebaseIdTokenSource {
  String? get currentUserId;

  Stream<String?> get userIdChanges;

  Future<String?> getIdToken(
    String expectedUserId, {
    required bool forceRefresh,
  });

  Future<void> signOut();
}

class FirebaseAuthIdTokenSource implements FirebaseIdTokenSource {
  FirebaseAuthIdTokenSource([FirebaseAuth? auth])
    : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  @override
  String? get currentUserId => _auth.currentUser?.uid;

  @override
  Stream<String?> get userIdChanges =>
      _auth.idTokenChanges().map((user) => user?.uid);

  @override
  Future<String?> getIdToken(
    String expectedUserId, {
    required bool forceRefresh,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw const FirebaseTokenException(FirebaseTokenFailure.signedOut);
    }
    if (user.uid != expectedUserId) {
      throw const FirebaseTokenException(FirebaseTokenFailure.userChanged);
    }

    final token = await user.getIdToken(forceRefresh);
    if (_auth.currentUser?.uid != expectedUserId) {
      throw const FirebaseTokenException(FirebaseTokenFailure.userChanged);
    }
    return token;
  }

  @override
  Future<void> signOut() => _auth.signOut();
}

enum FirebaseTokenFailure { signedOut, userChanged, unavailable }

class FirebaseTokenException implements Exception {
  const FirebaseTokenException(this.failure);

  final FirebaseTokenFailure failure;

  @override
  String toString() => 'Firebase token unavailable (${failure.name}).';
}

class FirebaseTokenService {
  FirebaseTokenService({FirebaseIdTokenSource? source})
    : _source = source ?? FirebaseAuthIdTokenSource() {
    _authSubscription = _source.userIdChanges.listen(
      _handleUserChanged,
      onError: (Object error, StackTrace stackTrace) {
        if (kDebugMode) {
          debugPrint(
            'Firebase auth state stream failed (${error.runtimeType}).',
          );
        }
      },
    );
  }

  final FirebaseIdTokenSource _source;
  late final StreamSubscription<String?> _authSubscription;
  String? _refreshUserId;
  Future<String>? _forcedRefresh;

  String? get currentUserId => _source.currentUserId;

  Future<String> getIdToken({
    bool forceRefresh = false,
    String? expectedUserId,
  }) async {
    final userId = _source.currentUserId;
    if (userId == null) {
      throw const FirebaseTokenException(FirebaseTokenFailure.signedOut);
    }
    if (expectedUserId != null && expectedUserId != userId) {
      throw const FirebaseTokenException(FirebaseTokenFailure.userChanged);
    }

    if (!forceRefresh) {
      return _retrieveToken(userId, forceRefresh: false);
    }

    final activeRefresh = _forcedRefresh;
    if (_refreshUserId == userId && activeRefresh != null) {
      return activeRefresh;
    }

    final refresh = _retrieveToken(userId, forceRefresh: true);
    _refreshUserId = userId;
    _forcedRefresh = refresh;
    try {
      return await refresh;
    } finally {
      if (identical(_forcedRefresh, refresh)) {
        _refreshUserId = null;
        _forcedRefresh = null;
      }
    }
  }

  Future<String> _retrieveToken(
    String userId, {
    required bool forceRefresh,
  }) async {
    final token = await _source.getIdToken(
      userId,
      forceRefresh: forceRefresh,
    );
    if (_source.currentUserId != userId) {
      throw const FirebaseTokenException(FirebaseTokenFailure.userChanged);
    }
    if (token == null || token.isEmpty) {
      throw const FirebaseTokenException(FirebaseTokenFailure.unavailable);
    }
    return token;
  }

  Future<void> signOut() => _source.signOut();

  Future<void> dispose() => _authSubscription.cancel();

  void _handleUserChanged(String? userId) {
    if (_refreshUserId != userId) {
      _refreshUserId = null;
      _forcedRefresh = null;
    }
  }
}
