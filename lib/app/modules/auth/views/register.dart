import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../controllers/auth_controller.dart';

class AuthView extends GetView<AuthController> {
  const AuthView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SizedBox.expand(
        child: Stack(
          children: [
            /// Gradient Background
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 420.h,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.teal, Color(0xFFB2F7EF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),

            /// Main Content
            SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    children: [
                      SizedBox(height: 80.h),

                      /// Title
                      Text(
                        "Let’s Create Your Account",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: "BalooBhai2",
                          fontSize: 26.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),

                      SizedBox(height: 8.h),

                      Text(
                        "You're 1 minute away from smarter money control 💸",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: "BalooBhai2",
                          fontSize: 13.sp,
                          color: Colors.white.withOpacity(.9),
                        ),
                      ),

                      SizedBox(height: 30.h),

                      /// Register Card
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 22.w,
                          vertical: 28.h,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E1E1E)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(26.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(.12),
                              blurRadius: 25,
                              offset: const Offset(0, 15),
                            ),
                          ],
                        ),

                        child: Obx(() {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "🔒 Your data is encrypted & secure",
                                style: TextStyle(
                                  fontFamily: "BalooBhai2",
                                  fontSize: 12.sp,
                                  color: isDark
                                      ? Colors.white60
                                      : Colors.black54,
                                ),
                              ),

                              SizedBox(height: 25.h),

                              ////////////////////////////////////////////////////////////
                              /// PHONE FIELD
                              ////////////////////////////////////////////////////////////
                              _animatedField(
                                label: "Mobile Number",
                                hint: "Enter your phone number",
                                controller: controller.phoneController,
                                isDark: isDark,
                                isValid: controller.isPhoneValid.value,
                              ),

                              SizedBox(height: 20.h),

                              ////////////////////////////////////////////////////////////
                              /// OTP FIELD (NOW WORKING 🔥)
                              ////////////////////////////////////////////////////////////
                              if (controller.isOtpSent.value) ...[
                                _animatedField(
                                  label: "OTP",
                                  hint: "Enter 6-digit OTP",
                                  controller: controller.otpController,
                                  isDark: isDark,
                                  isValid:
                                      controller.otpController.text.length == 6,
                                  focusNode:
                                      controller.otpFocusNode, // 🔥 IMPORTANT
                                ),

                                SizedBox(height: 8.h),

                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: controller.resendOtp,
                                    child: Text(
                                      "Resend OTP",
                                      style: TextStyle(
                                        fontFamily: "BalooBhai2",
                                        fontSize: 12.sp,
                                        color: Colors.teal,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                              SizedBox(height: 12.h),

                              ////////////////////////////////////////////////////////////
                              /// BUTTON
                              ////////////////////////////////////////////////////////////
                              Obx(() {
                                final isLoading =
                                    controller.isSendingOtp.value ||
                                    controller.isVerifyingOtp.value;

                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  height: 44.h,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30.r),
                                    gradient: const LinearGradient(
                                      colors: [Colors.teal, Color(0xFF00C9A7)],
                                    ),
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(30.r),

                                      onTap: isLoading
                                          ? null
                                          : () {
                                              if (!controller.isOtpSent.value) {
                                                controller.sendOtp();
                                              } else {
                                                controller.verifyOtp();
                                              }
                                            },

                                      child: Center(
                                        child: isLoading
                                            ? const SizedBox(
                                                height: 20,
                                                width: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color: Colors.white,
                                                    ),
                                              )
                                            : Text(
                                                controller.isOtpSent.value
                                                    ? "Verify & Continue"
                                                    : "Send OTP",
                                                style: TextStyle(
                                                  fontFamily: "BalooBhai2",
                                                  fontSize: 15.sp,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ],
                          );
                        }),
                      ),
                      SizedBox(height: 30.h),
                    ],
                  ),
                ),
              ),
            ),

            /// Bottom Right Lottie (True Scaffold Corner)
            Positioned(
              bottom: 0,
              right: 0,
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.8,
                  child: SizedBox(
                    height: 230.h,
                    width: 230.w,
                    child: Lottie.asset(
                      "assets/lotties/register_animation.json",
                      repeat: true,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //////////////////////////////////////////////////////////////
  /// Animated Input Field
  //////////////////////////////////////////////////////////////

  Widget _animatedField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required bool isDark,
    bool isPassword = false,
    FocusNode? focusNode,
    required bool isValid,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: "BalooBhai2",
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        SizedBox(height: 8.h),
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: isValid ? Colors.teal : Colors.transparent,
              width: 1.2,
            ),
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            obscureText: isPassword,
            style: TextStyle(fontFamily: "BalooBhai2", fontSize: 15.sp),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(fontFamily: "BalooBhai2", fontSize: 15.sp),
              filled: true,
              fillColor: isDark
                  ? const Color(0xFF2A2A2A)
                  : const Color(0xFFF5F5F5),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 14.h,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: BorderSide.none,
              ),
              suffixIcon: isValid
                  ? const Icon(Icons.check_circle, color: Colors.teal, size: 20)
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  //////////////////////////////////////////////////////////////
  /// Password Strength Indicator
  //////////////////////////////////////////////////////////////
}
