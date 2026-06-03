import 'package:get/get.dart';

import '../controllers/lend_borrow_edit_controller.dart';

class LendBorrowEditBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LendBorrowEditController>(() => LendBorrowEditController());
  }
}
