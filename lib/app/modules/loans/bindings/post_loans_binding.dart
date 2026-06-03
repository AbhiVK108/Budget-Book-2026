import 'package:budgetbook_2026/app/modules/loans/controllers/post_loan_controller.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';

class PostLoansBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PostLoanController>(() => PostLoanController());
  }
  
}