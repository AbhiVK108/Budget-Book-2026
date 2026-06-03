import 'package:get/get.dart';

import '../controllers/chit_funds_controller.dart';

class ChitFundsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChitFundsController>(
      () => ChitFundsController(),
    );
  }
}
