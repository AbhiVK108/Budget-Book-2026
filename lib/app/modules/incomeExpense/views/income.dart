import 'package:budgetbook_2026/app/core/constant/app_url.dart';
import 'package:budgetbook_2026/app/core/theme/app_colors.dart';
import 'package:budgetbook_2026/app/core/utils/attachment_view_helper.dart';
import 'package:budgetbook_2026/app/core/utils/expansion_tile_helper.dart';
import 'package:budgetbook_2026/app/modules/details/controllers/in_ex_details_controller.dart';
import 'package:budgetbook_2026/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/income_expense_controller.dart';

class IncomeExpenseView extends GetView<IncomeExpenseController> {
  const IncomeExpenseView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      floatingActionButton: addIncomeFAB(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10.h),

              _topBar(),

              SizedBox(height: 24.h),

              _heroAnalyticsCard(isDark, context),

              SizedBox(height: 26.h),

              incomeSourcesSection(),

              SizedBox(height: 26.h),

              recentHistorySection(context),

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
        "Income",
        style: TextStyle(
          fontFamily: "BalooBhai2",
          fontSize: 22.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  );
}

Widget _heroAnalyticsCard(bool isDark, BuildContext context) {
  final controller = Get.find<IncomeExpenseController>();

  return Obx(
    () => Container(
      padding: EdgeInsets.all(18.w),
      height: 260.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26.r),
        gradient: const LinearGradient(
          colors: [Color(0xFF0FB9B1), Color(0xFF064E4A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Title + Trend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total Income",
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
                  final percent = controller.incomeTrendPercent;
                  final growing = controller.isIncomeGrowing;

                  String period = "";

                  switch (controller.selectedFilter.value) {
                    case "Week":
                      period = "vs last week";
                      break;
                    case "Month":
                      period = "vs last month";
                      break;
                    default:
                      period = "";
                  }

                  return Text(
                    "${growing ? '▲' : '▼'} ${formatTrend(percent, growing)}${period.isNotEmpty ? ' $period' : ''}",
                    style: TextStyle(
                      fontFamily: "BalooBhai2",
                      fontSize: 12.sp,
                      color: growing ? Colors.greenAccent : Colors.redAccent,
                    ),
                  );
                }),
              ),
            ],
          ),

          SizedBox(height: 6.h),

          /// 🔥 REAL TOTAL
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                controller.formatIndianAmount(controller.filteredTotalIncome),
                style: TextStyle(
                  fontFamily: "BalooBhai2",
                  fontSize: 26.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              SizedBox(width: 6.w),

              Text(
                "(${formatFullIndianAmount(controller.filteredTotalIncome)})",
                style: TextStyle(
                  fontFamily: "BalooBhai2",
                  fontSize: 14.sp,
                  color: Colors.white70,
                ),
              ),
            ],
          ),

          SizedBox(height: 14.h),

          /// 🔥 FILTERS (Reactive)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _filterChip("All", controller),
                _filterChip("Week", controller),
                _filterChip("Month", controller),
              ],
            ),
          ),
          SizedBox(height: 14.h),

          /// Chart (unchanged)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 1, color: Colors.white.withOpacity(.25)),
                SizedBox(height: 8.h),

                Expanded(
                  child: Obx(() {
                    final rawData = controller.chartData;

                    final data = controller.selectedFilter.value == "All"
                        ? Map.fromEntries(
                            rawData.entries.toList().reversed,
                          ) // 🔥 FIX
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
                          /// 🔥 ALL → Scrollable + Left Anchored
                          ? SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children:
                                    _buildBars(
                                          data,
                                          maxValue,
                                          maxBarHeight,
                                          controller,
                                          useExpanded: false,
                                        )
                                        .map(
                                          (bar) => Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 8.w,
                                            ), // 👈 spacing fix
                                            child: SizedBox(
                                              width: 40.w,
                                              child: bar,
                                            ), // 👈 fixed width bars
                                          ),
                                        )
                                        .toList(),
                              ),
                            )
                          /// 🔥 WEEK / MONTH → Full Width
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: _buildBars(
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

String formatFullIndianAmount(double amount) {
  final formatter = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  return formatter.format(amount);
}

String formatTrend(double value, bool growing) {
  final absValue = value.abs();

  if (absValue >= 1000) {
    return growing ? "Huge increase" : "Huge drop";
  }

  if (absValue >= 100) {
    return "${absValue.toStringAsFixed(0)}%";
  }

  return "${absValue.toStringAsFixed(1)}%";
}

List<Widget> _buildBars(
  Map<String, double> data,
  double maxValue,
  double maxBarHeight,
  IncomeExpenseController controller, {
  bool useExpanded = false,
}) {
  return data.entries.toList().asMap().entries.map((entry) {
    final index = entry.key;
    final label = entry.value.key;
    final amount = entry.value.value;

    final height = maxValue == 0 ? 0 : (amount / maxValue) * maxBarHeight;

    /// 🔥 MAIN BAR WIDGET
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
          clipBehavior: Clip.none, // 👈 IMPORTANT
          children: [
            /// 🔹 BAR + LABEL (BASE LAYER)
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
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.white70,
                    fontFamily: "BalooBhai2",
                  ),
                ),
              ],
            ),

            /// 🔥 TOOLTIP (TOP LAYER)
            Obx(
              () => controller.selectedBarIndex.value == index
                  ? Positioned(
                      bottom: height + 30, // 👈 spacing above bar
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

    /// 🔥 CONDITIONAL LAYOUT (IMPORTANT)
    if (useExpanded) {
      /// WEEK / MONTH → Equal spacing
      return Expanded(child: bar);
    } else {
      /// ALL → Scrollable with spacing
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: SizedBox(width: 40.w, child: bar),
      );
    }
  }).toList();
}

Widget _filterChip(String title, IncomeExpenseController controller) {
  return Obx(() {
    final active = controller.selectedFilter.value == title;

    return GestureDetector(
      onTap: () => controller.changeFilter(title),
      child: Container(
        margin: EdgeInsets.only(right: 12.w),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          color: active ? Colors.white : Colors.white.withOpacity(.25),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontFamily: "BalooBhai2",
            fontSize: 13.sp,
            color: active ? Colors.black : Colors.white,
          ),
        ),
      ),
    );
  });
}

Widget incomeSourcesSection() {
  final controller = Get.find<IncomeExpenseController>();

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      /// Heading
      sectionTitle("Income Sources", ""),

      SizedBox(height: 12.h),

      Obx(() {
        final totals = controller.categoryTotals;
        final categories = totals.keys.toList();
        final imageMap = controller.categoryImages;

        if (categories.isEmpty) {
          return const Center(child: Text("No income data"));
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
                  Routes.IncomeDetails,
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
                  color: adaptiveSurface(Get.context!),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    /// 🔥 DYNAMIC IMAGE BADGE
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [AppColors.primaryDark, AppColors.secondary],
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
                                  Icons.account_balance_wallet,
                                  color: Colors.white,
                                  size: 18.sp,
                                ),
                              )
                            : Icon(
                                Icons.account_balance_wallet,
                                color: Colors.white,
                                size: 18.sp,
                              ),
                      ),
                    ),

                    SizedBox(height: 6.h),

                    /// CATEGORY NAME
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: "BalooBhai2",
                        fontSize: 11.sp,
                      ),
                    ),

                    /// AMOUNT
                    Text(
                      controller.formatIndianAmount(amount),
                      style: TextStyle(
                        fontFamily: "BalooBhai2",
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
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

Widget recentHistorySection(BuildContext context) {
  final controller = Get.find<IncomeExpenseController>();
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      sectionTitle("Recent Income", ""),

      SizedBox(height: 14.h),

      /// 🔥 REAL DATA FROM CONTROLLER
      Obx(() {
        final items = controller.recentIncomes.take(5).toList();

        if (items.isEmpty) {
          return const Center(child: Text("No recent income"));
        }

        return Column(
          children: items.map((item) {
            final amount = double.tryParse(item.amount) ?? 0;
            final imagePath = item.categoryImg;

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
                      /// 🔥 ICON COLUMN
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
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.r),
                              child: imagePath.isNotEmpty
                                  ? Image.network(
                                      AppUrl.getImageUrl(imagePath),
                                      width: 20.sp,
                                      height: 20.sp,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Icon(
                                        Icons.account_balance_wallet,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.account_balance_wallet,
                                      color: Colors.white,
                                    ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(width: 12.w),

                      /// 🔥 CENTER CONTENT
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// CATEGORY NAME
                            Text(
                              item.categoryName,
                              style: TextStyle(
                                fontFamily: "BalooBhai2",
                                fontWeight: FontWeight.w600,
                                fontSize: 13.sp,
                              ),
                            ),

                            SizedBox(height: 4.h),

                            /// DESCRIPTION
                            if (item.description.isNotEmpty)
                              ExpandableText(text: item.description),
                          ],
                        ),
                      ),

                      SizedBox(width: 8.w),

                      /// 🔥 RIGHT SIDE (DATE TOP, AMOUNT BELOW)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          /// DATE (TOP RIGHT)
                          Text(
                            formatDate(item.incomeDate.toString()),
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontFamily: "BalooBhai2",
                              fontWeight: FontWeight.w600,
                              color: Colors.grey,
                            ),
                          ),

                          SizedBox(height: 6.h),

                          /// AMOUNT (BELOW DATE)
                          Text(
                            "+${controller.formatIndianAmount(amount)}",
                            style: TextStyle(
                              fontFamily: "BalooBhai2",
                              fontWeight: FontWeight.bold,
                              fontSize: 14.sp,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

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
          }).toList(),
        );
      }),
    ],
  );
}

void _showDeleteConfirmation(
  BuildContext context,
  int id,
  IncomeExpenseController controller,
) {
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

String formatDate(String date) {
  try {
    final parsed = DateTime.parse(date);
    return DateFormat('dd MMM yyyy').format(parsed);
  } catch (_) {
    return date;
  }
}

Widget addIncomeFAB() {
  return FloatingActionButton.extended(
    onPressed: () {
      Get.toNamed(Routes.ADD_INCOME);
    },
    backgroundColor: const Color(0xFF0FB9B1),
    icon: const Icon(Icons.add),
    label: Text("Income", style: TextStyle(fontFamily: "BalooBhai2")),
  );
}

IconData iconForCategory(String name) {
  switch (name.toLowerCase()) {
    case "salary":
      return Icons.account_balance_wallet;
    case "business":
      return Icons.storefront;
    case "investments":
      return Icons.trending_up;
    case "rental":
      return Icons.home_work;
    case "food":
      return Icons.fastfood;
    case "sport":
      return Icons.sports_soccer;
    default:
      return Icons.category;
  }
}

List<Color> gradientForCategory(String name) {
  switch (name.toLowerCase()) {
    case "salary":
      return [Color(0xFF4FACFE), Color(0xFF00F2FE)];
    case "business":
      return [Color(0xFF43E97B), Color(0xFF38F9D7)];
    case "investments":
      return [Color(0xFFFF9A9E), Color(0xFFFAD0C4)];
    case "rental":
      return [Color(0xFF667EEA), Color(0xFF764BA2)];
    default:
      return [Color(0xFFFF9966), Color(0xFFFF5E62)];
  }
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

class IncomeTransaction {
  final String title;
  final String date;
  final double amount;
  final IconData icon;
  final List<Color> gradient;

  IncomeTransaction({
    required this.title,
    required this.date,
    required this.amount,
    required this.icon,
    required this.gradient,
  });
}

final List<IncomeTransaction> incomeHistory = [
  IncomeTransaction(
    title: "Salary Credit",
    date: "Today",
    amount: 25000,
    icon: Icons.account_balance_wallet,
    gradient: [Color(0xFF11998E), Color(0xFF38EF7D)],
  ),
  IncomeTransaction(
    title: "Stock Profit",
    date: "Yesterday",
    amount: 2100,
    icon: Icons.show_chart,
    gradient: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
  ),
];
