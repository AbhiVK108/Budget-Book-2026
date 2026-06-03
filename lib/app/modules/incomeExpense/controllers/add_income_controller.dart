import 'package:budgetbook_2026/app/data/repositories/income_api_repo.dart';
import 'package:budgetbook_2026/app/modules/incomeExpense/controllers/income_expense_controller.dart';
import 'package:get/get.dart';

class AddIncomeController extends GetxController {
  final IncomeRepository _repo = IncomeRepository();

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

      final success = await _repo.addIncome(
        categoryId: categoryId,
        amount: amount,
        incomeDate: formattedDate,
        description: description,
        receiptPath: receiptPath,
      );

      if (success) {
        Get.back(); // ✅ always works now

        /// 🔥 Refresh parent controller
        Get.find<IncomeExpenseController>().fetchIncome();

        Get.snackbar("Success", "Income added 🎉");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}