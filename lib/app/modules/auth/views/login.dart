import 'package:budgetbook_2026/app/modules/auth/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
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

                            SizedBox(height: 20.h),

                            ////////////////////////////////////////////////////
                            /// OTP FIELD (INLINE)
                            ////////////////////////////////////////////////////
                              TextField(
                                controller: controller.otpController,
                                keyboardType: TextInputType.number,
                                autofocus: true,
                                maxLength: 6,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: "BalooBhai2",
                                  fontSize: 18.sp,
                                  letterSpacing: 8,
                                ),
                                decoration: InputDecoration(
                                  labelText: "Enter OTP",
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
                                  onPressed: controller.verifyOtp,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.teal,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30.r),
                                    ),
                                  ),
                                  child: const Text("Verify OTP"),
                                ),
                              ),

                            SizedBox(height: 20.h),

                            ////////////////////////////////////////////////////
                            /// SEND / RESEND OTP BUTTON
                            ////////////////////////////////////////////////////
                            SizedBox(
                              height: 52.h,
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: controller.sendOtp,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.r),
                                  ),
                                ),
                                child: Text(
                                  controller.isOtpSent.value
                                      ? "Resend OTP"
                                      : "Send OTP",
                                ),
                              ),
                            ),
                          
                          
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
          style: TextStyle(fontFamily: "BalooBhai2", fontSize: 14.sp),
          decoration: InputDecoration(
            prefixText: "+91 ",
            filled: true,
            fillColor: isDark
                ? const Color(0xFF2A2A2A)
                : const Color(0xFFF5F5F5),
            hintText: "98765 43210",
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
