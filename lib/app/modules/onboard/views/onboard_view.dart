import 'dart:math';

import 'package:budgetbook_2026/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../controllers/onboard_controller.dart';

class OnboardView extends GetView<OnboardController> {
  const OnboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _heroBackground(),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                children: [
                  SizedBox(height: 60.h),

                  /// Floating Icons Section
                  _floatingIcons(),

                  const Spacer(),

                  /// App Title
                  Text(
                    "B U D G E T  B O O K",
                    style: TextStyle(
                      fontFamily: 'BalooBhai2',
                      fontSize: 32.sp,
                      fontWeight: FontWeight.bold,
                      // color: Colors.white,
                    ),
                  ),

                  SizedBox(height: 8.h),

                  /// Tagline
                  Text(
                    "Manage Income, Expenses, Loans,\nCredit Cards & Chit Funds Easily",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'BalooBhai2',
                      fontSize: 14.sp,
                      // color: Colors.white.withOpacity(.9),
                    ),
                  ),

                  SizedBox(height: 40.h),

                  /// Get Started Button
                  _primaryButton("Get Started", () {
                    Get.toNamed(Routes.AUTH);
                  }),

                  SizedBox(height: 12.h),

                  /// Login Button
                  // _secondaryButton("Already have account? Login", () {}),

                  SizedBox(height: 30.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /////////////////////////////////////////////////////////////
  /// HERO BACKGROUND
  /////////////////////////////////////////////////////////////

  Widget _heroBackground() {
    return ClipPath(
      clipper: _OnboardCurveClipper(),
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
    );
  }

  /////////////////////////////////////////////////////////////
  /// FLOATING FINANCE ICONS
  /////////////////////////////////////////////////////////////

  Widget _floatingIcons() {
    final items = [
      _FloatingItemModel(
        isIcon: true,
        icon: FontAwesomeIcons.arrowTrendUp,
        title: "Income",
        color: const Color(0xFF2ECC71),
        offset: Offset(-115.w, -40.h),
        size: 95.w,
      ),
      _FloatingItemModel(
        isIcon: true,
        icon: FontAwesomeIcons.arrowTrendDown,
        title: "Expense",
        color: const Color(0xFFE74C3C),
        offset: Offset(110.w, -100.h),
        size: 92.w,
      ),
      _FloatingItemModel(
        image: "assets/images/loan.png",
        title: "Loan",
        color: const Color(0xFFF39C12),
        offset: Offset(-90.w, 85.h),
        size: 100.w,
      ),
      _FloatingItemModel(
        image: "assets/images/atm-card.png",
        title: "Credit Card",
        color: const Color(0xFF3498DB),
        offset: Offset(80.w, 98.h),
        size: 96.w,
      ),
      _FloatingItemModel(
        image: "assets/images/teamwork.png",
        title: "Chit Fund",
        color: const Color(0xFF9B59B6),
        offset: Offset(15.w, -10.h),
        size: 110.w,
      ),
    ];

    return SizedBox(
      height: 190.h,
      child: Stack(
        alignment: Alignment.center,
        children: items.map((item) {
          return _floatingClusterItem(item);
        }).toList(),
      ),
    );
  }

  Widget _floatingClusterItem(_FloatingItemModel item) {
    return AnimatedBuilder(
      animation: controller.floatController,
      builder: (context, child) {
        final value = controller.floatController.value * 2 * pi;

        // Smooth circular finance motion
        final floatX = cos(value) * 4;
        final floatY = sin(value) * 6;

        // Subtle professional pulse
        final scale = 1 + (sin(value) * 0.02);

        return Transform.translate(
          offset: item.offset + Offset(floatX, floatY),
          child: Transform.scale(scale: scale, child: child),
        );
      },
      child: Container(
        width: item.size,
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18.r),
          color: Colors.white.withOpacity(.94),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.05),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: item.color.withOpacity(.18),
              blurRadius: 20,
              spreadRadius: 1,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(color: item.color.withOpacity(.15), width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 44.w,
              width: 44.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    item.color.withOpacity(.15),
                    item.color.withOpacity(.05),
                  ],
                ),
              ),
              child: Center(
                child: item.isIcon
                    ? FaIcon(item.icon!, color: item.color, size: 22.sp)
                    : Image.asset(item.image!, height: 30.h),
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              item.title,
              style: TextStyle(
                fontFamily: "BalooBhai2",
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                color: item.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /////////////////////////////////////////////////////////////
  /// BUTTONS
  /////////////////////////////////////////////////////////////

  Widget _primaryButton(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 55.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25.r),
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(.1), blurRadius: 12),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            fontFamily: 'BalooBhai2',
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.teal,
          ),
        ),
      ),
    );
  }


}

////////////////////////////////////////////////////////////
/// CURVE CLIPPER
////////////////////////////////////////////////////////////

class _OnboardCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();

    path.lineTo(0, size.height - 100);

    path.quadraticBezierTo(
      size.width / 2,
      size.height + 60,
      size.width,
      size.height - 100,
    );

    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _FloatingItemModel {
  final bool isIcon;
  final IconData? icon;
  final String? image;
  final String title;
  final Color color;
  final Offset offset;
  final double size;

  _FloatingItemModel({
    this.isIcon = false,
    this.icon,
    this.image,
    required this.title,
    required this.color,
    required this.offset,
    required this.size,
  });
}
