import 'package:budgetbook_2026/app/modules/auth/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class Login extends GetView<AuthController> {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SizedBox.expand(
        child: Stack(
          children: [
            ////////////////////////////////////////////////////////////
            /// Gradient Background
            ////////////////////////////////////////////////////////////
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 380.h,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.teal, Color(0xFFB2F7EF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),

            ////////////////////////////////////////////////////////////
            /// Content
            ////////////////////////////////////////////////////////////
            SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  children: [
                    SizedBox(height: 100.h),

                    ////////////////////////////////////////////////////
                    /// Title
                    ////////////////////////////////////////////////////
                    Text(
                      "Welcome",
                      style: TextStyle(
                        fontFamily: "BalooBhai2",
                        fontSize: 26.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    SizedBox(height: 8.h),

                    Text(
                      "Enter your mobile number to continue",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: "BalooBhai2",
                        fontSize: 14.sp,
                        color: Colors.white.withOpacity(.9),
                      ),
                    ),

                    SizedBox(height: 40.h),

                    ////////////////////////////////////////////////////
                    /// Card
                    ////////////////////////////////////////////////////
                    Obx(() {
                      return Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 22.w,
                          vertical: 30.h,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E1E1E)
                              : Colors.white.withOpacity(.95),
                          borderRadius: BorderRadius.circular(26.r),
                        ),
                        child: Column(
                          children: [
                            _phoneField(isDark),

                            if (controller.isOtpSent.value) ...[
                              SizedBox(height: 14.h),
                              Text(
                                "Enter the 6-digit code sent to +91 ${controller.phoneController.text.trim()}",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: "BalooBhai2",
                                  fontSize: 10.sp,
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.black54,
                                ),
                              ),
                              SizedBox(height: 16.h),
                              TextField(
                                controller: controller.otpController,
                                focusNode: controller.otpFocusNode,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.done,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(6),
                                ],
                                maxLength: 6,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: "BalooBhai2",
                                  fontSize: 18.sp,
                                  letterSpacing: 8,
                                ),
                                decoration: InputDecoration(
                                  labelText: "Verification code",
                                  hintText: "6-digit OTP",
                                  counterText: "",
                                  filled: true,
                                  fillColor: isDark
                                      ? const Color(0xFF2A2A2A)
                                      : const Color(0xFFF5F5F5),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14.r),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                              SizedBox(height: 16.h),
                              SizedBox(
                                height: 52.h,
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: controller.isVerifyingOtp.value
                                      ? null
                                      : controller.verifyOtp,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.teal,
                                    disabledBackgroundColor: Colors.teal
                                        .withOpacity(.55),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30.r),
                                    ),
                                  ),
                                  child: controller.isVerifyingOtp.value
                                      ? const SizedBox(
                                          height: 22,
                                          width: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text(
                                          "Verify OTP",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  TextButton(
                                    onPressed:
                                        controller.canResend.value &&
                                            !controller.isSendingOtp.value
                                        ? controller.resendOtp
                                        : null,
                                    child: Text(
                                      controller.canResend.value
                                          ? "Resend code"
                                          : "Resend in ${controller.resendSeconds.value}s",
                                      style: TextStyle(
                                        fontFamily: "BalooBhai2",
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed:
                                        controller.isSendingOtp.value ||
                                            controller.isVerifyingOtp.value
                                        ? null
                                        : controller.changePhoneNumber,
                                    child: Text(
                                      "Change number",
                                      style: TextStyle(
                                        fontFamily: "BalooBhai2",
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ] else ...[
                              SizedBox(height: 20.h),
                              SizedBox(
                                height: 52.h,
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed:
                                      controller.isPhoneValid.value &&
                                          !controller.isSendingOtp.value
                                      ? controller.sendOtp
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.teal,
                                    disabledBackgroundColor: Colors.teal
                                        .withOpacity(.55),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30.r),
                                    ),
                                  ),
                                  child: controller.isSendingOtp.value
                                      ? const SizedBox(
                                          height: 22,
                                          width: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text(
                                          "Send OTP",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    }),
                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //////////////////////////////////////////////////////////////
  /// Phone Field
  //////////////////////////////////////////////////////////////
  Widget _phoneField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Mobile Number",
          style: TextStyle(
            fontFamily: "BalooBhai2",
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: controller.phoneController,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.done,
          readOnly: controller.isOtpSent.value,
          maxLength: 10,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          style: TextStyle(fontFamily: "BalooBhai2", fontSize: 14.sp),
          decoration: InputDecoration(
            prefixText: "+91 ",
            counterText: "",
            filled: true,
            fillColor: isDark
                ? const Color(0xFF2A2A2A)
                : const Color(0xFFF5F5F5),
            hintText: "Enter Mobile Number",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
