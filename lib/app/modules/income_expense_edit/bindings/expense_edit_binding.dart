import 'package:budgetbook_2026/app/modules/income_expense_edit/controllers/expense_edit_controller.dart';
import 'package:get/get.dart';

class ExpenseEditBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ExpenseEditController());
  }
}
