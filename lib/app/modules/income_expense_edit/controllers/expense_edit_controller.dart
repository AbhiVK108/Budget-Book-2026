import 'package:budgetbook_2026/app/data/models/category_model.dart';
import 'package:budgetbook_2026/app/data/repositories/category_repo.dart';
import 'package:budgetbook_2026/app/data/repositories/expense_repo.dart';
import 'package:budgetbook_2026/app/modules/details/controllers/expense_details_controller.dart';
import 'package:budgetbook_2026/app/modules/incomeExpense/controllers/expense_controller.dart';
import 'package:get/get.dart';

class ExpenseEditController extends GetxController {
  final ExpenseRepository _repo = ExpenseRepository();
  final CategoryRepo _categoryRepo = CategoryRepo();

  final isLoading = false.obs;

  /// ================= UPDATE EXPENSE =================
  Future<void> submit({
    required int id,
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

      final success = await _repo.updateExpense(
        id: id,
        categoryId: categoryId,
        amount: amount,
        expenseDate: formattedDate,
        description: description,
        receiptPath: receiptPath,
      );

      if (success) {
        /// Refresh list
        final controller = Get.find<ExpenseController>();
        await controller.fetchExpense();

        /// Refresh details screen
        final detailsController = Get.find<ExpenseDetailsController>();
        detailsController.fetchExpense();

        Get.back();
        Get.snackbar("Success", "Expense updated 💸");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// ================= CATEGORY =================
  final RxList<CategoryModel> expenseCategories = <CategoryModel>[].obs;
  final RxBool isLoadingCategories = false.obs;
  final RxInt selectedCategoryIndex = (-1).obs;

  Future<void> fetchExpenseCategories(int initialCategoryId) async {
    try {
      isLoadingCategories.value = true;

      final response = await _categoryRepo.getCategories();

      final filtered =
          response.data.where((c) => c.type == "Expense").toList();

      expenseCategories.value = filtered;

      /// ✅ PRESELECT
      final index =
          expenseCategories.indexWhere((c) => c.id == initialCategoryId);

      if (index != -1) {
        selectedCategoryIndex.value = index;
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoadingCategories.value = false;
    }
  }
}