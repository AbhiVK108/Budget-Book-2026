import 'package:budgetbook_2026/app/data/models/income_model.dart';
import 'package:budgetbook_2026/app/data/repositories/income_api_repo.dart';
import 'package:budgetbook_2026/app/modules/incomeExpense/controllers/income_expense_controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class IncomeExpenseDetailsController extends GetxController {
  final IncomeRepository _repo = IncomeRepository();

  var selectedFilter = 0.obs;

  final filters = ["All", "7 Days", "This Month", "Custom"];

  final isLoading = false.obs;

  final incomes = <IncomeModel>[].obs;
  final filteredIncomes = <IncomeModel>[].obs;

  DateTime? startDate;
  DateTime? endDate;

  late String categoryName;
  String categoryImage = "";

  @override
  void onInit() {
    super.onInit();

    categoryName = Get.arguments?["category"] ?? "";
    categoryImage = Get.arguments?["image"] ?? "";

   ever(selectedFilter, (_) => applyFilter()); 
    fetchIncome();
  }

  Future<void> fetchIncome() async {
    try {
      isLoading.value = true;

      final mainController = Get.find<IncomeExpenseController>();
      await mainController.fetchIncome();

      incomes.assignAll(mainController.incomes);

      applyFilter(); // 🔥 IMPORTANT
    } catch (e) {
      Get.snackbar("Error", "Failed to load income");
    } finally {
      isLoading.value = false;
    }
  }

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

  // 🔥 MAIN FILTER ENGINE
  void applyFilter() {
    final now = DateTime.now();

    List<IncomeModel> baseList = incomes
        .where(
          (e) => e.categoryName.toLowerCase() == categoryName.toLowerCase(),
        )
        .toList();

    switch (selectedFilter.value) {
      case 0: // ALL
        filteredIncomes.value = baseList;
        break;

      case 1: // WEEKLY
        final weekAgo = now.subtract(const Duration(days: 7));

        filteredIncomes.value = baseList.where((e) {
          return e.incomeDate.isAfter(weekAgo);
        }).toList();
        break;

      case 2: // MONTHLY
        filteredIncomes.value = baseList.where((e) {
          return e.incomeDate.month == now.month &&
              e.incomeDate.year == now.year;
        }).toList();
        break;

      case 3: // CUSTOM
        if (startDate != null && endDate != null) {
          filteredIncomes.value = baseList.where((e) {
            return e.incomeDate.isAfter(
                  startDate!.subtract(const Duration(days: 1)),
                ) &&
                e.incomeDate.isBefore(endDate!.add(const Duration(days: 1)));
          }).toList();
        }
        break;
    }
  }

  // 🔥 RESET FILTER (VERY IMPORTANT UX)
  void clearFilter() {
    selectedFilter.value = 0;
    startDate = null;
    endDate = null;
    applyFilter();
  }

  double get totalAmount => filteredIncomes.fold(
    0,
    (sum, e) => sum + (double.tryParse(e.amount) ?? 0),
  );

  String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }
}
