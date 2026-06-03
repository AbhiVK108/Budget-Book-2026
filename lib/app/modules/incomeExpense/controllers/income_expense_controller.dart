import 'package:budgetbook_2026/app/data/models/category_model.dart';
import 'package:budgetbook_2026/app/data/models/income_model.dart';
import 'package:budgetbook_2026/app/data/repositories/category_repo.dart';
import 'package:budgetbook_2026/app/data/repositories/income_api_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IncomeExpenseController extends GetxController {
  //////////////////////////////////////////////////////////////
  /// REPOSITORY
  //////////////////////////////////////////////////////////////

  final IncomeRepository _repo = IncomeRepository();
  final CategoryRepo _categoryRepo = CategoryRepo();

  //////////////////////////////////////////////////////////////
  /// STATE
  //////////////////////////////////////////////////////////////

  final incomes = <IncomeModel>[].obs;
  final totalIncome = 0.0.obs;
  final isLoading = false.obs;
  final selectedBarIndex = (-1).obs;

  final selectedFilter = "All".obs;

  //////////////////////////////////////////////////////////////
  /// FETCH REAL API DATA
  //////////////////////////////////////////////////////////////

  Future<void> fetchIncome() async {
    try {
      isLoading.value = true;

      final response = await _repo.getIncome();

      incomes.value = response.data;
      totalIncome.value = response.totalAmount;
    } catch (e) {
      Get.snackbar("Error", "Failed to load income");
    } finally {
      isLoading.value = false;
    }
  }

  // Post Income
  Future<void> addIncome({
    required int categoryId,
    required String amount,
    required DateTime date,
    String? description,
    String? receiptPath,
  }) async {
    try {
      debugPrint("📤 [Income] Adding new income...");

      isLoading.value = true;

      final formattedDate =
          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} "
          "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:00";

      /// 🔥 Log request payload
      debugPrint("🧾 [Income] Payload:");
      debugPrint("   Category ID: $categoryId");
      debugPrint("   Amount: $amount");
      debugPrint("   Date: $formattedDate");
      debugPrint("   Description: ${description ?? "None"}");
      debugPrint("   Receipt Path: ${receiptPath ?? "None"}");

      final success = await _repo.addIncome(
        categoryId: categoryId,
        amount: amount,
        incomeDate: formattedDate,
        description: description,
        receiptPath: receiptPath,
      );

      debugPrint("📥 [Income] API result: $success");

      if (success) {
        debugPrint("🎉 [Income] Income added successfully");

        Get.snackbar("Success", "Income added successfully 🎉");

        await fetchIncome(); // refresh list
        /// 🔥 Close bottom sheet safely
        if (Get.isBottomSheetOpen ?? false) {
          Get.back(); // closes sheet only
        }
      } else {
        debugPrint("⚠️ [Income] API returned false");
      }
    } catch (e, stackTrace) {
      debugPrint("❌ [Income] Error adding income: $e");
      debugPrint("🧱 StackTrace: $stackTrace");

      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
      debugPrint("🏁 [Income] Add income process completed");
    }
  }

  // Income Categories
  final RxList<CategoryModel> incomeCategories = <CategoryModel>[].obs;
  final RxBool isLoadingCategories = false.obs;

  Future<void> fetchIncomeCategories() async {
    try {
      debugPrint("📥 [Category] Fetching categories from API...");

      isLoadingCategories.value = true;

      final response = await _categoryRepo.getCategories();

      debugPrint("✅ [Category] API Response Status: ${response.status}");
      debugPrint(
        "📊 [Category] Total categories received: ${response.data.length}",
      );

      /// 🔥 Filter only Income categories
      final filtered = response.data.where((c) => c.type == "Income").toList();

      debugPrint("💰 [Category] Income categories count: ${filtered.length}");

      for (var c in filtered) {
        debugPrint("➡️ Income Category → ID: ${c.id}, Name: ${c.name}");
      }

      incomeCategories.value = filtered;
    } catch (e, stackTrace) {
      debugPrint("❌ [Category] Error fetching categories: $e");
      debugPrint("🧱 StackTrace: $stackTrace");

      Get.snackbar("Error", e.toString());
    } finally {
      isLoadingCategories.value = false;
      debugPrint("🏁 [Category] Fetch process completed");
    }
  }

  // delete Income
  // Income Delete
  final isDeleting = false.obs;

  Future<void> deleteIncome(int id) async {
    try {
      isDeleting.value = true;

      final success = await _repo.deleteIncome(id);

      if (success) {
        await fetchIncome(); // refresh main list

        Get.snackbar("Success", "Income deleted 🎉");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isDeleting.value = false;
    }
  }

  //////////////////////////////////////////////////////////////
  /// FILTERED DATA
  //////////////////////////////////////////////////////////////
  List<IncomeModel> get filteredIncomes {
    final now = DateTime.now();

    if (selectedFilter.value == "Week") {
      return incomes
          .where((e) => now.difference(e.incomeDate).inDays <= 7)
          .toList();
    }

    if (selectedFilter.value == "Month") {
      return incomes
          .where(
            (e) =>
                now.month == e.incomeDate.month &&
                now.year == e.incomeDate.year,
          )
          .toList();
    }

    /// 🔥 ALL
    return incomes;
  }

  double get filteredTotalIncome {
    double sum = 0;

    for (var item in filteredIncomes) {
      sum += double.tryParse(item.amount) ?? 0;
    }

    return sum;
  }

  //////////////////////////////////////////////////////////////
  /// CATEGORY TOTALS (Income Sources Grid)
  //////////////////////////////////////////////////////////////

  Map<String, double> get categoryTotals {
    final map = <String, double>{};

    for (var item in filteredIncomes) {
      final amount = double.tryParse(item.amount) ?? 0;

      map[item.categoryName] = (map[item.categoryName] ?? 0) + amount;
    }

    return map;
  }

  // Income Category Images
  Map<String, String> get categoryImages {
    final map = <String, String>{};

    for (var item in filteredIncomes) {
      // store first image per category
      map[item.categoryName] = item.categoryImg;
    }

    return map;
  }

  //////////////////////////////////////////////////////////////
  /// RECENT INCOME LIST
  //////////////////////////////////////////////////////////////

  List<IncomeModel> get recentIncomes {
    final list = [...filteredIncomes];

    list.sort((a, b) => b.incomeDate.compareTo(a.incomeDate));

    return list.take(5).toList();
  }

  //////////////////////////////////////////////////////////////

  void changeFilter(String value) {
    selectedFilter.value = value;
  }

  //////////////////////////////////////////////////////////////
  ///

  String formatIndianAmount(double amount) {
    if (amount >= 10000000) {
      return "₹${(amount / 10000000).toStringAsFixed(1)}Cr";
    } else if (amount >= 100000) {
      return "₹${(amount / 100000).toStringAsFixed(1)}L";
    } else if (amount >= 1000) {
      return "₹${(amount / 1000).toStringAsFixed(1)}K";
    }
    return "₹${amount.toStringAsFixed(0)}";
  }

  // Chart Bar Filtering
  //////////////////////////////////////////////////////////////
  /// CHART DATA (Smart Grouping)
  //////////////////////////////////////////////////////////////

  Map<String, double> get chartData {
    final Map<String, double> data = {};

    final now = DateTime.now();

    ////////////////////////////////////////////////////////////
    /// WEEK → Mon–Sun
    ////////////////////////////////////////////////////////////

    if (selectedFilter.value == "Week") {
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

      const weekLabels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

      for (int i = 0; i < 7; i++) {
        final day = startOfWeek.add(Duration(days: i));
        final label = weekLabels[i];

        data[label] = filteredIncomes
            .where(
              (e) =>
                  e.incomeDate.day == day.day &&
                  e.incomeDate.month == day.month &&
                  e.incomeDate.year == day.year,
            )
            .fold(0.0, (sum, e) => sum + (double.tryParse(e.amount) ?? 0));
      }

      return data;
    }

    ////////////////////////////////////////////////////////////
    /// MONTH → 1–31
    ////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////
    /// MONTH → GROUP BY WEEK (W1–W5)
    ////////////////////////////////////////////////////////////

    if (selectedFilter.value == "Month") {
      final daysInMonth = DateTime(now.year, now.month + 1, 0).day;

      for (int week = 1; week <= 5; week++) {
        final startDay = (week - 1) * 7 + 1;
        final endDay = (week * 7).clamp(1, daysInMonth);

        if (startDay > daysInMonth) break;

        final label = "Week $week";

        data[label] = filteredIncomes
            .where(
              (e) => e.incomeDate.day >= startDay && e.incomeDate.day <= endDay,
            )
            .fold(0.0, (sum, e) => sum + (double.tryParse(e.amount) ?? 0));
      }

      return data;
    }

    ////////////////////////////////////////////////////////////
    /// ALL → GROUP BY MONTH
    ////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////
    /// ALL → GROUP BY MONTH (Jan, Feb, Mar…)
    ////////////////////////////////////////////////////////////

    if (selectedFilter.value == "All") {
      const monthNames = [
        "Jan",
        "Feb",
        "Mar",
        "Apr",
        "May",
        "Jun",
        "Jul",
        "Aug",
        "Sep",
        "Oct",
        "Nov",
        "Dec",
      ];

      final Map<DateTime, double> temp = {};

      for (var item in filteredIncomes) {
        final date = DateTime(item.incomeDate.year, item.incomeDate.month);

        final amount = double.tryParse(item.amount) ?? 0;

        temp[date] = (temp[date] ?? 0) + amount;
      }

      /// 🔥 SORT BY DATE (NEWEST → OLDEST)
      final sortedKeys = temp.keys.toList()..sort((a, b) => b.compareTo(a));

      final Map<String, double> sortedData = {};

      for (var date in sortedKeys) {
        final label =
            "${monthNames[date.month - 1]} ${date.year.toString().substring(2)}";

        sortedData[label] = temp[date]!;
      }

      return sortedData;
    }

    return data;
  }

  //////////////////////////////////////////////////////////////
  /// MAX VALUE (Used for scaling bar heights)
  //////////////////////////////////////////////////////////////

  double get maxChartValue {
    if (chartData.isEmpty) return 0;

    return chartData.values.reduce((a, b) => a > b ? a : b);
  }

  //////////////////////////////////////////////////////////////
  /// PREVIOUS PERIOD TOTAL
  //////////////////////////////////////////////////////////////

  double get previousPeriodTotal {
    final now = DateTime.now();

    List<IncomeModel> previous = [];

    if (selectedFilter.value == "Week") {
      previous = incomes
          .where(
            (e) =>
                now.difference(e.incomeDate).inDays > 7 &&
                now.difference(e.incomeDate).inDays <= 14,
          )
          .toList();
    }

    if (selectedFilter.value == "Month") {
      final lastMonth = DateTime(now.year, now.month - 1);

      previous = incomes
          .where(
            (e) =>
                e.incomeDate.month == lastMonth.month &&
                e.incomeDate.year == lastMonth.year,
          )
          .toList();
    }

    if (selectedFilter.value == "All") {
      return 0; // no comparison for ALL
    }

    return previous.fold(
      0.0,
      (sum, e) => sum + (double.tryParse(e.amount) ?? 0),
    );
  }

  //////////////////////////////////////////////////////////////
  /// TREND PERCENTAGE
  //////////////////////////////////////////////////////////////

  double get incomeTrendPercent {
    final prev = previousPeriodTotal;
    final current = filteredTotalIncome;

    if (prev == 0) return 0;

    return ((current - prev) / prev) * 100;
  }

  bool get isIncomeGrowing => incomeTrendPercent >= 0;

  @override
  void onInit() {
    fetchIncome(); // 🔥 REAL API CALL
    fetchIncomeCategories();
    super.onInit();
  }
}
