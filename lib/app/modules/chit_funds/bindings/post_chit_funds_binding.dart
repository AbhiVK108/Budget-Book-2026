import 'package:budgetbook_2026/app/modules/chit_funds/controllers/post_chit_funds_controller.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/utils.dart';

class PostChitFundsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PostChitFundsController>(() => PostChitFundsController());
  }
  
}