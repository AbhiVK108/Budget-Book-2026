import 'package:budgetbook_2026/app/data/repositories/lend_repo.dart';
import 'package:budgetbook_2026/app/modules/lendBorrow/controllers/lend_controller.dart';
import 'package:get/get.dart';

class PostLendController extends GetxController {
  final LendRepository _repo = LendRepository();

  final isLoading = false.obs;

  Future<void> createLend({
    required String givenTo,
    required String amount,
    required String givenDate,
    required String rateOfInterest,
    required String returnDate,
    String? description,
    String? receiptPath,
  }) async {
    try {
      isLoading.value = true;

      final success = await _repo.createLend(
        givenTo: givenTo,
        amount: amount,
        givenDate: givenDate,
        rateOfInterest: rateOfInterest,
        returnDate: returnDate,
        description: description,
        receiptPath: receiptPath,
      );

      if (success) {
        await Get.find<LendController>().fetchLends();

        Get.back(); // 🔥 CLOSE CREATE PAGE

        Get.snackbar("Success", "Credit added successfully");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}