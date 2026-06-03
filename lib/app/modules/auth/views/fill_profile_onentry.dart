import 'package:budgetbook_2026/app/modules/auth/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class FillProfileOnentry extends GetView<AuthController> {
  const FillProfileOnentry({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          /// Gradient Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF004D44), const Color(0xFF002F2A)]
                    : [const Color(0xFF00C9A7), const Color(0xFF007C6E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          /// Main Content
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                children: [
                  SizedBox(height: 70.h),

                  /// Welcome Lottie
                  SizedBox(
                    height: 190.h,
                    child: Lottie.asset(
                      "assets/lotties/hello.json",
                      repeat: true,
                    ),
                  ),

                  SizedBox(height: 0.h),

                  Text(
                    "Let’s Know You Better 💡",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: "BalooBhai2",
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 6.h), // spacing between title and caption
                  Text(
                    "We just need a few details to personalize your experience",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: "BalooBhai2",
                      fontSize: 13.sp,
                      color: Colors.white.withOpacity(0.85),
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  SizedBox(height: 30.h),

                  /// Profile Card
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 22.w,
                      vertical: 28.h,
                    ),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      borderRadius: BorderRadius.circular(26.r),
                    ),
                    child: Obx(() {
                      final isValid = controller.isProfileFormValid.value;

                      return Column(
                        children: [
                          _animatedField(
                            label: "Full Name",
                            hint: "Enter your full name",
                            controller: controller.fullNameController,
                            isDark: isDark,
                            isValid: controller.isNameValid.value,
                          ),

                          SizedBox(height: 18.h),

                          _animatedField(
                            label: "Phone Number",
                            hint: "Enter your phone",
                            controller: controller.phoneController,
                            isDark: isDark,
                            isValid: controller.isPhoneValid.value,
                          ),

                          SizedBox(height: 18.h),

                          _animatedField(
                            label: "Email Address",
                            hint: "Enter your email",
                            controller: controller.emailController,
                            isDark: isDark,
                            isValid: controller.isEmailValid.value,
                          ),

                          SizedBox(height: 30.h),

                          /// Continue Button
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            height: 52.h,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30.r),
                              gradient: isValid
                                  ? const LinearGradient(
                                      colors: [
                                        Color(0xFF00C9A7),
                                        Color(0xFF008E7F),
                                      ],
                                    )
                                  : null,
                              color: isValid ? null : Colors.grey.shade400,
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(30.r),
                                onTap: isValid
                                    ? () {
                                        Get.offAllNamed("/home");
                                      }
                                    : null,
                                child: Center(
                                  child: Text(
                                    "Continue",
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
                          ),
                        ],
                      );
                    }),
                  ),

                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ),

          /// Skip Button
          SafeArea(
            child: Padding(
              padding: EdgeInsets.only(right: 20.w, top: 10.h),
              child: Align(
                alignment: Alignment.topRight,
                child: Material(
                  color: Colors.white.withOpacity(
                    0.25,
                  ), // semi-transparent background
                  borderRadius: BorderRadius.circular(20.r),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20.r),
                    onTap: () => Get.offAllNamed("/home"),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 18.w,
                        vertical: 6.h,
                      ),
                      child: Text(
                        "Skip",
                        style: TextStyle(
                          fontFamily: "BalooBhai2",
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              offset: Offset(0, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  //////////////////////////////////////////////////////////////
  /// Animated Field (Adaptive)
  //////////////////////////////////////////////////////////////

  Widget _animatedField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required bool isDark,
    required bool isValid,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: "BalooBhai2",
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        SizedBox(height: 6.h),
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
            style: TextStyle(
              fontFamily: "BalooBhai2",
              fontSize: 14.sp,
              color: isDark ? Colors.white : Colors.black,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                fontFamily: "BalooBhai2",
                fontSize: 13.sp,
                color: isDark ? Colors.white54 : Colors.black54,
              ),
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
}
