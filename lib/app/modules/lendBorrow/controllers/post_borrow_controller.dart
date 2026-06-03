import 'package:budgetbook_2026/app/data/repositories/borrow_repo.dart';
import 'package:budgetbook_2026/app/modules/lendBorrow/controllers/borrow_controller.dart';
import 'package:get/get.dart';

class PostBorrowController extends GetxController {
  final BorrowRepository _repo = BorrowRepository();

  final isLoading = false.obs;

  Future<void> createBorrow({
    required String receiveFrom,
    required String amount,
    required String receiveDate,
    required String rateOfInterest,
    required String returnDate,
    String? description,
    String? receiptPath,
  }) async {
    try {
      isLoading.value = true;

      final success = await _repo.createBorrow(
        receiveFrom: receiveFrom,
        amount: amount,
        receiveDate: receiveDate,
        rateOfInterest: rateOfInterest,
        returnDate: returnDate,
        description: description,
        receiptPath: receiptPath,
      );

      if (success) {
        await Get.find<BorrowController>().fetchBorrows();

        Get.back();

        Get.snackbar("Success", "Borrow added successfully");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}