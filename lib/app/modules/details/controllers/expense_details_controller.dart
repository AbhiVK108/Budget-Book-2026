import 'package:budgetbook_2026/app/data/repositories/expense_repo.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:budgetbook_2026/app/data/models/expense_model.dart';

class ExpenseDetailsController extends GetxController {
  final ExpenseRepository _repo = ExpenseRepository();

  /// FILTERS
  var selectedFilter = 0.obs;
  final filters = ["All", "7 Days", "This Month", "Custom"];

  /// STATES
  final isLoading = false.obs;
  final isDeleting = false.obs;

  /// DATA
  final expenses = <ExpenseModel>[].obs;
  final filteredExpenses = <ExpenseModel>[].obs;

  /// DATE RANGE
  DateTime? startDate;
  DateTime? endDate;

  /// CATEGORY
  late String categoryName;
  String categoryImage = "";

  /// TOTAL FROM API (optional use)
  final apiTotalAmount = 0.0.obs;

  @override
  void onInit() {
    super.onInit();

    categoryName = Get.arguments?["category"] ?? "";
    categoryImage = Get.arguments?["image"] ?? "";

    ever(selectedFilter, (_) => applyFilter());

    fetchExpense();
  }

  ////////////////////////////////////////////////////////////
  /// 🔥 FETCH EXPENSE FROM API (UPDATED)
  ////////////////////////////////////////////////////////////
  Future<void> fetchExpense() async {
    try {
      isLoading.value = true;

      final response = await _repo.getExpense();

      /// ✅ store API total (optional)
      apiTotalAmount.value = response.totalAmount ?? 0;

      /// ✅ assign list
      expenses.assignAll(response.data);

      /// ✅ apply filter
      applyFilter();
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  ////////////////////////////////////////////////////////////
  /// 🔥 DELETE
  ////////////////////////////////////////////////////////////
  Future<void> deleteExpense(int id) async {
    try {
      isDeleting.value = true;

      final success = await _repo.deleteExpense(id);

      if (success) {
        await fetchExpense();
        Get.snackbar("Success", "Expense deleted");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isDeleting.value = false;
    }
  }

  ////////////////////////////////////////////////////////////
  /// 🔥 FILTER LOGIC
  ////////////////////////////////////////////////////////////
  void applyFilter() {
    final now = DateTime.now();

    /// ✅ filter by category FIRST
    List<ExpenseModel> baseList = expenses
        .where((e) =>
            (e.categoryName ?? "").toLowerCase() ==
            categoryName.toLowerCase())
        .toList();

    switch (selectedFilter.value) {
      case 0: // ALL
        filteredExpenses.value = baseList;
        break;

      case 1: // 7 DAYS
        final weekAgo = now.subtract(const Duration(days: 7));

        filteredExpenses.value =
            baseList.where((e) => e.expenseDate.isAfter(weekAgo)).toList();
        break;

      case 2: // THIS MONTH
        filteredExpenses.value = baseList.where((e) {
          return e.expenseDate.month == now.month &&
              e.expenseDate.year == now.year;
        }).toList();
        break;

      case 3: // CUSTOM
        if (startDate != null && endDate != null) {
          filteredExpenses.value = baseList.where((e) {
            return e.expenseDate.isAfter(
                  startDate!.subtract(const Duration(days: 1)),
                ) &&
                e.expenseDate.isBefore(
                  endDate!.add(const Duration(days: 1)),
                );
          }).toList();
        }
        break;
    }
  }

  ////////////////////////////////////////////////////////////
  /// 🔥 CLEAR FILTER
  ////////////////////////////////////////////////////////////
  void clearFilter() {
    selectedFilter.value = 0;
    startDate = null;
    endDate = null;
    applyFilter();
  }

  ////////////////////////////////////////////////////////////
  /// 🔥 TOTAL (FILTERED)
  ////////////////////////////////////////////////////////////
  double get totalAmount => filteredExpenses.fold(
        0,
        (sum, e) => sum + (double.tryParse(e.amount ?? "0") ?? 0),
      );

  ////////////////////////////////////////////////////////////
  /// 🔥 FORMAT DATE
  ////////////////////////////////////////////////////////////
  String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }
}