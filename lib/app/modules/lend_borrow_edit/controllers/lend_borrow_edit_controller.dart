import 'package:budgetbook_2026/app/data/models/lend_model.dart';
import 'package:budgetbook_2026/app/data/repositories/lend_repo.dart';
import 'package:budgetbook_2026/app/modules/lendBorrow/controllers/lend_controller.dart';
import 'package:get/get.dart';

class LendBorrowEditController extends GetxController {
  final LendRepository _repo = LendRepository();
  final isUpdateLoading = false.obs;
  final isDeleteLoading = false.obs;

  final lendList = <LendModel>[].obs;

  /// 🔥 UPDATE
  Future<void> updateLend({
    required int id,
    required String givenTo,
    required String amount,
    required String givenDate,
    required String rateOfInterest,
    required String returnDate,
    String? description,
    String? receiptPath,
  }) async {
    try {
      isUpdateLoading.value = true;

      final success = await _repo.updateLend(
        id: id,
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

        Get.back(); // close edit page

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

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
