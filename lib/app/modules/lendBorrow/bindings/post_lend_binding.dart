import 'package:budgetbook_2026/app/modules/lendBorrow/controllers/post_lend_controller.dart';
import 'package:get/get.dart';

class PostLendBinding extends Bindings {
  @override
    void dependencies() {
    Get.lazyPut<PostLendController>(() => PostLendController());
  }
  
}