import 'package:budgetbook_2026/app/core/utils/formate_helper.dart';
import 'package:budgetbook_2026/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/chit_funds_controller.dart';

class ChitFundsView extends GetView<ChitFundsController> {
  const ChitFundsView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      floatingActionButton: addChitFundFAB(),
      backgroundColor: isDark ? const Color(0xFF0B1220) : Colors.grey.shade100,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF0B1220) : Colors.white,
        centerTitle: true,
        title: Text(
          "Chit Funds",
          style: TextStyle(
            fontFamily: "BalooBhai2",
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final list = controller.chits;

        return Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              /// 🔥 HERO (ONLY PLACE WITH GRADIENT)
              _overview(),

              SizedBox(height: 16.h),

              /// 🔹 LIST
              Expanded(
                child: list.isEmpty
                    ? const Center(child: Text("No Chits Found"))
                    : ListView.builder(
                        itemCount: list.length,
                        itemBuilder: (_, i) {
                          return _chitTile(list[i], isDark);
                        },
                      ),
              ),
            ],
          ),
        );
      }),
    );
  }

  ////////////////////////////////////////////////////
  /// 🔥 OVERVIEW (FINTECH HERO)
  ////////////////////////////////////////////////////
  Widget _overview() {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        gradient: const LinearGradient(
          colors: [Color(0xFF8FCF1A), Color(0xFFB8E728)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFB8E728).withOpacity(.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Total Value",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12.sp,
              fontFamily: "BalooBhai2",
            ),
          ),

          SizedBox(height: 6.h),

          Text(
            FormatHelper.formatINR(controller.totalValue),
            style: TextStyle(
              fontSize: 26.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: "BalooBhai2",
            ),
          ),

          SizedBox(height: 14.h),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _metric("Monthly", controller.totalMonthly),
              _metric("Active", controller.activeChits.toDouble()),
              _metric("Groups", controller.chits.length.toDouble()),
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
          title == "Active"
              ? value.toInt().toString()
              : FormatHelper.formatCompact(value),
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
  /// 🔥 CHIT TILE (REAL UI — NOT BLUE)
  ////////////////////////////////////////////////////
  Widget _chitTile(dynamic c, bool isDark) {
    double value = double.tryParse(c.chitValue ?? "0") ?? 0;
    double monthly = double.tryParse(c.chitMonthly ?? "0") ?? 0;

    return InkWell(
      onTap: () => _showBottomSheet(c, isDark),
      borderRadius: BorderRadius.circular(18.r),

      child: Container(
        margin: EdgeInsets.only(bottom: 14.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 10),
          ],
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔹 TOP ROW
            Row(
              children: [
                CircleAvatar(
                  radius: 22.r,
                  backgroundColor: Color(0xFFB8E728).withOpacity(.1),
                  child: Text(
                    c.chitName[0],
                    style: TextStyle(
                      fontFamily: "BalooBhai2",
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFB8E728),
                    ),
                  ),
                ),

                SizedBox(width: 12.w),

                Expanded(
                  child: Text(
                    c.chitName,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      fontFamily: "BalooBhai2",
                    ),
                  ),
                ),

                Text(
                  FormatHelper.formatINR(value),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: "BalooBhai2",
                  ),
                ),
              ],
            ),

            SizedBox(height: 10.h),

            /// 🔹 DETAILS ROW
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _mini("Monthly", monthly),
                _mini("Members", double.parse(c.chitMembers ?? "0")),
                _mini("Duration", double.parse(c.chitDuration ?? "0")),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget addChitFundFAB() {
    return FloatingActionButton.extended(
      onPressed: () {
        Get.toNamed(Routes.PostChitFundsView);
      },
      backgroundColor: const Color(0xFFB8E728),
      icon: const Icon(Icons.add),
      label: Text("Insert", style: TextStyle(fontFamily: "BalooBhai2")),
    );
  }

  Widget _mini(String title, double val) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 10.sp,
            color: Colors.grey,
            fontFamily: "BalooBhai2",
          ),
        ),
        Text(
          FormatHelper.formatCompact(val),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12.sp,
            fontFamily: "BalooBhai2",
          ),
        ),
      ],
    );
  }

  ////////////////////////////////////////////////////
  /// 🔥 BOTTOM SHEET (DETAILS + DELETE)
  ////////////////////////////////////////////////////
  void _showBottomSheet(dynamic c, bool isDark) {
    double value = double.tryParse(c.chitValue ?? "0") ?? 0;
    double monthly = double.tryParse(c.chitMonthly ?? "0") ?? 0;
    double afterMonthly = double.tryParse(c.chitMonthlyAfter ?? "0") ?? 0;
    double members = double.tryParse(c.chitMembers ?? "0") ?? 0;
    double duration = double.tryParse(c.chitDuration ?? "0") ?? 0;
    double liftAmount = double.tryParse(c.chitLiftAmount ?? "0") ?? 0;

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1C28) : Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// 🔹 HANDLE
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(.4),
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),

            SizedBox(height: 16.h),

            /// 🔹 HEADER (LIKE PROFILE)
            Row(
              children: [
                CircleAvatar(
                  radius: 26.r,
                  backgroundColor: const Color(0xFFB8E728).withOpacity(.15),
                  child: Text(
                    c.chitName[0].toUpperCase(),
                    style: TextStyle(
                      fontFamily: "BalooBhai2",
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFB8E728),
                    ),
                  ),
                ),

                SizedBox(width: 12.w),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c.chitName,
                        style: TextStyle(
                          fontFamily: "BalooBhai2",
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        "Total Value: ${FormatHelper.formatINR(value)}",
                        style: TextStyle(
                          fontFamily: "BalooBhai2",
                          fontSize: 12.sp,
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 18.h),

            /// 🔥 GLASS DETAILS CARD
            Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18.r),
                color: isDark
                    ? Colors.white.withOpacity(.05)
                    : Colors.grey.withOpacity(.08),
                border: Border.all(color: Colors.grey.withOpacity(.15)),
              ),
              child: Column(
                children: [
                  /// ROW 1
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _miniInfo("Monthly", monthly, Colors.blue),
                      _miniInfo("After", afterMonthly, Colors.green),
                      _miniInfo("Members", members, Colors.orange),
                    ],
                  ),

                  SizedBox(height: 12.h),

                  /// ROW 2
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _miniInfo("Duration", duration, Colors.purple),
                      _miniInfo("Lift Amt", liftAmount, Colors.red),
                      _miniInfo(
                        "Status",
                        double.parse(c.status ?? "0"),
                        c.status == "0" ? Colors.green : Colors.grey,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 16.h),

            /// 🔹 DATES
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _dateTile("Start", c.chitStart),
                _dateTile("End", c.chitEnd),
              ],
            ),

            SizedBox(height: 20.h),

            /// 🔥 ACTIONS (PRO)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _actionBtn(
                  Icons.edit,
                  "Modify",
                  Colors.blue,
                  onTap: () {
                    Get.back();
                    Get.toNamed(Routes.EDIT_CHIT_FUNDS, arguments: c);
                  },
                ),

                _actionBtn(
                  Icons.delete,
                  "Remove",
                  Colors.red,
                  onTap: () {
                    Get.back();
                    _showDeleteConfirmation(
                      Get.context!,
                      int.parse(c.id.toString()),
                    );
                  },
                ),
              ],
            ),

            SizedBox(height: 10.h),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showDeleteConfirmation(BuildContext context, int id) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// HANDLE
            Container(
              height: 4,
              width: 50,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey.withOpacity(.3),
              ),
            ),

            /// ICON
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red.withOpacity(.1),
              ),
              child: const Icon(
                Icons.delete_outline,
                color: Colors.red,
                size: 28,
              ),
            ),

            const SizedBox(height: 16),

            /// TITLE
            const Text(
              "Remove Chit?",
              style: TextStyle(
                fontFamily: "BalooBhai2",
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            /// SUBTITLE
            const Text(
              "This action cannot be undone.\nAre you sure you want to delete this chit fund?",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: "BalooBhai2",
                fontSize: 13,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 22),

            /// BUTTONS
            Row(
              children: [
                /// CANCEL
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(fontFamily: "BalooBhai2"),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                /// DELETE
                Expanded(
                  child: Obx(() {
                    return ElevatedButton(
                      onPressed: controller.isDeleteLoading.value
                          ? null
                          : () async {
                              Get.close(2);
                              await Future.delayed(
                                const Duration(milliseconds: 200),
                              );
                              await controller.deleteChit(id);
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: controller.isDeleteLoading.value
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              "Remove",
                              style: TextStyle(
                                fontFamily: "BalooBhai2",
                                color: Colors.white,
                              ),
                            ),
                    );
                  }),
                ),
              ],
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _miniInfo(String title, double value, Color color) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: "BalooBhai2",
            fontSize: 10.sp,
            color: Colors.grey,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          title == "Status"
              ? (value == 0 ? "Active" : "Closed")
              : FormatHelper.formatCompact(value),
          style: TextStyle(
            fontFamily: "BalooBhai2",
            fontSize: 13.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _dateTile(String title, String date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 10.sp,
            color: Colors.grey,
            fontFamily: "BalooBhai2",
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          FormatHelper.formatDate(date),
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            fontFamily: "BalooBhai2",
          ),
        ),
      ],
    );
  }

  Widget _actionBtn(
    IconData icon,
    String label,
    Color color, {
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            height: 46.h,
            width: 46.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(.12),
            ),
            child: Icon(icon, size: 18.sp, color: color),
          ),
          SizedBox(height: 6.h),
          Text(
            label,
            style: TextStyle(
              fontFamily: "BalooBhai2",
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
