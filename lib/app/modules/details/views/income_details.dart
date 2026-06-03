import 'package:budgetbook_2026/app/core/constant/app_url.dart';
import 'package:budgetbook_2026/app/core/theme/app_colors.dart';
import 'package:budgetbook_2026/app/core/utils/attachment_view_helper.dart';
import 'package:budgetbook_2026/app/core/utils/expansion_tile_helper.dart';
import 'package:budgetbook_2026/app/core/utils/formate_helper.dart';
import 'package:budgetbook_2026/app/data/models/income_model.dart';
import 'package:budgetbook_2026/app/modules/incomeExpense/controllers/income_expense_controller.dart';
import 'package:budgetbook_2026/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/in_ex_details_controller.dart';

class IncomeDetails extends GetView<IncomeExpenseDetailsController> {
  const IncomeDetails({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          controller.categoryName,
          style: TextStyle(
            fontFamily: "BalooBhai2",
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSalarySheet(context),
        backgroundColor: const Color(0xFF0FB9B1),
        label: Text("Insert", style: TextStyle(fontFamily: "BalooBhai2")),
        icon: const Icon(Icons.add),
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(18.w),
        child: Column(
          children: [
            _incomeSummaryCard(context, isDark),

            /// 🔥 SHOW DATE RANGE + CLEAR BUTTON
            Obx(() {
              if (controller.selectedFilter.value == 3 &&
                  controller.startDate != null &&
                  controller.endDate != null) {
                return Column(
                  children: [
                    SizedBox(height: 22.h),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${controller.formatDate(controller.startDate!)} - ${controller.formatDate(controller.endDate!)}",
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey,
                            fontFamily: "BalooBhai2",
                          ),
                        ),

                        GestureDetector(
                          onTap: controller.clearFilter,
                          child: Text(
                            "Clear",
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.redAccent,
                              fontFamily: "BalooBhai2",

                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }
              return const SizedBox();
            }),
            SizedBox(height: 12.h),
            _recordsSection(context, isDark),
          ],
        ),
      ),
    );
  }

  void _showAddSalarySheet(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final amountController = TextEditingController();
    final noteController = TextEditingController();

    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setState) {
          return Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
              color: isDark
                  ? const Color(0xFF1C1C1E)
                  : theme.colorScheme.surface,
            ),

            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// Handle Bar
                  Container(
                    height: 4.h,
                    width: 50.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.r),
                      color: Colors.grey.withOpacity(.3),
                    ),
                  ),

                  SizedBox(height: 18.h),

                  /// Title
                  Text(
                    "Salary",
                    style: TextStyle(
                      fontFamily: "BalooBhai2",
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  SizedBox(height: 20.h),

                  /// Amount Field
                  _textField(
                    controller: amountController,
                    hint: "Enter Amount",
                    icon: Icons.currency_rupee,
                    keyboard: TextInputType.number,
                  ),

                  SizedBox(height: 14.h),

                  /// Note Field
                  _textField(
                    controller: noteController,
                    hint: "Note / Description",
                    icon: Icons.edit_note,
                  ),

                  SizedBox(height: 18.h),

                  /// Date Picker
                  Row(
                    children: [
                      Expanded(
                        child: _pickerTile(
                          title:
                              "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                          icon: Icons.calendar_month,
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                              initialDate: selectedDate,
                            );

                            if (picked != null) {
                              setState(() => selectedDate = picked);
                            }
                          },
                        ),
                      ),

                      SizedBox(width: 12.w),

                      /// Time Picker
                      Expanded(
                        child: _pickerTile(
                          title: selectedTime.format(context),
                          icon: Icons.access_time,
                          onTap: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: selectedTime,
                            );

                            if (picked != null) {
                              setState(() => selectedTime = picked);
                            }
                          },
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 24.h),

                  /// Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back(); // 👉 only close
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        backgroundColor: const Color(0xFF0FB9B1),
                      ),
                      child: Text(
                        "Submit",
                        style: TextStyle(
                          fontFamily: "BalooBhai2",
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white60,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 10.h),
                ],
              ),
            ),
          );
        },
      ),
      isScrollControlled: true,
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboard,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      style: TextStyle(fontFamily: "BalooBhai2"),
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        hintText: hint,
        hintStyle: TextStyle(fontFamily: "BalooBhai2"),
        filled: true,
        fillColor: Colors.white.withOpacity(.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _pickerTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 12.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          color: Colors.white.withOpacity(.05),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18.sp),
            SizedBox(width: 8.w),
            Text(
              title,
              style: TextStyle(fontFamily: "BalooBhai2", fontSize: 13.sp),
            ),
          ],
        ),
      ),
    );
  }

  // -----------------------------------------------------------
  // ⭐ SUMMARY CARD
  // -----------------------------------------------------------

  Widget _incomeSummaryCard(BuildContext context, bool isDark) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28.r),
        color: isDark
            ? Colors.white.withOpacity(.05)
            : theme.colorScheme.surfaceVariant,
      ),
      child: Column(
        children: [
          /// Icon
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
              ),
            ),
            child: ClipOval(
              child: controller.categoryImage.isNotEmpty
                  ? Image.network(
                      AppUrl.getImageUrl(controller.categoryImage),
                      width: 28.sp,
                      height: 28.sp,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.account_balance_wallet,
                        color: Colors.white,
                        size: 28.sp,
                      ),
                    )
                  : Icon(
                      Icons.account_balance_wallet,
                      color: Colors.white,
                      size: 28.sp,
                    ),
            ),
          ),
          SizedBox(height: 14.h),

          /// Total Income
          Obx(
            () => Text(
              FormatHelper.formatINR(controller.totalAmount),
              style: TextStyle(
                fontFamily: "BalooBhai2",
                fontWeight: FontWeight.bold,
                fontSize: 28.sp,
              ),
            ),
          ),

          Text(
            "Total ${controller.categoryName} Income",
            style: TextStyle(
              fontFamily: "BalooBhai2",
              fontSize: 13.sp,
              color: theme.hintColor,
            ),
          ),

          SizedBox(height: 18.h),

          /// Filters
          _filterTabs(context),
        ],
      ),
    );
  }

  // -----------------------------------------------------------
  // ⭐ FILTER TABS
  // -----------------------------------------------------------

  Widget _filterTabs(BuildContext context) {
    return Column(
      children: [
        Obx(
          () => Row(
            children: List.generate(controller.filters.length, (index) {
              final selected = controller.selectedFilter.value == index;

              return Expanded(
                child: GestureDetector(
                  onTap: () async {
                    if (index == 3) {
                      // 👇 open date picker ONLY when clicked
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
                          ? const Color(0xFF0FB9B1)
                          : Colors.white.withOpacity(.08),
                    ),
                    child: Center(
                      child: Text(
                        controller.filters[index],
                        style: TextStyle(
                          fontFamily: "BalooBhai2",
                          fontSize: 12.sp,
                          color: selected ? Colors.white : null,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  // -----------------------------------------------------------
  // ⭐ RECORD LIST
  // -----------------------------------------------------------

  Widget _recordsSection(BuildContext context, bool isDark) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.filteredIncomes.isEmpty) {
          return const Center(child: Text("No records found"));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "My Records",
              style: TextStyle(
                fontFamily: "BalooBhai2",
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
              ),
            ),
            SizedBox(height: 12.h),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.filteredIncomes.length,
              itemBuilder: (context, index) {
                final item = controller.filteredIncomes[index];
                return _recordTile(context, item, isDark);
              },
            ),
          ],
        );
      }),
    );
  }

  // -----------------------------------------------------------
  // ⭐ SINGLE RECORD TILE
  // -----------------------------------------------------------
  Widget _recordTile(BuildContext context, IncomeModel item, bool isDark) {
    final amount = double.tryParse(item.amount) ?? 0;

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18.r),
        color: adaptiveSurface(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ================= TOP ROW =================
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /// ICON
              Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.r),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0FB9B1), Color(0xFF6EE7E0)],
                      ),
                    ),
                    child: const Icon(
                      Icons.arrow_downward,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ],
              ),

              SizedBox(width: 12.w),

              /// TITLE + DATE
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// DATE (formatted properly)
                    Text(
                      "+${FormatHelper.formatINR(amount)}",
                      style: TextStyle(
                        fontFamily: "BalooBhai2",
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                        color: AppColors.primary,
                      ),
                    ),

                    SizedBox(height: 4.h),

                    /// DESCRIPTION (Expandable)
                    ExpandableText(
                      text: item.description.isNotEmpty
                          ? item.description
                          : "N/A",
                    ),
                  ],
                ),
              ),
              SizedBox(width: 6.w),

              /// AMOUNT (using helper)

              /// MORE MENU
              Column(
                children: [
                  Text(
                    controller.formatDate(item.incomeDate),
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontFamily: "BalooBhai2",
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 2.h),

                  PopupMenuButton<String>(
                    padding: EdgeInsets.zero,
                    offset: const Offset(0, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
                    elevation: 8,

                    /// 👇 Better Icon Button UI
                    icon: Container(
                      padding: EdgeInsets.all(6.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.r),
                        color: isDark
                            ? Colors.white.withOpacity(.05)
                            : Colors.grey.withOpacity(.1),
                      ),
                      child: Icon(
                        Icons.more_vert,
                        size: 18,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),

                    onSelected: (value) {
                      if (value == "edit") {
                        Get.toNamed(
                          Routes.INCOME_EXPENSE_EDIT,
                          arguments: {
                            "id": item.id,
                            "categoryId": item.categoryId,
                            "amount": item.amount,
                            "description": item.description,
                            "date": item.incomeDate,
                            "receipt": item.receipt,
                          },
                        );
                      } else if (value == "delete") {
                        _showDeleteConfirmation(
                          context,
                          int.tryParse(item.id.toString()) ?? 0,
                        );
                      }
                    },

                    itemBuilder: (context) => [
                      /// ✏️ EDIT
                      PopupMenuItem(
                        value: "edit",
                        child: Row(
                          children: [
                            Icon(
                              Icons.edit_outlined,
                              size: 18,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 10.w),
                            Text(
                              "Modify",
                              style: TextStyle(
                                fontFamily: "BalooBhai2",
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      /// Divider (nice touch)
                      PopupMenuDivider(height: 8.h),

                      /// 🗑 DELETE (Danger Style)
                      PopupMenuItem(
                        value: "delete",
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline,
                              size: 18,
                              color: Colors.redAccent,
                            ),
                            SizedBox(width: 10.w),
                            Text(
                              "Remove",
                              style: TextStyle(
                                fontFamily: "BalooBhai2",
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.redAccent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          /// ================= ATTACHMENT =================
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
        ],
      ),
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
            /// Handle bar
            Container(
              height: 4,
              width: 50,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey.withOpacity(.3),
              ),
            ),

            /// Icon (Danger feel)
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

            /// Title
            Text(
              "Remove Record?",
              style: TextStyle(
                fontFamily: "BalooBhai2",
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            /// Subtitle
            Text(
              "This action cannot be undone.\nAre you sure you want to Remove this income?",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: "BalooBhai2",
                fontSize: 13,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 22),

            /// Buttons Row
            Row(
              children: [
                /// Cancel Button
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

                /// Delete Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Get.back(); // close sheet

                      await controller.deleteIncome(id);

                      /// refresh details screen also
                      final detailsController =
                          Get.find<IncomeExpenseDetailsController>();
                      detailsController.fetchIncome();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      "Remove",
                      style: TextStyle(
                        fontFamily: "BalooBhai2",
                        color: Colors.white,
                      ),
                    ),
                  ),
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


}

Color adaptiveSurface(BuildContext context) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;

  return isDark
      ? Colors.white.withOpacity(.05)
      : theme.colorScheme.surfaceVariant;
}
