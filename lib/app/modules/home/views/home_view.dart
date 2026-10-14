import 'dart:math';
import 'package:budgetbook_2026/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            _heroBackground(),
            TweenAnimationBuilder(
              duration: const Duration(milliseconds: 700),
              tween: Tween<double>(begin: 0, end: 1),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, 40 * (1 - value)),
                  child: Opacity(opacity: value, child: child),
                );
              },
              child: Column(
                children: [
                  _glassHeader(),
                  SizedBox(height: 5.h),

                  Text(
                    "B U D G E T  B O O K",
                    style: TextStyle(
                      fontFamily: 'BalooBhai2',
                      fontSize: 22.sp,
                      color: Colors.grey.shade200,
                      letterSpacing: 4,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  // SizedBox(height: 15.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: _walletAnalyticsBookCard(context), // dynamic now
                  ),

                  SizedBox(height: 15.h),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: incomeExpenseCard(), // dynamic now
                  ),

                  SizedBox(height: 15.h),

                  _categorySection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget incomeExpenseCard() {
    return Container(
      padding: EdgeInsets.all(8.w),

      // decoration: BoxDecoration(
      //   borderRadius: BorderRadius.circular(30.r),

      //   /// Soft Parent Glass
      //   gradient: LinearGradient(
      //     colors: [
      //       Colors.white.withOpacity(.35),
      //       Colors.white.withOpacity(.08),
      //     ],
      //   ),

      //   border: Border.all(color: Colors.white.withOpacity(.40)),

      //   boxShadow: [
      //     BoxShadow(
      //       color: Colors.black.withOpacity(.10),
      //       blurRadius: 18,
      //       offset: const Offset(0, 8),
      //     ),
      //   ],
      // ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => Get.toNamed(Routes.INCOME_EXPENSE),
              child: _financeCapsule(
                title: "Income",
                amount: "₹${controller.totalIncome.value}",

                icon: Icons.arrow_downward_rounded,
                colors: const [Color(0xFF0FB9B1), Color(0xFF6EE7E0)],
              ),
            ),
          ),

          SizedBox(width: 8.w),

          Expanded(
            child: InkWell(
              onTap: () => Get.toNamed(Routes.Expense),
              child: _financeCapsule(
                title: "Expense",
                amount: "0",
                icon: Icons.arrow_upward_rounded,
                colors: const [Color(0xFFFF6B6B), Color(0xFFFF9A9A)],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _financeCapsule({
    required String title,
    required String amount,
    required IconData icon,
    required List<Color> colors,
  }) {
    return Container(
      height: 75.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26.r),

        /// ⭐ Smooth Fintech Gradient
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),

        /// ⭐ Floating Capsule Shadow
        boxShadow: [
          // BoxShadow(
          //   color: colors.first.withOpacity(.35),
          //   blurRadius: 16,
          //   offset: const Offset(0, 8),
          // ),
        ],
      ),

      child: Row(
        children: [
          /// Icon Glass Bubble
          Container(
            height: 42.h,
            width: 42.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withOpacity(.70),
            ),
            child: Icon(icon, color: Colors.white, size: 18.sp),
          ),

          SizedBox(width: 12.w),

          /// Text Content
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'BalooBhai2',
                  fontSize: 12.sp,
                  color: Colors.white.withOpacity(.85),
                  fontWeight: FontWeight.w500,
                ),
              ),

              SizedBox(height: 2.h),

              Text(
                amount,
                style: TextStyle(
                  fontFamily: 'BalooBhai2',
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroBackground() {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 1.1, end: 1),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: ClipPath(
        clipper: HeroBigCurveClipper(),
        child: Container(
          height: 320.h,
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal, Color(0xFFB2F7EF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),

          child: Stack(
            children: [
              /// ⭐ BACK FLOW SHAPE
              Positioned.fill(
                child: CustomPaint(painter: FinanceFlowPainter(opacity: .20)),
              ),

              /// ⭐ FRONT FLOW SHAPE
              Positioned.fill(
                child: CustomPaint(
                  painter: FinanceFlowPainter(opacity: .10, reverse: true),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _glassHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: Container(
        height: 70.h,
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25.r),

          /// Glass Gradient
          // gradient: LinearGradient(
          //   colors: [
          //     Colors.white.withOpacity(.55),
          //     Colors.white.withOpacity(.25),
          //   ],
          // ),

          /// Glass Border
          // border: Border.all(color: Colors.white.withOpacity(.6)),

          /// Glass Shadow
          // boxShadow: [
          //   BoxShadow(
          //     color: Colors.black.withOpacity(.08),
          //     blurRadius: 20,
          //     offset: const Offset(0, 8),
          //   ),
          // ],
        ),

        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            /// ===== LEFT PROFILE =====
            Row(
              children: [
                InkWell(
                  onTap: () => Get.toNamed(Routes.Profile),
                  child: Container(
                    height: 45.h,
                    width: 45.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: const DecorationImage(
                        image: NetworkImage("https://i.pravatar.cc/150?img=3"),
                        fit: BoxFit.cover,
                      ),

                      // boxShadow: [
                      //   BoxShadow(
                      //     color: Colors.black.withOpacity(.2),
                      //     blurRadius: 8,
                      //     offset: const Offset(0, 4),
                      //   ),
                      // ],
                    ),
                  ),
                ),

                SizedBox(width: 12.w),

                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome Back",
                      style: TextStyle(
                        fontFamily: 'BalooBhai2',
                        fontSize: 12.sp,
                        color: Colors.grey.shade200,
                      ),
                    ),
                    Text(
                      "Abhi Ram",
                      style: TextStyle(
                        fontFamily: 'BalooBhai2',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            Row(
              children: [
                InkWell(
                  onTap: () => Get.toNamed(Routes.INFO),
                  child: glassHeaderIcon(
                    icon: Icons.notifications_none_rounded,
                  ),
                ),
                SizedBox(width: 12.w),
                glassHeaderIcon(icon: FontAwesomeIcons.language, size: 18),
              ],
            ),
          ],
        ),
      ),
    );
  }

  //Circular Icon Helper
  Widget glassHeaderIcon({
    required IconData icon,
    VoidCallback? onTap,
    double size = 22,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 45.h,
        width: 45.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.25),
          border: Border.all(color: Colors.white.withOpacity(.5)),
          // boxShadow: [
          //   BoxShadow(
          //     color: Colors.black.withOpacity(.12),
          //     blurRadius: 12,
          //     offset: const Offset(0, 5),
          //   ),
          // ],
        ),

        child: Icon(icon, size: size.sp, color: Colors.white.withOpacity(.85)),
      ),
    );
  }

  String formatIndianAmount(num amount) {
    if (amount >= 10000000) {
      // Crore
      return "${(amount / 10000000).toStringAsFixed(2)}Cr";
    } else if (amount >= 100000) {
      // Lakh
      return "${(amount / 100000).toStringAsFixed(2)}L";
    } else if (amount >= 1000) {
      // Thousand
      return "${(amount / 1000).toStringAsFixed(1)}K";
    } else {
      return amount.toStringAsFixed(0);
    }
  }

  /// ================= WALLET STYLE HERO CARD (THEME ADAPTIVE) =================
  Widget _walletAnalyticsBookCard(BuildContext context) {
    final income = controller.totalIncome.value;
    final expense = 0;
    final balance = income - expense;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final scheme = theme.colorScheme;

    /// Warm paper tone (important!)
    final pageColor = isDark ? scheme.surface : const Color(0xFFFFFBF2);

    /// ⭐ BOOK COVER USING APP PRIMARY COLORS (3D READY)
    final coverGradient = LinearGradient(
      colors: [
        const Color(0xFF00C9A7), // highlight
        const Color(0xFF009E88), // mid tone (derived)
        const Color(0xFF007C6E), // dark edge
      ],
      stops: const [0.0, 0.45, 1.0],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    return Transform(
      /// Slight tilt = HUGE realism boost
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.0012) // ⭐ perspective depth
        ..rotateX(-0.40) // ⭐ tilt away at top
        ..rotateZ(-0.02),

      child: Container(
        height: 220.h,
        width: double.infinity,

        /// BOOK COVER
        /// BOOK COVER
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.r),
          gradient: coverGradient,

          /// Subtle material border (not outline color)
          border: Border.all(
            color: isDark
                ? Colors.black.withOpacity(0.7)
                : Colors.black.withOpacity(0.25),
            width: 1,
          ),

          /// Realistic depth shadow
        ),
        child: Row(
          children: [
            // ================= LEFT PAGE =================
            Expanded(
              child: ClipRRect(
                child: ClipPath(
                  clipper: _PageClipper(isLeft: true),
                  child: Container(
                    color: pageColor, // 🔥 blocks green bleed

                    child: Container(
                      padding: EdgeInsets.only(
                        bottom: 8.h,
                        top: 8.h,

                        left: 6.w,
                      ),

                      decoration: BoxDecoration(
                        color: pageColor,

                        /// ONLY one soft shadow toward spine
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(
                              isDark ? 0.45 : 0.12,
                            ),
                            blurRadius: 28,
                            offset: const Offset(6, 0),
                          ),
                        ],
                      ),

                      child: Stack(
                        children: [
                          /// Gentle paper shading near spine
                          Positioned(
                            right: 0,
                            top: 0,
                            bottom: 0,
                            child: Container(
                              width: 22.w,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.black.withOpacity(0.12),
                                    Colors.transparent,
                                  ],
                                  begin: Alignment.centerRight,
                                  end: Alignment.centerLeft,
                                ),
                              ),
                            ),
                          ),

                          /// Outer lift highlight
                          Positioned(
                            left: 0,
                            top: 0,
                            bottom: 0,
                            child: Container(
                              width: 14.w,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withOpacity(0.35),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),

                          Positioned.fill(
                            child: CustomPaint(
                              painter: LedgerLinesPainter(
                                isDark: isDark,
                                lineCount: 0,
                              ),
                            ),
                          ),

                          /// YOUR DONUT CENTER (unchanged)
                          Center(
                            child: SizedBox(
                              height: 130.h,
                              width: 130.w,
                              child: CustomPaint(
                                painter: MultiColorDonutPainterLight(),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Balance",
                                        style: TextStyle(
                                          fontFamily: 'BalooBhai2',
                                          fontSize: 12.sp,
                                          color: scheme.onSurfaceVariant,
                                        ),
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        "₹${formatIndianAmount(balance)}",
                                        style: TextStyle(
                                          fontSize: 22.sp,
                                          fontFamily: 'BalooBhai2',
                                          fontWeight: FontWeight.bold,
                                          color: scheme.onSurface,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ================= SPINE =================
            Container(
              width: 12.w,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [Colors.black, Colors.grey.shade800, Colors.black]
                      : [
                          const Color(0xFF2E1F1A),
                          const Color(0xFF6D4C41),
                          const Color(0xFF2E1F1A),
                        ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                // boxShadow: [
                //   BoxShadow(
                //     color: Colors.black.withOpacity(0.7),
                //     blurRadius: 12,
                //     spreadRadius: 2,
                //   ),
                // ],
              ),
            ),

            // ================= RIGHT PAGE =================
            Expanded(
              child: ClipPath(
                clipper: _PageClipper(isLeft: false),
                child: Container(
                  color: pageColor, // 🔥 blocks background bleed
                  child: Container(
                    padding: EdgeInsets.only(bottom: 8.h, top: 8.h, right: 6.w),
                    decoration: BoxDecoration(
                      color: pageColor,

                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.45 : 0.12),
                          blurRadius: 28,
                          offset: const Offset(-6, 0),
                        ),
                      ],
                    ),

                    child: Stack(
                      children: [
                        /// Gentle shading near spine
                        Positioned(
                          left: 0,
                          top: 0,
                          bottom: 0,
                          child: Container(
                            width: 22.w,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black.withOpacity(0.12),
                                  Colors.transparent,
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                            ),
                          ),
                        ),

                        /// Outer lift highlight
                        Positioned(
                          right: 0,
                          top: 0,
                          bottom: 0,
                          child: Container(
                            width: 14.w,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  Colors.white.withOpacity(0.35),
                                ],
                              ),
                            ),
                          ),
                        ),

                        Positioned.fill(
                          child: CustomPaint(
                            painter: LedgerLinesPainter(
                              isDark: isDark,
                              lineCount: 5,
                            ),
                          ),
                        ),

                        /// YOUR TEXT COLUMN (unchanged)
                        Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 8.h,
                            horizontal: 16.w,
                          ),

                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(height: 13.h),

                              _infoRowLedger(
                                context,
                                "Income",
                                formatIndianAmount(income),
                                const Color(0xFF2EC4B6),
                              ),
                              SizedBox(height: 6.h),

                              _infoRowLedger(
                                context,
                                "Expense",
                                formatIndianAmount(expense),
                                const Color(0xFFFF6B6B),
                              ),
                              SizedBox(height: 6.h),

                              _infoRowLedger(
                                context,
                                "Available",
                                formatIndianAmount(balance),
                                const Color(0xFFB8E728),
                              ),
                              SizedBox(height: 6.h),

                              _infoRowLedger(
                                context,
                                "Savings",
                                formatIndianAmount(income ~/ 2),
                                const Color(0xFFFFC857),
                              ),
                            ],
                          ),
                        ),
                      ],
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

  /// -------- INFO ROW --------
  Widget _infoRowLedger(
    BuildContext context,
    String title,
    String value,
    Color accentColor,
  ) {
    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 28.h,
      child: Row(
        children: [
          /// Accent dot
          Container(
            height: 10.h,
            width: 10.w,
            decoration: BoxDecoration(
              color: accentColor,
              shape: BoxShape.circle,
            ),
          ),

          SizedBox(width: 10.w),

          /// Title
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontFamily: 'BalooBhai2',
                fontSize: 14.sp,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),

          /// Amount
          Text(
            "₹$value",
            style: TextStyle(
              fontFamily: 'BalooBhai2',
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: scheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  // Categories
  Widget _categorySection() {
    final categories = [
      _CategoryModel(
        "Lend",
        FontAwesomeIcons.handHoldingDollar,
        Color(0xFF2EC4B6),
        Routes.LEND_BORROW,
      ),
      _CategoryModel(
        "Borrow",
        FontAwesomeIcons.moneyBillTransfer,
        Colors.orange,
        Routes.Borrow,
      ),
      _CategoryModel(
        "Loans",
        FontAwesomeIcons.landmark,
        Colors.red,
        Routes.LOANS,
      ),
      _CategoryModel(
        "Chit Fund",
        FontAwesomeIcons.users,
        Color(0xFFB8E728),
        Routes.CHIT_FUNDS,
      ),
      _CategoryModel(
        "Budget",
        FontAwesomeIcons.calculator,
        Color(0xFFFFC857),
        Routes.LEND_BORROW,
      ),
      _CategoryModel(
        "Credit Card",
        FontAwesomeIcons.creditCard,
        Colors.blue,
        Routes.CREDIT_CARDS,
      ),
      _CategoryModel(
        "EMI",
        FontAwesomeIcons.clockRotateLeft,
        Colors.purple,
        Routes.LEND_BORROW,
      ),
      _CategoryModel(
        "Invest",
        FontAwesomeIcons.chartLine,
        Colors.teal,
        Routes.LEND_BORROW,
      ),
    ];

    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 900),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Container(
          padding: EdgeInsets.all(18.w),

          // decoration: BoxDecoration(
          //   borderRadius: BorderRadius.circular(28.r),

          //   /// Glass Style
          //   gradient: LinearGradient(
          //     colors: [
          //       Colors.white.withOpacity(.55),
          //       Colors.white.withOpacity(.20),
          //     ],
          //   ),

          //   border: Border.all(color: Colors.white.withOpacity(.8)),

          //   boxShadow: [
          //     BoxShadow(
          //       color: Colors.black.withOpacity(.08),
          //       blurRadius: 18,
          //       offset: const Offset(0, 10),
          //     ),
          //   ],
          // ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Title
              Text(
                "Categories",
                style: TextStyle(
                  fontFamily: 'BalooBhai2',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 18.h),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: categories.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 18.h,
                  crossAxisSpacing: 12.w,
                  childAspectRatio: .85,
                ),
                itemBuilder: (_, index) {
                  final item = categories[index];
                  return InkWell(
                    onTap: () => Get.toNamed(item.route),
                    child: _categoryItem(item),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _categoryItem(_CategoryModel item) {
    return Column(
      children: [
        /// Icon Glass Bubble
        Container(
          height: 58.h,
          width: 58.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,

            gradient: LinearGradient(
              colors: [
                item.color.withOpacity(.85),
                item.color.withOpacity(.55),
              ],
            ),

            // boxShadow: [
            //   BoxShadow(
            //     color: item.color.withOpacity(.40),
            //     blurRadius: 12,
            //     offset: const Offset(0, 6),
            //   ),
            // ],
          ),
          child: Icon(item.icon, color: Colors.white, size: 22.sp),
        ),

        SizedBox(height: 8.h),

        Text(
          item.title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'BalooBhai2',
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _PageClipper extends CustomClipper<Path> {
  final bool isLeft;

  _PageClipper({required this.isLeft});

  @override
  Path getClip(Size size) {
    final path = Path();

    path.moveTo(0, 0);

    // Top curve
    path.quadraticBezierTo(size.width * 0.5, size.height * 0.10, size.width, 0);

    path.lineTo(size.width, size.height);

    // Bottom curve
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.90,
      0,
      size.height,
    );

    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class PageCurvePainter extends CustomPainter {
  final bool isLeftPage;
  final bool isDark;

  PageCurvePainter({required this.isLeftPage, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();

    // Create realistic page bow
    path.moveTo(0, 0);

    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.10, // TOP CURVE
      size.width,
      0,
    );

    path.lineTo(size.width, size.height);

    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.90, // BOTTOM CURVE
      0,
      size.height,
    );

    path.close();

    final paint = Paint()
      ..shader = LinearGradient(
        begin: isLeftPage ? Alignment.centerRight : Alignment.centerLeft,
        end: isLeftPage ? Alignment.centerLeft : Alignment.centerRight,
        colors: isDark
            ? [Colors.black.withOpacity(0.35), Colors.transparent]
            : [Colors.black.withOpacity(0.15), Colors.transparent],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// ===== Custom Painter for Ledger Lines =====
/// Ledger Lines per page
class LedgerLinesPainter extends CustomPainter {
  final bool isDark;
  final int lineCount;

  LedgerLinesPainter({required this.isDark, this.lineCount = 10});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDark ? Colors.white12 : Colors.grey.withOpacity(0.25)
      ..strokeWidth = 1;

    final spacing = size.height / (lineCount + 1);

    for (int i = 1; i <= lineCount; i++) {
      canvas.drawLine(
        Offset(0, spacing * i),
        Offset(size.width, spacing * i),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CategoryModel {
  final String title;
  final IconData icon;
  final Color color;
  final String route;

  _CategoryModel(this.title, this.icon, this.color, this.route);
}

class FinanceFlowPainter extends CustomPainter {
  final double opacity;
  final bool reverse;

  FinanceFlowPainter({this.opacity = .15, this.reverse = false});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(opacity)
      ..style = PaintingStyle.fill;

    final path = Path();

    if (!reverse) {
      path.moveTo(0, size.height * .6);

      path.quadraticBezierTo(
        size.width * .25,
        size.height * .4,
        size.width * .5,
        size.height * .6,
      );

      path.quadraticBezierTo(
        size.width * .75,
        size.height * .8,
        size.width,
        size.height * .55,
      );

      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
    } else {
      path.moveTo(0, size.height * .3);

      path.quadraticBezierTo(
        size.width * .3,
        size.height * .5,
        size.width * .6,
        size.height * .3,
      );

      path.quadraticBezierTo(
        size.width * .85,
        size.height * .1,
        size.width,
        size.height * .25,
      );

      path.lineTo(size.width, 0);
      path.lineTo(0, 0);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

////////////////////////////////////////////////////////////
/// 🔥 MULTI COLOR DONUT PAINTER
////////////////////////////////////////////////////////////

class MultiColorDonutPainterLight extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height).deflate(10);
    const stroke = 16.0;

    final values = [40, 20, 25, 15];

    /// Gradient color pairs
    final gradientPairs = [
      [const Color(0xFF0FB9B1), const Color(0xFF0FB9B1)], // Income
      [const Color(0xFFFF6B6B), const Color(0xFFFF9A9A)], // Expense
      [const Color(0xFFB8E728), const Color(0xFFE7FF8A)], // Savings
      [const Color(0xFFFFC857), const Color(0xFFFFE39A)], // Investment
    ];

    double startAngle = -pi / 2;

    /// Background Ring
    final bgPaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;

    canvas.drawArc(rect, 0, 2 * pi, false, bgPaint);

    /// Draw Gradient Segments
    for (int i = 0; i < values.length; i++) {
      final sweep = (values[i] / 100) * 2 * pi;

      /// Create Sweep Gradient aligned to arc
      final gradient = SweepGradient(
        startAngle: startAngle,
        endAngle: startAngle + sweep,
        colors: gradientPairs[i],
      );

      final paint = Paint()
        ..shader = gradient.createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(rect, startAngle, sweep, false, paint);

      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class HeroBigCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();

    path.lineTo(0, size.height - 80);

    path.quadraticBezierTo(
      size.width / 2,
      size.height + 60,
      size.width,
      size.height - 80,
    );

    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
