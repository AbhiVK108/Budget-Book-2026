import 'package:budgetbook_2026/app/modules/details/controllers/expense_details_controller.dart';
import 'package:get/get.dart';

class ExpenseDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ExpenseDetailsController>(() => ExpenseDetailsController());
  }
}
