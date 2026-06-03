import 'package:budgetbook_2026/app/routes/app_pages.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  //////////////////////////////////////////////////////////////
  /// FIREBASE INSTANCE
  //////////////////////////////////////////////////////////////

  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _verificationId;
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
    resendSeconds.value = 30;
    canResend.value = false;

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      resendSeconds.value--;

      if (resendSeconds.value <= 0) {
        canResend.value = true;
        return false;
      }
      return true;
    });
  }

  ////////////////////////////////////////////////////////////
  /// SEND OTP (PRO VERSION)
  ////////////////////////////////////////////////////////////

  Future<void> sendOtp() async {
    final phone = phoneController.text.trim();

    isPhoneValid.value = RegExp(r'^[0-9]{10}$').hasMatch(phone);

    if (!isPhoneValid.value) {
      Get.snackbar("Invalid", "Enter valid 10-digit phone number");
      return;
    }

    try {
      isSendingOtp.value = true;

      await _auth.verifyPhoneNumber(
        phoneNumber: "+91$phone",
        timeout: const Duration(seconds: 60),

        ////////////////////////////////////////////////////////
        /// AUTO VERIFICATION
        ////////////////////////////////////////////////////////
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
          isSendingOtp.value = false;
          Get.offAllNamed(Routes.FillProfileOnentry);
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

          /// Focus AFTER UI updates
          Future.delayed(const Duration(milliseconds: 300), () {
            FocusScope.of(Get.context!).requestFocus(otpFocusNode);
          });
        },

        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      isSendingOtp.value = false;
      Get.snackbar("Error", e.toString());
    }
  }

  //////////////////////////////////////////////////////////////
  /// VERIFY OTP
  //////////////////////////////////////////////////////////////

  Future<void> verifyOtp() async {
    final otp = otpController.text.trim();

    if (otp.length != 6) {
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

      await _auth.signInWithCredential(credential);

      isVerifyingOtp.value = false;

      Get.back(); // close bottom sheet
      Get.offAllNamed(Routes.FillProfileOnentry);
    } catch (e) {
      isVerifyingOtp.value = false;
      Get.snackbar("Error", "Invalid OTP");
    }
  }

  //////////////////////////////////////////////////////////////
  /// RESEND OTP
  //////////////////////////////////////////////////////////////

  void resendOtp() {
    sendOtp();
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
    phoneController.dispose();
    otpController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    fullNameController.dispose();
    emailController.dispose();
    passwordFocusNode.dispose();
    super.onClose();
  }
}
