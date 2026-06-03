import 'package:budgetbook_2026/app/core/constant/app_url.dart';
import 'package:budgetbook_2026/app/core/utils/attachment_view_helper.dart';
import 'package:budgetbook_2026/app/core/utils/expansion_tile_helper.dart';
import 'package:budgetbook_2026/app/modules/incomeExpense/controllers/expense_controller.dart';
import 'package:budgetbook_2026/app/modules/incomeExpense/views/income.dart';
import 'package:budgetbook_2026/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class Expense extends GetView<ExpenseController> {
  const Expense({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _addExpenseFAB(),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10.h),

              _topBar(),

              SizedBox(height: 24.h),

              _heroExpenseCard(),

              SizedBox(height: 26.h),

              expenseCategoriesSection(context),

              SizedBox(height: 26.h),

              recentExpenseHistory(context),

              SizedBox(height: 80.h),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _topBar() {
  return Row(
    children: [
      IconButton(
        onPressed: () => Get.back(),
        icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20.sp),
      ),
      SizedBox(width: 6.w),
      Text(
        "Expense",
        style: TextStyle(
          fontFamily: "BalooBhai2",
          fontSize: 22.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  );
}

Widget _heroExpenseCard() {
  final controller = Get.find<ExpenseController>();

  return Obx(
    () => Container(
      padding: EdgeInsets.all(18.w),
      height: 260.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26.r),
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B6B), Color(0xFFFF9A9A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ////////////////////////////////////////////////////////////
          /// 🔥 TITLE + TREND
          ////////////////////////////////////////////////////////////
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total Expense",
                style: TextStyle(
                  fontFamily: "BalooBhai2",
                  fontSize: 14.sp,
                  color: Colors.white70,
                ),
              ),

              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.r),
                  color: Colors.white.withOpacity(.20),
                ),
                child: Obx(() {
                  final percent = controller.expenseTrendPercent;
                  final growing = controller.isExpenseGrowing;

                  String period = "";

                  switch (controller.selectedFilter.value) {
                    case "Week":
                      period = "vs last week";
                      break;
                    case "Month":
                      period = "vs last month";
                      break;
                  }

                  return Text(
                    "${growing ? '▲' : '▼'} ${percent.abs().toStringAsFixed(1)}% ${period}",
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontFamily: "BalooBhai2",
                      color: growing ? Colors.redAccent : Colors.greenAccent,
                    ),
                  );
                }),
              ),
            ],
          ),

          SizedBox(height: 6.h),

          ////////////////////////////////////////////////////////////
          /// 🔥 TOTAL AMOUNT
          ////////////////////////////////////////////////////////////
          Row(
            children: [
              Text(
                controller.formatIndianAmount(controller.filteredTotalExpense),
                style: TextStyle(
                  fontFamily: "BalooBhai2",
                  fontSize: 26.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              SizedBox(width: 6.w),

              Text(
                "(${formatFullIndianAmount(controller.filteredTotalExpense)})",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontFamily: "BalooBhai2",
                  color: Colors.white70,
                ),
              ),
            ],
          ),

          SizedBox(height: 14.h),

          ////////////////////////////////////////////////////////////
          /// 🔥 FILTERS
          ////////////////////////////////////////////////////////////
          Row(
            children: [
              _expenseFilterChip("All", controller),
              _expenseFilterChip("Week", controller),
              _expenseFilterChip("Month", controller),
            ],
          ),

          SizedBox(height: 14.h),

          ////////////////////////////////////////////////////////////
          /// 🔥 CHART (SAME AS INCOME)
          ////////////////////////////////////////////////////////////
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 1, color: Colors.white.withOpacity(.25)),
                SizedBox(height: 8.h),

                Expanded(
                  child: Obx(() {
                    final rawData = controller.chartData;

                    /// 🔥 FIX ORDER (same as income)
                    final data = controller.selectedFilter.value == "All"
                        ? Map.fromEntries(rawData.entries.toList().reversed)
                        : rawData;

                    final maxValue = controller.maxChartValue;

                    if (data.isEmpty) {
                      return SizedBox(
                        height: 120,
                        child: Center(child: Text("No data")),
                      );
                    }

                    const maxBarHeight = 45.0;

                    return SizedBox(
                      height: 120,
                      child: controller.selectedFilter.value == "All"
                          ? SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: data.entries
                                    .toList()
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                      final index = entry.key;
                                      final label = entry.value.key;
                                      final value = entry.value.value;

                                      final height = maxValue == 0
                                          ? 0
                                          : (value / maxValue) * 45;

                                      return Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8.w,
                                        ),
                                        child: SizedBox(
                                          width: 30.w, // 🔥 IMPORTANT
                                          child: _expenseBar(
                                            index,
                                            label,
                                            value,
                                            height.toDouble(),
                                          ),
                                        ),
                                      );
                                    })
                                    .toList(),
                              ),
                            )
                          /// 🔥 WEEK / MONTH → Full width
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: _buildExpenseBars(
                                data,
                                maxValue,
                                maxBarHeight,
                                controller,
                                useExpanded: true,
                              ),
                            ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _expenseBar(int index, String label, double amount, double height) {
  final controller = Get.find<ExpenseController>();

  return GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: () {
      controller.selectedBarIndex.value = index;
    },
    child: Container(
      height: double.infinity,
      alignment: Alignment.bottomCenter,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          /// 🔹 BAR + LABEL
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: height.clamp(6.0, 45.0).toDouble(),
                width: 12,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),

              SizedBox(height: 8.h),

              /// 🔥 LABEL (THIS FIXES MULTILINE)
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontFamily: "BalooBhai2",
                  color: Colors.white70,
                ),
              ),
            ],
          ),

          /// 🔥 TOOLTIP
          Obx(
            () => controller.selectedBarIndex.value == index
                ? Positioned(
                    bottom: height + 30,
                    child: Material(
                      color: Colors.transparent,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          controller.formatIndianAmount(amount),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontFamily: "BalooBhai2",
                          ),
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    ),
  );
}

List<Widget> _buildExpenseBars(
  Map<String, double> data,
  double maxValue,
  double maxBarHeight,
  ExpenseController controller, {
  bool useExpanded = false,
}) {
  return data.entries.toList().asMap().entries.map((entry) {
    final index = entry.key;
    final label = entry.value.key;
    final amount = entry.value.value;

    final height = maxValue == 0 ? 0 : (amount / maxValue) * maxBarHeight;

    Widget bar = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        controller.selectedBarIndex.value = index;
      },
      child: Container(
        height: double.infinity,
        alignment: Alignment.bottomCenter,
        child: Stack(
          alignment: Alignment.bottomCenter,
          clipBehavior: Clip.none, // 🔥 IMPORTANT
          children: [
            /// BAR + LABEL
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: height.clamp(6.0, maxBarHeight).toDouble(),
                  width: 12,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),

                SizedBox(height: 8.h),

                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10.sp, color: Colors.white70),
                ),
              ],
            ),

            /// 🔥 TOOLTIP
            Obx(
              () => controller.selectedBarIndex.value == index
                  ? Positioned(
                      bottom: height + 30,
                      child: Material(
                        color: Colors.transparent,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            controller.formatIndianAmount(amount),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );

    /// 🔥 LAYOUT CONTROL
    if (useExpanded) {
      return Expanded(child: bar);
    } else {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: SizedBox(width: 40.w, child: bar),
      );
    }
  }).toList();
}

Widget _expenseFilterChip(String title, ExpenseController controller) {
  return Obx(() {
    final active = controller.selectedFilter.value == title;

    return GestureDetector(
      onTap: () {
        controller.selectedFilter.value = title;
        controller.selectedBarIndex.value = -1;
      },
      child: Container(
        margin: EdgeInsets.only(right: 10.w),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          color: active ? Colors.white : Colors.white.withOpacity(.25),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12.sp,
            color: active ? Colors.black : Colors.white,
          ),
        ),
      ),
    );
  });
}

Widget expenseCategoriesSection(BuildContext context) {
  final controller = Get.find<ExpenseController>();

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      sectionTitle("Expense Categories", ""),

      SizedBox(height: 12.h),

      Obx(() {
        final totals = controller.categoryTotals;
        final categories = totals.keys.toList();
        final imageMap = controller.categoryImages; // 👈 ADD THIS IN CONTROLLER

        if (categories.isEmpty) {
          return const Center(child: Text("No expense data"));
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: categories.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
            childAspectRatio: 1.0,
          ),
          itemBuilder: (_, index) {
            final name = categories[index];
            final amount = totals[name] ?? 0;
            final imagePath = imageMap[name] ?? "";

            return GestureDetector(
              onTap: () {
                Get.toNamed(
                  Routes.ExpenseDetails,
                  arguments: {
                    "category": name, // 👈 pass category name
                    "image": imagePath,
                  },
                );
              },
              child: Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18.r),
                  color: adaptiveSurface(context),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //////////////////////////////////////////////////////
                    /// 🔥 GRADIENT ICON BADGE (EXPENSE STYLE)
                    //////////////////////////////////////////////////////
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFFF6B6B), // 🔴 expense primary
                            Color(0xFFFF9A9A), // 🔴 light
                          ],
                        ),
                      ),
                      child: ClipOval(
                        child: imagePath.isNotEmpty
                            ? Image.network(
                                AppUrl.getImageUrl(imagePath),
                                width: 18.sp,
                                height: 18.sp,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Icon(
                                  Icons.category,
                                  color: Colors.white,
                                  size: 18.sp,
                                ),
                              )
                            : Icon(
                                Icons.category,
                                color: Colors.white,
                                size: 18.sp,
                              ),
                      ),
                    ),

                    SizedBox(height: 6.h),

                    //////////////////////////////////////////////////////
                    /// CATEGORY NAME
                    //////////////////////////////////////////////////////
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: "BalooBhai2",
                        fontSize: 11.sp,
                      ),
                    ),

                    //////////////////////////////////////////////////////
                    /// AMOUNT
                    //////////////////////////////////////////////////////
                    Text(
                      controller.formatIndianAmount(amount),
                      style: TextStyle(
                        fontFamily: "BalooBhai2",
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent, // 🔥 expense color
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    ],
  );
}

Widget recentExpenseHistory(BuildContext context) {
  final controller = Get.find<ExpenseController>();
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      sectionTitle("Recent Expense", ""),

      SizedBox(height: 14.h),

      Obx(() {
        final items = controller.filteredExpenses.take(5).toList();

        if (items.isEmpty) {
          return const Center(child: Text("No recent expense"));
        }

        return Column(
          children: items.map((item) {
            final amount = double.tryParse(item.amount) ?? 0;
            final imagePath = item.categoryImg ?? "";

            return Container(
              margin: EdgeInsets.only(bottom: 12.h),
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18.r),
                color: adaptiveSurface(context),
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //////////////////////////////////////////////////////
                      /// 🔥 ICON (RED THEME)
                      //////////////////////////////////////////////////////
                      Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(10.w),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.r),
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFF6B6B), Color(0xFFFF9A9A)],
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.r),
                              child: imagePath.isNotEmpty
                                  ? Image.network(
                                      AppUrl.getImageUrl(imagePath),
                                      width: 20.sp,
                                      height: 20.sp,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Icon(
                                        Icons.remove,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.remove,
                                      color: Colors.white,
                                    ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(width: 12.w),

                      //////////////////////////////////////////////////////
                      /// 🔥 CENTER CONTENT
                      //////////////////////////////////////////////////////
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// CATEGORY
                            Text(
                              item.categoryName,
                              style: TextStyle(
                                fontFamily: "BalooBhai2",
                                fontWeight: FontWeight.w600,
                                fontSize: 13.sp,
                              ),
                            ),

                            SizedBox(height: 2.h),

                            /// DESCRIPTION (Expandable)
                            if (item.description.isNotEmpty)
                              ExpandableText(text: item.description),
                          ],
                        ),
                      ),

                      SizedBox(width: 8.w),

                      //////////////////////////////////////////////////////
                      /// 🔥 RIGHT SIDE (DATE + AMOUNT)
                      //////////////////////////////////////////////////////
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          /// DATE
                          Text(
                            formatDate(item.expenseDate.toString()),
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontFamily: "BalooBhai2",
                              fontWeight: FontWeight.w600,
                              color: Colors.grey,
                            ),
                          ),

                          SizedBox(height: 6.h),

                          /// AMOUNT (NEGATIVE)
                          Text(
                            "-${controller.formatIndianAmount(amount)}",
                            style: TextStyle(
                              fontFamily: "BalooBhai2",
                              fontWeight: FontWeight.bold,
                              fontSize: 14.sp,
                              color: Colors.redAccent,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  //////////////////////////////////////////////////////
                  /// 🔥 ATTACHMENT (OPTIONAL)
                  //////////////////////////////////////////////////////
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
                            color: Colors.redAccent,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            "View Attachment",
                            style: TextStyle(
                              fontFamily: "BalooBhai2",
                              fontSize: 12.sp,
                              color: Colors.redAccent,
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
          }).toList(),
        );
      }),
    ],
  );
}

Widget sectionTitle(String title, String action) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        title,
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          fontFamily: "BalooBhai2",
        ),
      ),
      Text(
        action,
        style: TextStyle(
          color: Colors.teal,
          fontSize: 12.sp,
          fontFamily: "BalooBhai2",
        ),
      ),
    ],
  );
}

Color adaptiveSurface(BuildContext context) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;

  return isDark
      ? Colors.white.withOpacity(.05)
      : theme.colorScheme.surfaceVariant;
}

Widget _addExpenseFAB() {
  return FloatingActionButton.extended(
    onPressed: () {
      Get.toNamed(Routes.ADD_EXPENSE);
    },
    backgroundColor: const Color(0xFFFF6B6B),
    icon: const Icon(Icons.remove),
    label: Text("Expense", style: TextStyle(fontFamily: "BalooBhai2")),
  );
}
