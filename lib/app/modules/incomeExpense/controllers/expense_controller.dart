import 'package:budgetbook_2026/app/data/models/category_model.dart';
import 'package:budgetbook_2026/app/data/models/expense_model.dart';
import 'package:budgetbook_2026/app/data/repositories/category_repo.dart';
import 'package:budgetbook_2026/app/data/repositories/expense_repo.dart';
import 'package:get/get.dart';

class ExpenseController extends GetxController {
  final ExpenseRepository _repo = ExpenseRepository();
  final CategoryRepo _categoryRepo = CategoryRepo();

  ////////////////////////////////////////////////////////////
  /// STATE
  ////////////////////////////////////////////////////////////

  final expenses = <ExpenseModel>[].obs;
  final totalExpense = 0.0.obs;
  final isLoading = false.obs;
  final selectedFilter = "All".obs;

  ////////////////////////////////////////////////////////////
  /// FETCH
  ////////////////////////////////////////////////////////////

  Future<void> fetchExpense() async {
    try {
      isLoading.value = true;

      final response = await _repo.getExpense();

      expenses.value = response.data;
      totalExpense.value = response.totalAmount;
    } catch (e) {
      Get.snackbar("Error", "Failed to load expense");
    } finally {
      isLoading.value = false;
    }
  }

  ////////////////////////////////////////////////////////////
  /// ADD EXPENSE
  ////////////////////////////////////////////////////////////

  Future<void> addExpense({
    required int categoryId,
    required String amount,
    required DateTime date,
    String? description,
    String? receiptPath,
  }) async {
    try {
      isLoading.value = true;

      final formattedDate =
          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} "
          "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:00";

      final success = await _repo.addExpense(
        categoryId: categoryId,
        amount: amount,
        expenseDate: formattedDate,
        description: description,
        receiptPath: receiptPath,
      );

      if (success) {
        Get.snackbar("Success", "Expense added 🎉");
        await fetchExpense();
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  ////////////////////////////////////////////////////////////
  /// DELETE
  ////////////////////////////////////////////////////////////

  Future<void> deleteExpense(int id) async {
    try {
      isLoading.value = true;

      final success = await _repo.deleteExpense(id);

      if (success) {
        await fetchExpense();
        Get.snackbar("Success", "Expense deleted");
      }
    } finally {
      isLoading.value = false;
    }
  }

  ////////////////////////////////////////////////////////////
  /// FILTERED
  ////////////////////////////////////////////////////////////

  List<ExpenseModel> get filteredExpenses {
    final now = DateTime.now();

    if (selectedFilter.value == "Week") {
      return expenses
          .where((e) => now.difference(e.expenseDate).inDays <= 7)
          .toList();
    }

    if (selectedFilter.value == "Month") {
      return expenses
          .where(
            (e) =>
                now.month == e.expenseDate.month &&
                now.year == e.expenseDate.year,
          )
          .toList();
    }

    return expenses;
  }

  ////////////////////////////////////////////////////////////
  /// CATEGORY TOTALS
  ////////////////////////////////////////////////////////////

  Map<String, double> get categoryTotals {
    final map = <String, double>{};

    for (var item in filteredExpenses) {
      final amount = double.tryParse(item.amount) ?? 0;

      map[item.categoryName] = (map[item.categoryName] ?? 0) + amount;
    }

    return map;
  }

  // Category Images
  Map<String, String> get categoryImages {
    final map = <String, String>{};

    for (var item in expenseCategories) {
      map[item.name] = item.image;
    }

    return map;
  }

  ////////////////////////////////////////////////////////////
  /// FETCH EXPENSE CATEGORIES
  ////////////////////////////////////////////////////////////

  final expenseCategories = <CategoryModel>[].obs;

  Future<void> fetchExpenseCategories() async {
    try {
      final response = await _categoryRepo.getCategories();

      expenseCategories.value = response.data
          .where((c) => c.type == "Expense") // 🔥 KEY DIFFERENCE
          .toList();
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  ////////////////////////////////////////////////////////////
  /// UI LOGIC
  final selectedBarIndex = (-1).obs;
  double get filteredTotalExpense {
    double sum = 0;

    for (var item in filteredExpenses) {
      sum += double.tryParse(item.amount) ?? 0;
    }

    return sum;
  }

  void removeExpenseLocally(int id) {
    expenses.removeWhere((e) => e.id == id);
  }

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

  Map<String, double> get chartData {
    final Map<String, double> data = {};
    final now = DateTime.now();

    /// WEEK
    if (selectedFilter.value == "Week") {
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

      const weekLabels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

      for (int i = 0; i < 7; i++) {
        final day = startOfWeek.add(Duration(days: i));

        data[weekLabels[i]] = filteredExpenses
            .where(
              (e) =>
                  e.expenseDate.day == day.day &&
                  e.expenseDate.month == day.month &&
                  e.expenseDate.year == day.year,
            )
            .fold(0.0, (sum, e) => sum + (double.tryParse(e.amount) ?? 0));
      }

      return data;
    }

    /// MONTH (W1–W5)
    if (selectedFilter.value == "Month") {
      final daysInMonth = DateTime(now.year, now.month + 1, 0).day;

      for (int week = 1; week <= 5; week++) {
        final startDay = (week - 1) * 7 + 1;
        final endDay = (week * 7).clamp(1, daysInMonth);

        if (startDay > daysInMonth) break;

        data["Week $week"] = filteredExpenses
            .where(
              (e) =>
                  e.expenseDate.day >= startDay && e.expenseDate.day <= endDay,
            )
            .fold(0.0, (sum, e) => sum + (double.tryParse(e.amount) ?? 0));
      }

      return data;
    }

    /// ALL → MONTH GROUP
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

      for (var item in filteredExpenses) {
        final date = DateTime(item.expenseDate.year, item.expenseDate.month);

        final amount = double.tryParse(item.amount) ?? 0;

        temp[date] = (temp[date] ?? 0) + amount;
      }

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

  double get maxChartValue {
    if (chartData.isEmpty) return 0;
    return chartData.values.reduce((a, b) => a > b ? a : b);
  }

  double get previousPeriodTotal {
    final now = DateTime.now();
    List<ExpenseModel> previous = [];

    if (selectedFilter.value == "Week") {
      previous = expenses
          .where(
            (e) =>
                now.difference(e.expenseDate).inDays > 7 &&
                now.difference(e.expenseDate).inDays <= 14,
          )
          .toList();
    }

    if (selectedFilter.value == "Month") {
      final lastMonth = DateTime(now.year, now.month - 1);

      previous = expenses
          .where(
            (e) =>
                e.expenseDate.month == lastMonth.month &&
                e.expenseDate.year == lastMonth.year,
          )
          .toList();
    }

    if (selectedFilter.value == "All") return 0;

    return previous.fold(
      0.0,
      (sum, e) => sum + (double.tryParse(e.amount) ?? 0),
    );
  }

  double get expenseTrendPercent {
    final prev = previousPeriodTotal;
    final current = filteredTotalExpense;

    if (prev == 0) return 0;

    return ((current - prev) / prev) * 100;
  }

  bool get isExpenseGrowing => expenseTrendPercent >= 0;

  void changeFilter(String value) {
    selectedFilter.value = value;
  }

  @override
  void onInit() {
    fetchExpense();
    fetchExpenseCategories();
    super.onInit();
  }
}
