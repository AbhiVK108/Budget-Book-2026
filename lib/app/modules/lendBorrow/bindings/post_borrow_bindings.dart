import 'package:budgetbook_2026/app/modules/lendBorrow/controllers/post_borrow_controller.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';

class PostBorrowBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PostBorrowController>(() => PostBorrowController());
  }
  
}