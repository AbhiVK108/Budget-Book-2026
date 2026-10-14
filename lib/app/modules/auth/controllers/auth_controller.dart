import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:budgetbook_2026/app/routes/app_pages.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  static const _firebaseAuthEndpoint =
      'https://api.budgetbook.in/api/v1/auth/firebase';

  final Dio _authApi = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      responseType: ResponseType.plain,
      validateStatus: (_) => true,
      followRedirects: false,
    ),
  );

  //////////////////////////////////////////////////////////////
  /// FIREBASE INSTANCE
  //////////////////////////////////////////////////////////////

  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _verificationId;
  Timer? _resendTimer;
  bool _isCompletingPhoneSignIn = false;
  bool _hasCompletedPhoneSignIn = false;
  StreamSubscription<User?>? _authStateSubscription;
  SnackbarController? _firebaseTokenDebugSnackbar;
  String? _firebaseTokenDebugSnackbarToken;
  String? _firebaseTokenDebugSnackbarUserId;
  var _firebaseTokenDebugSnackbarSequence = 0;
  final isPhoneValid = false.obs;

  //////////////////////////////////////////////////////////////
  /// OTP CONTROLLERS
  //////////////////////////////////////////////////////////////

  final phoneController = TextEditingController();
  final otpController = TextEditingController();

  final isOtpSent = false.obs;
  final isSendingOtp = false.obs;
  final isVerifyingOtp = false.obs;

  //////////////////////////////////////////////////////////////
  /// SEND OTP
  //////////////////////////////////////////////////////////////

  final otpFocusNode = FocusNode(); // 🔥 ADD THIS

  ////////////////////////////////////////////////////////////
  /// RESEND TIMER
  ////////////////////////////////////////////////////////////

  final resendSeconds = 30.obs;
  final canResend = false.obs;

  void startResendTimer() {
    _resendTimer?.cancel();
    resendSeconds.value = 30;
    canResend.value = false;

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      resendSeconds.value--;

      if (resendSeconds.value <= 0) {
        canResend.value = true;
        timer.cancel();
      }
    });
  }

  ////////////////////////////////////////////////////////////
  /// SEND OTP (PRO VERSION)
  ////////////////////////////////////////////////////////////

  Future<void> sendOtp() async {
    if (isSendingOtp.value || isVerifyingOtp.value) return;

    final phone = phoneController.text.trim();

    isPhoneValid.value = RegExp(r'^[0-9]{10}$').hasMatch(phone);

    if (!isPhoneValid.value) {
      Get.snackbar("Invalid", "Enter valid 10-digit phone number");
      return;
    }

    _hasCompletedPhoneSignIn = false;

    try {
      isSendingOtp.value = true;

      await _auth.verifyPhoneNumber(
        phoneNumber: "+91$phone",
        timeout: const Duration(seconds: 60),

        ////////////////////////////////////////////////////////
        /// AUTO VERIFICATION
        ////////////////////////////////////////////////////////
        verificationCompleted: (PhoneAuthCredential credential) async {
          isSendingOtp.value = false;
          isVerifyingOtp.value = true;
          try {
            await _completePhoneSignIn(credential);
          } on FirebaseAuthException catch (e) {
            Get.snackbar("Error", e.message ?? "Phone verification failed");
          } catch (e) {
            Get.snackbar("Error", "Phone verification failed: $e");
          } finally {
            isVerifyingOtp.value = false;
          }
        },

        ////////////////////////////////////////////////////////
        /// FAILURE
        ////////////////////////////////////////////////////////
        verificationFailed: (FirebaseAuthException e) {
          isSendingOtp.value = false;
          Get.snackbar("Error", e.message ?? "Verification Failed");
        },

        ////////////////////////////////////////////////////////
        /// OTP SENT SUCCESS
        ////////////////////////////////////////////////////////
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;

          isSendingOtp.value = false;
          isOtpSent.value = true;

          startResendTimer();

          Get.snackbar(
            "OTP Sent",
            "Code sent to +91 $phone",
            snackPosition: SnackPosition.BOTTOM,
          );

          Future.delayed(const Duration(milliseconds: 300), () {
            if (isOtpSent.value) otpFocusNode.requestFocus();
          });
        },

        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } on FirebaseAuthException catch (e) {
      isSendingOtp.value = false;
      Get.snackbar("Error", e.message ?? "Unable to send verification code");
    } catch (e) {
      isSendingOtp.value = false;
      Get.snackbar("Error", "Unable to send verification code: $e");
    }
  }

  //////////////////////////////////////////////////////////////
  /// VERIFY OTP
  //////////////////////////////////////////////////////////////

  Future<void> verifyOtp() async {
    final otp = otpController.text.trim();

    if (!RegExp(r'^[0-9]{6}$').hasMatch(otp)) {
      Get.snackbar("Invalid", "Enter valid 6-digit OTP");
      return;
    }

    if (_verificationId == null) {
      Get.snackbar("Error", "Please request OTP first");
      return;
    }

    try {
      isVerifyingOtp.value = true;

      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );

      await _completePhoneSignIn(credential);
    } on FirebaseAuthException catch (e) {
      isVerifyingOtp.value = false;
      Get.snackbar(
        "Error",
        e.message ?? "Invalid or expired verification code",
      );
    } catch (e) {
      isVerifyingOtp.value = false;
      Get.snackbar("Error", "Unable to verify code: $e");
    }
  }

  Future<void> _completePhoneSignIn(PhoneAuthCredential credential) async {
    if (_isCompletingPhoneSignIn || _hasCompletedPhoneSignIn) return;

    _isCompletingPhoneSignIn = true;
    final correlationId = _newCorrelationId();
    _logFirebaseBackendAuth(
      'firebase_backend_auth_started',
      correlationId,
      <String, Object?>{'endpoint': _firebaseAuthEndpoint},
    );

    try {
      await _auth.signInWithCredential(credential);
      final user = _auth.currentUser;
      _logFirebaseBackendAuth(
        'firebase_current_user_checked',
        correlationId,
        <String, Object?>{
          'firebase_app_name': _auth.app.name,
          'firebase_project_id': _auth.app.options.projectId,
          'user_exists': user != null,
          'uid_available': user?.uid.isNotEmpty ?? false,
        },
      );
      if (user == null) {
        throw const _FirebaseBackendAuthException(
          'Firebase authentication completed without a current user.',
        );
      }

      final idToken = await user.getIdToken(true);
      _logFirebaseBackendAuth(
        'firebase_id_token_obtained',
        correlationId,
        <String, Object?>{
          'token_non_empty': idToken?.isNotEmpty ?? false,
          'token_length': idToken?.length ?? 0,
        },
      );
      if (idToken == null || idToken.isEmpty) {
        if (kDebugMode) {
          debugPrint('[FIREBASE_JWS] Token is empty.');
        }
        throw const _FirebaseBackendAuthException(
          'Firebase did not provide an ID token.',
        );
      }

      _showFirebaseTokenDebugSnackbar(idToken, user.uid);

      if (kDebugMode) {
        debugPrint('[FIREBASE_JWS] Token length: ${idToken.length}');
        debugPrint('[FIREBASE_JWS] JWS segments: ${idToken.split('.').length}');
      }

      final backendAuthenticated = await _verifyFirebaseTokenWithBackend(
        correlationId,
        idToken,
      );
      if (!backendAuthenticated) {
        throw const _FirebaseBackendAuthException(
          'The backend response schema is unconfirmed; authentication was not completed.',
        );
      }

      _hasCompletedPhoneSignIn = true;
      isSendingOtp.value = false;
      isVerifyingOtp.value = false;
      _resendTimer?.cancel();
      Get.offAllNamed(Routes.FillProfileOnentry);
    } catch (error) {
      _logFirebaseBackendAuth(
        'firebase_backend_auth_failed',
        correlationId,
        <String, Object?>{'error': _safeErrorMessage(error)},
      );
      rethrow;
    } finally {
      _isCompletingPhoneSignIn = false;
    }
  }

  Future<bool> _verifyFirebaseTokenWithBackend(
    String correlationId,
    String idToken,
  ) async {
    final requestBody = <String, String>{
      'id_token': idToken,
      'ledger_currency': 'INR',
    };
    final requestOptions = Options(
      contentType: Headers.jsonContentType,
      responseType: ResponseType.plain,
      headers: const {'Accept': 'application/json'},
    );
    final serializedRequestBody = jsonEncode(requestBody);
    final startedAt = DateTime.now();
    _logFirebaseBackendAuth(
      'firebase_backend_request_constructed',
      correlationId,
      <String, Object?>{
        'method': 'POST',
        'url': _firebaseAuthEndpoint,
        'body_keys': requestBody.keys.toList(),
        'id_token_non_empty': requestBody['id_token']!.isNotEmpty,
        'id_token_length': requestBody['id_token']!.length,
        'request_body_json_encoded': true,
        'content_type': 'application/json',
        'authorization_header_present':
            requestOptions.headers?.keys.any(
              (key) => key.toLowerCase() == 'authorization',
            ) ??
            false,
      },
    );

    try {
      _logFirebaseBackendAuth(
        'firebase_backend_request_sent',
        correlationId,
        <String, Object?>{'method': 'POST', 'url': _firebaseAuthEndpoint},
      );
      final response = await _authApi.post(
        _firebaseAuthEndpoint,
        data: serializedRequestBody,
        options: requestOptions,
      );

      final elapsedMs = DateTime.now().difference(startedAt).inMilliseconds;
      final contentType =
          response.headers.value(Headers.contentTypeHeader) ?? '';
      final responseBodySummary = _safeResponseBody(response.data);
      _logFirebaseBackendAuth(
        'firebase_backend_response_received',
        correlationId,
        <String, Object?>{
          'url': _firebaseAuthEndpoint,
          'status': response.statusCode,
          'elapsed_ms': elapsedMs,
          'content_type': contentType,
          'response_data_type': response.data.runtimeType.toString(),
          'response_body': responseBodySummary,
          'backend_error_message': _safeBackendMessage(response.data),
        },
      );

      final decodedBody = _parseFirebaseBackendAuthResponse(
        statusCode: response.statusCode,
        contentType: contentType,
        body: response.data,
        safeBodySummary: responseBodySummary,
      );
      _logFirebaseBackendAuth(
        'firebase_backend_response_schema_unconfirmed',
        correlationId,
        <String, Object?>{'response_keys': decodedBody.keys.toList()},
      );
      return false;
    } on DioException catch (error) {
      final response = error.response;
      final statusCode = response?.statusCode;
      final contentType =
          response?.headers.value(Headers.contentTypeHeader) ?? '';
      final safeBody = _safeResponseBody(response?.data);
      _logFirebaseBackendAuth(
        'firebase_backend_auth_failed',
        correlationId,
        <String, Object?>{
          'url': _firebaseAuthEndpoint,
          'status': statusCode,
          'elapsed_ms': DateTime.now().difference(startedAt).inMilliseconds,
          'dio_error_type': error.type.name,
          'content_type': contentType,
          'response_body': safeBody,
          'backend_error_message': _safeBackendMessage(response?.data),
        },
      );
      if (statusCode == 404) {
        throw _FirebaseBackendAuthException(
          'Firebase auth endpoint returned 404 at $_firebaseAuthEndpoint. Confirm that this route is registered and deployed. Response: $safeBody',
        );
      }
      throw _FirebaseBackendAuthException(_dioErrorMessage(error, statusCode));
    } on FormatException catch (error) {
      _logFirebaseBackendAuth(
        'firebase_backend_auth_failed',
        correlationId,
        <String, Object?>{
          'error_type': 'format',
          'error': _safeLogText(error.message),
        },
      );
      rethrow;
    }
  }

  String _newCorrelationId() {
    final randomPart = Random.secure().nextInt(1 << 32).toRadixString(16);
    return '${DateTime.now().microsecondsSinceEpoch}-$randomPart';
  }

  void _logFirebaseBackendAuth(
    String event,
    String correlationId,
    Map<String, Object?> fields,
  ) {
    if (!kDebugMode) return;
    debugPrint(
      jsonEncode(<String, Object?>{
        'event': event,
        'correlation_id': correlationId,
        ...fields,
      }),
    );
  }

  bool _isJsonContentType(String contentType) {
    final mediaType = contentType.split(';').first.trim().toLowerCase();
    return mediaType == 'application/json' || mediaType.endsWith('+json');
  }

  /// Validates only HTTP/JSON transport shape. Backend documentation must
  /// define the success indicator and any session credential fields before
  /// this parser can treat a response as authenticated.
  Map<String, dynamic> _parseFirebaseBackendAuthResponse({
    required int? statusCode,
    required String contentType,
    required dynamic body,
    required String safeBodySummary,
  }) {
    if (statusCode == 404) {
      throw _FirebaseBackendAuthException(
        'Firebase auth endpoint returned 404 at $_firebaseAuthEndpoint. Confirm that this route is registered and deployed. Response: $safeBodySummary',
      );
    }
    if (statusCode == 401) {
      throw const _FirebaseBackendAuthException(
        'The backend rejected Firebase authentication (HTTP 401).',
      );
    }
    if (statusCode == null || statusCode < 200 || statusCode >= 300) {
      throw _FirebaseBackendAuthException(
        'Firebase backend authentication failed (HTTP ${statusCode ?? 'unknown'}).',
      );
    }
    if (statusCode != 200) {
      throw _FirebaseBackendAuthException(
        'Unexpected Firebase backend status: HTTP $statusCode.',
      );
    }
    if (!_isJsonContentType(contentType)) {
      throw const _FirebaseBackendAuthException(
        'Firebase backend returned HTTP 200 with a non-JSON content type.',
      );
    }
    if (body is! String || body.trim().isEmpty) {
      throw const _FirebaseBackendAuthException(
        'Firebase backend returned an empty JSON response.',
      );
    }

    final decoded = jsonDecode(body);
    if (decoded is! Map) {
      throw const _FirebaseBackendAuthException(
        'Firebase backend returned JSON that is not an object.',
      );
    }
    return Map<String, dynamic>.from(decoded);
  }

  String _safeResponseBody(dynamic body) {
    String text;
    if (body is String) {
      text = body;
    } else {
      try {
        text = jsonEncode(body);
      } catch (_) {
        text = '<unserializable response>';
      }
    }

    try {
      final decoded = jsonDecode(text);
      if (decoded is Map) {
        return 'JSON object; keys=${decoded.keys.join(', ')}';
      }
      if (decoded is List) return 'JSON array; items=${decoded.length}';
    } on FormatException {
      // Plain text and HTML are summarized below.
    }

    if (RegExp(
      r'<\s*(?:!doctype\s+html|html\b|head\b|body\b)',
      caseSensitive: false,
    ).hasMatch(text)) {
      return 'HTML response (${text.length} characters)';
    }

    text = text
        .replaceAll(
          RegExp(
            r'\b(otp|verification code)\s*[:=]?\s*\d{4,8}\b',
            caseSensitive: false,
          ),
          r'$1=<redacted>',
        )
        .replaceAll(
          RegExp(r'\bBearer\s+\S+', caseSensitive: false),
          'Bearer <redacted>',
        )
        .replaceAll(
          RegExp(
            r'"?([A-Za-z0-9_-]*(?:id_token|access_token|refresh_token|token|password|secret|authorization|otp|phone)[A-Za-z0-9_-]*)"?\s*:\s*"[^"]*"',
            caseSensitive: false,
          ),
          '"<redacted>":"<redacted>"',
        )
        .replaceAll(
          RegExp(
            r'\b[A-Za-z0-9_-]{20,}\.[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\b',
          ),
          '<redacted-jwt>',
        )
        .replaceAll(RegExp(r'\b\d{8,15}\b'), '<redacted-number>');

    return text.length <= 512 ? text : '${text.substring(0, 512)}…';
  }

  String? _safeBackendMessage(dynamic body) {
    dynamic decoded = body;
    if (body is String) {
      try {
        decoded = jsonDecode(body);
      } on FormatException {
        return _safeLogText(body);
      }
    }
    if (decoded is Map) {
      final message =
          decoded['message'] ?? decoded['detail'] ?? decoded['error'];
      if (message is String && message.isNotEmpty) {
        return _safeLogText(message);
      }
    }
    return null;
  }

  String _safeErrorMessage(Object error) {
    if (error is DioException) {
      return _dioErrorMessage(error, error.response?.statusCode);
    }
    if (error is _FirebaseBackendAuthException) {
      return _safeLogText(error.message);
    }
    return 'Unexpected authentication error (${error.runtimeType}).';
  }

  String _dioErrorMessage(DioException error, int? statusCode) {
    if (statusCode == 401) {
      return 'The backend rejected Firebase authentication (HTTP 401).';
    }
    if (statusCode != null && statusCode >= 500) {
      return 'Firebase backend authentication is unavailable (HTTP $statusCode).';
    }
    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout =>
        'Firebase backend authentication timed out.',
      DioExceptionType.connectionError =>
        'Unable to connect to Firebase backend authentication.',
      _ =>
        'Firebase backend request failed${statusCode == null ? '' : ' (HTTP $statusCode)'}.',
    };
  }

  String _safeLogText(String text) {
    return _safeResponseBody(text);
  }

  void _showFirebaseTokenDebugSnackbar(String token, String userId) {
    if (!kDebugMode ||
        token.isEmpty ||
        _auth.currentUser?.uid != userId ||
        (_firebaseTokenDebugSnackbarToken == token &&
            _firebaseTokenDebugSnackbar != null)) {
      return;
    }

    _closeFirebaseTokenDebugSnackbar();
    final snackbarSequence = ++_firebaseTokenDebugSnackbarSequence;
    _firebaseTokenDebugSnackbarToken = token;
    _firebaseTokenDebugSnackbarUserId = userId;
    _firebaseTokenDebugSnackbar = Get.rawSnackbar(
      messageText: _FirebaseTokenDebugContent(token: token),
      duration: const Duration(minutes: 2),
      snackPosition: SnackPosition.BOTTOM,
      snackStyle: SnackStyle.FLOATING,
      backgroundColor: Get.theme.colorScheme.surfaceContainerHighest,
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      borderRadius: 12,
      maxWidth: 640,
      isDismissible: false,
      snackbarStatus: (status) {
        if (status == SnackbarStatus.CLOSED &&
            _firebaseTokenDebugSnackbarSequence == snackbarSequence) {
          _firebaseTokenDebugSnackbar = null;
          _firebaseTokenDebugSnackbarToken = null;
          _firebaseTokenDebugSnackbarUserId = null;
        }
      },
    );
  }

  void _closeFirebaseTokenDebugSnackbar() {
    final snackbar = _firebaseTokenDebugSnackbar;
    _firebaseTokenDebugSnackbar = null;
    _firebaseTokenDebugSnackbarToken = null;
    _firebaseTokenDebugSnackbarUserId = null;
    if (snackbar != null) unawaited(snackbar.close());
  }

  //////////////////////////////////////////////////////////////
  /// RESEND OTP
  //////////////////////////////////////////////////////////////

  void resendOtp() {
    if (!isOtpSent.value) return;
    if (!canResend.value) {
      Get.snackbar(
        "Please wait",
        "You can request another code in ${resendSeconds.value} seconds",
      );
      return;
    }

    otpController.clear();
    sendOtp();
  }

  void changePhoneNumber() {
    _verificationId = null;
    _resendTimer?.cancel();
    isOtpSent.value = false;
    canResend.value = false;
    resendSeconds.value = 30;
    otpController.clear();
  }

  //////////////////////////////////////////////////////////////
  /// REGISTER CONTROLLERS
  //////////////////////////////////////////////////////////////

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final isUsernameValid = false.obs;
  final isPasswordStrong = false.obs;
  final isPasswordMatching = false.obs;
  final isFormValid = false.obs;
  final passwordStrength = 0.0.obs;

  //////////////////////////////////////////////////////////////
  /// PROFILE CONTROLLERS
  //////////////////////////////////////////////////////////////

  final fullNameController = TextEditingController();
  final emailController = TextEditingController();

  final isNameValid = false.obs;
  final isEmailValid = false.obs;
  final isProfileFormValid = false.obs;

  //////////////////////////////////////////////////////////////
  /// FOCUS
  //////////////////////////////////////////////////////////////

  final passwordFocusNode = FocusNode();
  final isPasswordFocused = false.obs;

  //////////////////////////////////////////////////////////////
  /// INIT
  //////////////////////////////////////////////////////////////

  @override
  void onInit() {
    super.onInit();

    _authStateSubscription = _auth.authStateChanges().listen((_) {
      if (_firebaseTokenDebugSnackbarUserId != null &&
          _auth.currentUser?.uid != _firebaseTokenDebugSnackbarUserId) {
        _closeFirebaseTokenDebugSnackbar();
      }
    });

    usernameController.addListener(_validateUsername);
    passwordController.addListener(_validatePassword);
    confirmPasswordController.addListener(_validateConfirmPassword);

    phoneController.addListener(() {
      final phone = phoneController.text.trim();
      isPhoneValid.value = RegExp(r'^[0-9]{10}$').hasMatch(phone);
    });

    passwordFocusNode.addListener(() {
      isPasswordFocused.value = passwordFocusNode.hasFocus;
    });

    fullNameController.addListener(_validateProfile);
    phoneController.addListener(_validateProfile);
    emailController.addListener(_validateProfile);
  }

  //////////////////////////////////////////////////////////////
  /// VALIDATIONS
  //////////////////////////////////////////////////////////////

  void _validateUsername() {
    isUsernameValid.value = usernameController.text.trim().length >= 4;
    _validateForm();
  }

  void _validatePassword() {
    final password = passwordController.text;

    double strength = 0;

    if (password.isEmpty) {
      strength = 0;
    } else if (password.length < 6) {
      strength = 0.3;
    } else if (password.length < 8) {
      strength = 0.6;
    } else {
      strength = 1.0;
    }

    passwordStrength.value = strength;
    isPasswordStrong.value = strength >= 0.6;

    _validateConfirmPassword();
    _validateForm();
  }

  void _validateConfirmPassword() {
    isPasswordMatching.value =
        passwordController.text == confirmPasswordController.text &&
        confirmPasswordController.text.isNotEmpty;

    _validateForm();
  }

  void _validateForm() {
    isFormValid.value =
        isUsernameValid.value &&
        isPasswordStrong.value &&
        isPasswordMatching.value;
  }

  void _validateProfile() {
    isNameValid.value = fullNameController.text.trim().length >= 3;

    isEmailValid.value = RegExp(
      r'^[^@]+@[^@]+\.[^@]+',
    ).hasMatch(emailController.text.trim());

    isProfileFormValid.value = isNameValid.value && isEmailValid.value;
  }

  //////////////////////////////////////////////////////////////
  /// REGISTER
  //////////////////////////////////////////////////////////////

  void register() {
    if (!isFormValid.value) return;

    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    print("Registering:");
    print(username);
    print(password);

    Get.offAllNamed(Routes.FillProfileOnentry);
  }

  //////////////////////////////////////////////////////////////
  /// DISPOSE
  //////////////////////////////////////////////////////////////

  @override
  void onClose() {
    _resendTimer?.cancel();
    _authStateSubscription?.cancel();
    _closeFirebaseTokenDebugSnackbar();
    phoneController.dispose();
    otpController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    fullNameController.dispose();
    emailController.dispose();
    passwordFocusNode.dispose();
    otpFocusNode.dispose();
    super.onClose();
  }
}

class _FirebaseBackendAuthException implements Exception {
  const _FirebaseBackendAuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

class _FirebaseTokenDebugContent extends StatefulWidget {
  const _FirebaseTokenDebugContent({required this.token});

  final String token;

  @override
  State<_FirebaseTokenDebugContent> createState() =>
      _FirebaseTokenDebugContentState();
}

class _FirebaseTokenDebugContentState
    extends State<_FirebaseTokenDebugContent> {
  Timer? _confirmationTimer;
  bool _copied = false;

  Future<void> _copyToken() async {
    await Clipboard.setData(ClipboardData(text: widget.token));
    if (!mounted) return;

    _confirmationTimer?.cancel();
    setState(() => _copied = true);
    _confirmationTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  void dispose() {
    _confirmationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 360),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'FIREBASE TOKEN DEBUG',
            style: theme.textTheme.titleSmall?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 180,
            child: Scrollbar(
              child: SingleChildScrollView(
                child: SelectableText(
                  widget.token,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurface,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: _copyToken,
              icon: const Icon(Icons.copy),
              label: const Text('Copy Token'),
            ),
          ),
          if (_copied)
            Text(
              'Firebase ID token copied to clipboard',
              style: theme.textTheme.bodySmall?.copyWith(color: colors.primary),
            ),
        ],
      ),
    );
  }
}
