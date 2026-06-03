import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import '../controllers/credit_cards_controller.dart';

class CreditCardsView extends GetView<CreditCardsController> {
  const CreditCardsView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1220) : Colors.grey.shade100,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF0B1220) : Colors.white,
        centerTitle: true,
        title: Text(
          "Credit Cards",
          style: TextStyle(
            fontFamily: "BalooBhai2",
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Obx(() {
        final cards = controller.cards;

        double totalUsed = controller.totalUsed;
        double totalLimit = controller.totalLimit;
        double percent = totalLimit == 0 ? 0 : totalUsed / totalLimit;

        return Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 🔥 SMART DASHBOARD (REAL USE CASE)
              _smartOverview(totalUsed, totalLimit, percent),

              SizedBox(height: 18.h),

              /// 🔥 BILL ALERT SECTION (IMPORTANT UX)
              _billAlertSection(cards),

              SizedBox(height: 18.h),

              /// 🔥 CARD STACK VIEW (MODERN)
              Expanded(
                child: cards.isEmpty
                    ? const Center(child: Text("No Cards"))
                    : ListView.builder(
                        itemCount: cards.length,
                        itemBuilder: (_, i) {
                          return _proCard(cards[i]);
                        },
                      ),
              ),
            ],
          ),
        );
      }),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.blueAccent,
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: Text("Add Card", style: TextStyle(fontFamily: "BalooBhai2")),
      ),
    );
  }

  ////////////////////////////////////////////////////
  /// 🔥 SMART OVERVIEW (FINTECH STYLE)
  ////////////////////////////////////////////////////
  Widget _smartOverview(double used, double limit, double percent) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        gradient: const LinearGradient(
          colors: [Colors.blue, Colors.blueAccent],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Total Exposure",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12.sp,
              fontFamily: "BalooBhai2",
            ),
          ),

          SizedBox(height: 6.h),

          Text(
            "₹${used.toStringAsFixed(0)}",
            style: TextStyle(
              color: Colors.white,
              fontSize: 26.sp,
              fontWeight: FontWeight.bold,
              fontFamily: "BalooBhai2",
            ),
          ),

          SizedBox(height: 12.h),

          LinearProgressIndicator(
            value: percent,
            minHeight: 8.h,
            backgroundColor: Colors.white.withOpacity(.2),
            valueColor: const AlwaysStoppedAnimation(Colors.white),
          ),

          SizedBox(height: 10.h),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _metric("Limit", limit),
              _metric("Used %", percent * 100),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metric(String title, double value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 11.sp,
            fontFamily: "BalooBhai2",
          ),
        ),
        Text(
          title == "Used %"
              ? "${value.toStringAsFixed(0)}%"
              : "₹${value.toStringAsFixed(0)}",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14.sp,
            fontFamily: "BalooBhai2",
          ),
        ),
      ],
    );
  }

  ////////////////////////////////////////////////////
  /// 🔥 BILL ALERT (REAL WORLD UX)
  ////////////////////////////////////////////////////
  Widget _billAlertSection(List cards) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18.r),
        color: Colors.orange.withOpacity(.1),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 22.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              "2 bills due this week • Avoid late fees",
              style: TextStyle(
                fontFamily: "BalooBhai2",
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            "Pay Now",
            style: TextStyle(
              color: Colors.blueAccent,
              fontWeight: FontWeight.bold,
              fontFamily: "BalooBhai2",
            ),
          ),
        ],
      ),
    );
  }

  ////////////////////////////////////////////////////
  /// 💳 PRO CARD UI (REAL FINTECH LOOK)
  ////////////////////////////////////////////////////
  Widget _proCard(dynamic c) {
    double percent = c.limit == 0 ? 0 : c.used / c.limit;

    /// 🔥 SMART COLOR (REAL FINTECH LOGIC)
    Color usageColor;
    if (percent < 0.3) {
      usageColor = Colors.green;
    } else if (percent < 0.7) {
      usageColor = Colors.orange;
    } else {
      usageColor = Colors.red;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),

        /// 🔥 GLASS / CLEAN CARD (NOT BLUE)
        color: Get.isDarkMode ? Colors.white.withOpacity(.05) : Colors.white,

        border: Border.all(color: Colors.grey.withOpacity(.15)),

        boxShadow: [
          if (!Get.isDarkMode)
            BoxShadow(
              color: Colors.black.withOpacity(.05),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔹 TOP ROW
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                c.bank,
                style: TextStyle(
                  fontFamily: "BalooBhai2",
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),

              /// 🔥 UTILIZATION BADGE
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: usageColor.withOpacity(.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  "${(percent * 100).toInt()}%",
                  style: TextStyle(
                    color: usageColor,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                    fontFamily: "BalooBhai2",
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 6.h),

          Text(
            c.number,
            style: TextStyle(
              color: Colors.grey,
              letterSpacing: 2,
              fontFamily: "BalooBhai2",
            ),
          ),

          SizedBox(height: 12.h),

          /// 🔹 USAGE BAR (COLOR BASED)
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 6.h,
              backgroundColor: Colors.grey.withOpacity(.2),
              valueColor: AlwaysStoppedAnimation(usageColor),
            ),
          ),

          SizedBox(height: 10.h),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Used ₹${c.used}",
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Colors.grey,
                  fontFamily: "BalooBhai2",
                ),
              ),
              Text(
                "Limit ₹${c.limit}",
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Colors.grey,
                  fontFamily: "BalooBhai2",
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          /// 🔹 ACTIONS (SUBTLE, NOT LOUD)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _actionBtn(Icons.payment, "Pay"),
              _actionBtn(Icons.notifications, "Remind"),
              _actionBtn(Icons.analytics, "Stats"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(IconData icon, String text) {
    return Column(
      children: [
        CircleAvatar(
          radius: 18.r,
          // backgroundColor: Colors.white.withOpacity(.2),
          backgroundColor: Get.isDarkMode
              ? Colors.white.withOpacity(.05)
              : Colors.grey.withOpacity(.2),
          // child: Icon(icon, color: Colors.white, size: 16.sp),
          child: Icon(icon, color: Colors.blueAccent, size: 16.sp),
        ),
        SizedBox(height: 4.h),
        Text(
          text,
          style: TextStyle(
            fontSize: 10.sp,
            color: Get.isDarkMode ? Colors.white70 : Colors.grey,
            fontFamily: "BalooBhai2",
          ),
        ),
      ],
    );
  }
}

class CardModel {
  String bank;
  String number;
  double used;
  double limit;
  String dueDate;

  CardModel({
    required this.bank,
    required this.number,
    required this.used,
    required this.limit,
    required this.dueDate,
  });
}
