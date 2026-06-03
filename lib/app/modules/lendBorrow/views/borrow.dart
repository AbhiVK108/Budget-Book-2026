import 'package:budgetbook_2026/app/core/utils/attachment_view_helper.dart';
import 'package:budgetbook_2026/app/core/utils/expansion_tile_helper.dart';
import 'package:budgetbook_2026/app/core/utils/formate_helper.dart';
import 'package:budgetbook_2026/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controllers/borrow_controller.dart';

class Borrow extends GetView<BorrowController> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      floatingActionButton: addBorrowFAB(),
      backgroundColor: isDark ? const Color(0xFF1C1C28) : Colors.grey.shade100,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF1C1C28) : Colors.white,
        centerTitle: true,
        title: Text(
          "You Borrowed",
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

        final totalBorrowed = controller.getTotalBorrowAmount();
        final totalPending = controller.getTotalPendingAmount();

        final paid = controller.getTotalPaidAmount();
        final progress = totalBorrowed == 0 ? 0.0 : (paid / totalBorrowed);

        final list = controller.filteredList;

        return Padding(
          padding: EdgeInsets.all(18.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 🔥 OVERVIEW CARD (RED THEME)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFFFB74D), // light
                      Color(0xFFFF9800), // main
                      Color(0xFFE65100), // dark,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// TITLE
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Borrow Overview",
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.white70,
                            fontFamily: "BalooBhai2",
                          ),
                        ),
                        Text(
                          "${(progress * 100).toInt()}%",
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            fontFamily: "BalooBhai2",
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 10.h),

                    /// TOTAL BORROWED
                    Text(
                      FormatHelper.formatINR(totalBorrowed),
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: "BalooBhai2",
                      ),
                    ),

                    SizedBox(height: 4.h),

                    Text(
                      "Total You Borrowed",
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.white70,
                        fontFamily: "BalooBhai2",
                      ),
                    ),

                    SizedBox(height: 12.h),

                    /// PROGRESS
                    LinearProgressIndicator(
                      value: progress,
                      minHeight: 8.h,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation(Colors.white),
                    ),

                    SizedBox(height: 12.h),

                    /// METRICS
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _overviewMetric("Paid", paid),
                        _overviewMetric("Pending", totalPending),
                        _overviewMetric("Interest", 0),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 15.h),

              _filterTabs(context),

              SizedBox(height: 20.h),

              Text(
                "People you owe",
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  fontFamily: "BalooBhai2",
                ),
              ),  

              SizedBox(height: 10.h),

              /// LIST
              Expanded(
                child: list.isEmpty
                    ? const Center(
                        child: Text(
                          "No Data",
                          style: TextStyle(fontFamily: "BalooBhai2"),
                        ),
                      )
                    : ListView.builder(
                        itemCount: list.length,
                        itemBuilder: (_, index) {
                          final item = list[index];
                          return _personTile(item, isDark);
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
  /// FAB
  ////////////////////////////////////////////////////
  Widget addBorrowFAB() {
    return FloatingActionButton.extended(
      onPressed: () {
        Get.toNamed(Routes.PostBorrow);
      },
      backgroundColor: Colors.orangeAccent,
      icon: const Icon(Icons.add),
      label: const Text("Borrow"),
    );
  }

  ////////////////////////////////////////////////////
  /// FILTER
  ////////////////////////////////////////////////////
  Widget _filterTabs(BuildContext context) {
    return Obx(() {
      return Row(
        children: List.generate(controller.filters.length, (index) {
          final selected = controller.selectedFilter.value == index;

          return Expanded(
            child: GestureDetector(
              onTap: () async {
                if (index == 3) {
                  final picked = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );

                  if (picked != null) {
                    controller.startDate = picked.start;
                    controller.endDate = picked.end;
                    controller.selectedFilter.value = 3;
                    controller.applyFilter();
                  }
                } else {
                  controller.selectedFilter.value = index;
                  controller.applyFilter();
                }
              },
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                padding: EdgeInsets.symmetric(vertical: 10.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14.r),
                  color: selected
                      ? Colors.orange
                      : Colors.grey.withOpacity(.15),
                ),
                child: Center(
                  child: Text(
                    controller.filters[index],
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontFamily: "BalooBhai2",
                      color: selected ? Colors.white : null,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      );
    });
  }

  ////////////////////////////////////////////////////
  /// PERSON TILE
  Widget _personTile(item, bool isDark) {
    double borrowed = double.tryParse(item.amount.toString()) ?? 0;
    double paid = double.tryParse(item.paidAmount?.toString() ?? "0") ?? 0;

    double pending = borrowed - paid;
    double progress = borrowed == 0 ? 0 : paid / borrowed;

    String name = item.receiveFrom ?? "";

    return InkWell(
      borderRadius: BorderRadius.circular(18.r),
      onTap: () => _showBorrowBottomSheet(Get.context!, item, isDark),

      child: Container(
        margin: EdgeInsets.only(bottom: 14.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A2A3C) : Colors.white,
          borderRadius: BorderRadius.circular(18.r),
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔹 TOP ROW
            Row(
              children: [
                CircleAvatar(
                  radius: 22.r,
                  backgroundColor: Colors.orange.withOpacity(.2),
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : "?",
                    style: TextStyle(
                      fontFamily: "BalooBhai2",
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ),

                SizedBox(width: 12.w),

                /// NAME + DATE
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: "BalooBhai2",
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      SizedBox(height: 2.h),

                      Text(
                        FormatHelper.formatDate(item.receiveDate),
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.grey,
                          fontFamily: "BalooBhai2",
                        ),
                      ),
                    ],
                  ),
                ),

                /// PENDING
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      FormatHelper.formatINR(pending),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                        fontFamily: "BalooBhai2",
                      ),
                    ),
                    Text(
                      "Pending",
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: Colors.grey,
                        fontFamily: "BalooBhai2",
                      ),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 10.h),

            /// 🔹 PROGRESS BAR
            ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6.h,
                backgroundColor: Colors.grey.withOpacity(.2),
                valueColor: const AlwaysStoppedAnimation(Colors.orange),
              ),
            ),

            SizedBox(height: 8.h),

            /// 🔹 FOOTER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Borrowed: ${FormatHelper.formatINR(borrowed)}",
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.grey,
                    fontFamily: "BalooBhai2",
                  ),
                ),

                Row(
                  children: [
                    Icon(Icons.touch_app, size: 14.sp, color: Colors.grey),
                    SizedBox(width: 4.w),
                    Text(
                      "Tap for details",
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.grey,
                        fontFamily: "BalooBhai2",
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  ////////////////////////////////////////////////////
  void _showBorrowBottomSheet(BuildContext context, item, bool isDark) {
    double borrowed = double.tryParse(item.amount.toString()) ?? 0;
    double paid = double.tryParse(item.paidAmount?.toString() ?? "0") ?? 0;
    double interest = double.tryParse(item.rateOfInterest.toString()) ?? 0;

    double total = borrowed + interest;
    double pending = total - paid;

    String name = item.receiveFrom ?? "";

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
            /// HANDLE
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(.4),
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),

            SizedBox(height: 16.h),

            /// PROFILE
            Row(
              children: [
                CircleAvatar(
                  radius: 26.r,
                  backgroundColor: Colors.orange.withOpacity(.15),
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : "?",
                    style: TextStyle(
                      fontFamily: "BalooBhai2",
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ),

                SizedBox(width: 12.w),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontFamily: "BalooBhai2",
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        "Outstanding: ${FormatHelper.formatINR(pending)}",
                        style: TextStyle(
                          fontFamily: "BalooBhai2",
                          fontSize: 12.sp,
                          color: Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 18.h),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.description.isNotEmpty)
                  ExpandableText(text: item.description),
              ],
            ),
            SizedBox(height: 10.h),

            if (item.receipt != null && item.receipt!.isNotEmpty) ...[
              SizedBox(height: 10.h),

              GestureDetector(
                onTap: () {
                  ReceiptViewerHelper.open(item.receipt!);
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.attach_file,
                      size: 16.sp,
                      color: Colors.blueAccent,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      "View Attachment",
                      style: TextStyle(
                        fontFamily: "BalooBhai2",
                        fontSize: 12.sp,
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            SizedBox(height: 18.h),

            /// 🔥 DETAILS CARD
            Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18.r),
                color: isDark
                    ? Colors.white.withOpacity(.05)
                    : Colors.grey.withOpacity(.08),
                border: Border.all(color: Colors.grey.withOpacity(.15)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _miniInfo("Borrowed", borrowed, Colors.red),
                  _miniInfo("Paid", paid, Colors.green),
                  _miniInfo("Interest", interest, Colors.blue),
                  _miniInfo("Pending", pending, Colors.orange),
                ],
              ),
            ),

            SizedBox(height: 20.h),

            /// 🔥 ACTIONS (SAME AS LEND)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _actionBtn(
                  FontAwesomeIcons.penToSquare,
                  "Modify",
                  Colors.blue,
                  onTap: () {
                    Get.back();
                    Get.toNamed(Routes.BorrowEditView, arguments: item);
                  },
                ),

                _actionBtn(
                  FontAwesomeIcons.trash,
                  "Remove",
                  Colors.red,
                  onTap: () {
                    Get.back();
                    _showDeleteConfirmation(
                      context,
                      int.tryParse(item.id.toString()) ?? 0,
                    );
                  },
                ),

                _actionBtn(
                  FontAwesomeIcons.phone,
                  "Call",
                  Colors.green,
                  onTap: () {
                    _makeCall();
                  },
                ),

                _actionBtn(
                  FontAwesomeIcons.whatsapp,
                  "WhatsApp",
                  Colors.teal,
                  onTap: () {
                    _openWhatsApp();
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
              "Remove Record?",
              style: TextStyle(
                fontFamily: "BalooBhai2",
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            /// SUBTITLE
            const Text(
              "This action cannot be undone.\nAre you sure you want to remove this borrow record?",
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
                              Get.back();

                              await controller.deleteBorrow(id);

                              /// 🔥 IMPORTANT: refresh list
                              controller.fetchBorrows();
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

  Widget _miniInfo(String title, double amount, Color color) {
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
          FormatHelper.formatCompact(amount),
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
            style: TextStyle(fontFamily: "BalooBhai2", fontSize: 11.sp),
          ),
        ],
      ),
    );
  }

  ////////////////////////////////////////////////////
  Widget _overviewMetric(String title, double amount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.white70,
            fontFamily: "BalooBhai2",
            fontSize: 11.sp,
          ),
        ),
        Text(
          FormatHelper.formatCompact(amount),
          style: const TextStyle(
            fontFamily: "BalooBhai2",
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  ////////////////////////////////////////////////////
  Future<void> _makeCall() async {
    final Uri url = Uri(scheme: 'tel', path: '7337563108');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> _openWhatsApp() async {
    final Uri url = Uri.parse("https://wa.me/7337563108");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }
}
