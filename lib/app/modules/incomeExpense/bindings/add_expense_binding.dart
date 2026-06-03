import 'package:budgetbook_2026/app/modules/incomeExpense/controllers/add_expense_controller.dart';
import 'package:get/get.dart';

class AddExpenseBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddExpenseController>(() => AddExpenseController());
  }
}
