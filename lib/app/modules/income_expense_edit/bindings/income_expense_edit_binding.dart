import 'package:get/get.dart';

import '../controllers/income_expense_edit_controller.dart';

class IncomeExpenseEditBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<IncomeExpenseEditController>(
      () => IncomeExpenseEditController(),
    );
  }
}
