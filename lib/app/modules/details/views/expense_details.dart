import 'package:budgetbook_2026/app/core/constant/app_url.dart';
import 'package:budgetbook_2026/app/core/utils/attachment_view_helper.dart';
import 'package:budgetbook_2026/app/core/utils/expansion_tile_helper.dart';
import 'package:budgetbook_2026/app/core/utils/formate_helper.dart';
import 'package:budgetbook_2026/app/data/models/expense_model.dart';
import 'package:budgetbook_2026/app/modules/details/controllers/expense_details_controller.dart';
import 'package:budgetbook_2026/app/modules/incomeExpense/controllers/expense_controller.dart';
import 'package:budgetbook_2026/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ExpenseDetails extends GetView<ExpenseDetailsController> {
  const ExpenseDetails({super.key});

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
        onPressed: () => _showAddExpenseSheet(context),
        backgroundColor: const Color(0xFFFF6B6B),
        label: Text("Insert", style: TextStyle(fontFamily: "BalooBhai2")),
        icon: const Icon(Icons.remove),
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(18.w),
        child: Column(
          children: [
            _expenseSummaryCard(context, isDark),

            /// 🔥 DATE RANGE UI (same as income)
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
                              fontWeight: FontWeight.w600,
                              fontFamily: "BalooBhai2",
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

  // =========================================================
  // ⭐ SUMMARY CARD
  // =========================================================

  Widget _expenseSummaryCard(BuildContext context, bool isDark) {
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
          /// ICON
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFFFF6B6B), Color(0xFFFF9A9A)],
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

          /// TOTAL EXPENSE
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
            "Total ${controller.categoryName} Expense",
            style: TextStyle(
              fontFamily: "BalooBhai2",
              fontSize: 13.sp,
              color: theme.hintColor,
            ),
          ),

          SizedBox(height: 18.h),

          /// FILTERS
          _filterTabs(context),
        ],
      ),
    );
  }

  // =========================================================
  // ⭐ FILTER TABS
  // =========================================================

  Widget _filterTabs(BuildContext context) {
    return Obx(
      () => Row(
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
                      ? const Color(0xFFFF6B6B)
                      : Colors.white.withOpacity(.08),
                ),
                child: Center(
                  child: Text(
                    controller.filters[index],
                    style: TextStyle(
                      fontFamily: "BalooBhai2",
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : null,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // =========================================================
  // ⭐ RECORD LIST
  // =========================================================

  Widget _recordsSection(BuildContext context, bool isDark) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.filteredExpenses.isEmpty) {
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
            itemCount: controller.filteredExpenses.length,
            itemBuilder: (context, index) {
              final item = controller.filteredExpenses[index];
              return _recordTile(context, item, isDark);
            },
          ),
        ],
      );
    });
  }

  // =========================================================
  // ⭐ RECORD TILE
  // =========================================================

  Widget _recordTile(BuildContext context, ExpenseModel item, bool isDark) {
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
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6B6B), Color(0xFFFF9A9A)],
                  ),
                ),
                child: const Icon(
                  Icons.arrow_upward,
                  color: Colors.white,
                  size: 18,
                ),
              ),

              SizedBox(width: 12.w),

              /// TEXT
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "-${FormatHelper.formatINR(amount)}",
                      style: TextStyle(
                        fontFamily: "BalooBhai2",
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                        color: Colors.redAccent,
                      ),
                    ),
                    SizedBox(height: 4.h),

                    /// DESCRIPTION
                    ExpandableText(
                      text: (item.description ?? "").isNotEmpty
                          ? item.description!
                          : "N/A",
                    ),
                  ],
                ),
              ),

              /// DATE + MENU
              Column(
                children: [
                  Text(
                    controller.formatDate(item.expenseDate),
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

                    /// ICON STYLE (same as income)
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
                          Routes.ExpenseEditView,
                          arguments: {
                            "id": item.id,
                            "categoryId": item.categoryId,
                            "amount": item.amount,
                            "description": item.description,
                            "date": item.expenseDate,
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
                              color: Colors.orange,
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

                      PopupMenuDivider(height: 8.h),

                      /// 🗑 DELETE
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
  // =========================================================
  // ⭐ DELETE SHEET
  // =========================================================

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
            /// Handle
            Container(
              height: 4,
              width: 50,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey.withOpacity(.3),
              ),
            ),

            /// Icon
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

            Text(
              "Remove Expense?",
              style: TextStyle(
                fontFamily: "BalooBhai2",
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              "This action cannot be undone.\nAre you sure?",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: "BalooBhai2",
                fontSize: 13,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 22),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    child: const Text("Cancel"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Get.back();
                      await controller.deleteExpense(id);

                      final mainController = Get.find<ExpenseController>();

                      mainController.removeExpenseLocally(id); // instant UI
                      mainController.fetchExpense();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text("Remove"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}

/// SAME AS INCOME
Color adaptiveSurface(BuildContext context) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;

  return isDark
      ? Colors.white.withOpacity(.05)
      : theme.colorScheme.surfaceVariant;
}

void _showAddExpenseSheet(BuildContext context) {
  final amountController = TextEditingController();
  final noteController = TextEditingController();

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  Get.bottomSheet(
    StatefulBuilder(
      builder: (context, setState) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            color: Theme.of(context).colorScheme.surface,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Add Expense"),

              const SizedBox(height: 12),

              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: "Amount"),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: noteController,
                decoration: const InputDecoration(hintText: "Description"),
              ),

              const SizedBox(height: 10),

              ElevatedButton(
                onPressed: () async {
                  /// 👉 Later connect API here
                  Get.back();
                },
                child: const Text("Submit"),
              ),
            ],
          ),
        );
      },
    ),
    isScrollControlled: true,
  );
}
