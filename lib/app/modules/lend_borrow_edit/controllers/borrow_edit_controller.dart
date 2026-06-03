import 'package:budgetbook_2026/app/data/repositories/borrow_repo.dart';
import 'package:budgetbook_2026/app/modules/lendBorrow/controllers/borrow_controller.dart';
import 'package:get/get.dart';

class BorrowEditController extends GetxController {
  final BorrowRepository _repo = BorrowRepository();

  final isUpdateLoading = false.obs;

  /// 🔥 UPDATE BORROW
  Future<void> updateBorrow({
    required int id,
    required String receiveFrom,
    required String amount,
    required String receiveDate,
    required String rateOfInterest,
    required String returnDate,
    String? description,
    String? receiptPath,
  }) async {
    try {
      isUpdateLoading.value = true;

      final success = await _repo.updateBorrow(
        id: id,
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

        Future.delayed(const Duration(milliseconds: 200), () {
          Get.snackbar("Success", "Updated successfully");
        });
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isUpdateLoading.value = false;
    }
  }
}