import 'package:budgetbook_2026/app/modules/chit_funds/controllers/edit_chit_funds_controller.dart';
import 'package:get/get.dart';

class EditChitFundsBinding extends Bindings {
  @override
  void dependencies() {
  Get.lazyPut<EditChitFundsController>(() => EditChitFundsController());
  }
  
}