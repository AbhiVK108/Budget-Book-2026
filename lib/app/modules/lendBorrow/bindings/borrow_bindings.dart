import 'package:budgetbook_2026/app/modules/lendBorrow/controllers/borrow_controller.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';

class BorrowBindings extends Bindings {
  @override
  void dependencies() {
      Get.lazyPut<BorrowController>(() => BorrowController());
  }
  
}