import 'package:budgetbook_2026/app/data/repositories/expense_repo.dart';
import 'package:budgetbook_2026/app/modules/incomeExpense/controllers/expense_controller.dart';
import 'package:get/get.dart';

class AddExpenseController extends GetxController {
  final ExpenseRepository _repo = ExpenseRepository();

  final isLoading = false.obs;

  Future<void> submit({
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
        Get.back();

        /// 🔥 refresh expense list
        Get.find<ExpenseController>().fetchExpense();

        Get.snackbar("Success", "Expense added 💸");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}