import 'package:get/get.dart';

import '../controllers/lend_controller.dart';

class LendBorrowBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LendController>(() => LendController());
  }
}
