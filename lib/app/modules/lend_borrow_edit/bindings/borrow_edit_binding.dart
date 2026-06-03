import 'package:budgetbook_2026/app/modules/lend_borrow_edit/controllers/borrow_edit_controller.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/route_manager.dart';

class BorrowEditBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BorrowEditController>(() => BorrowEditController());
  }
}
