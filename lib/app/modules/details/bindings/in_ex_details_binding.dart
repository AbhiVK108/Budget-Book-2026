import 'package:get/get.dart';

import '../controllers/in_ex_details_controller.dart';

class IncomeExpDetailsController extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<IncomeExpenseDetailsController>(
      () => IncomeExpenseDetailsController(),
    );
  }
}
