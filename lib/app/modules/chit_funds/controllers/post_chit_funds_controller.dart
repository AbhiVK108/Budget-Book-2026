import 'package:budgetbook_2026/app/data/repositories/chit_api_repo.dart';
import 'package:budgetbook_2026/app/modules/chit_funds/controllers/chit_funds_controller.dart';
import 'package:get/get.dart';

class PostChitFundsController extends GetxController {
  final ChitRepository _repo = ChitRepository();

  var isLoading = false.obs;

  /// 🔥 CREATE CHIT
  Future<void> createChit({
    required String chitName,
    required String chitValue,
    required String chitStart,
    required String chitEnd,
    required String chitDuration,
    required String chitMembers,
    required String chitMonthly,
    required String chitMonthlyAfter,
    required String chitStatus,
    required String status,
    String? receiptPath,
  }) async {
    try {
      isLoading.value = true;

      final success = await _repo.createChit(
        chitName: chitName,
        chitValue: chitValue,
        chitStart: chitStart,
        chitEnd: chitEnd,
        chitDuration: chitDuration,
        chitMembers: chitMembers,
        chitMonthly: chitMonthly,
        chitMonthlyAfter: chitMonthlyAfter,
        chitStatus: chitStatus,
        status: status,
        receiptPath: receiptPath,
      );

      if (success) {
        Get.back();
        Get.find<ChitFundsController>().fetchChits();
        Get.snackbar("Success", "Chit Created Successfully");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
