import 'package:budgetbook_2026/app/data/repositories/chit_api_repo.dart';
import 'package:budgetbook_2026/app/modules/chit_funds/controllers/chit_funds_controller.dart';
import 'package:get/get.dart';

class EditChitFundsController extends GetxController {
  final ChitRepository _repo = ChitRepository();

  var isUpdateLoading = false.obs;

  /// 🔥 UPDATE CHIT
  Future<void> updateChit({
    required int id,
    required String chitName,
    required String chitValue,
    required String chitStart,
    required String chitEnd,
    required String chitDuration,
    required String chitMembers,
    required String chitLift,
    required String chitLiftAmount,
    required String chitMonthly,
    required String chitMonthlyAfter,
    required String chitStatus,
    required String status,
    String? receiptPath,
  }) async {
    try {
      isUpdateLoading.value = true;

      final success = await _repo.updateChit(
        id: id,
        chitName: chitName,
        chitValue: chitValue,
        chitStart: chitStart,
        chitEnd: chitEnd,
        chitDuration: chitDuration,
        chitMembers: chitMembers,
        chitLift: chitLift,
        chitLiftAmount: chitLiftAmount,
        chitMonthly: chitMonthly,
        chitMonthlyAfter: chitMonthlyAfter,
        chitStatus: chitStatus,
        status: status,
        receiptPath: receiptPath,
      );

      if (success) {
        Get.back();

        /// 🔥 Refresh main list
        Get.find<ChitFundsController>().fetchChits();

        Get.snackbar("Success", "Chit Updated Successfully");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isUpdateLoading.value = false;
    }
  }
}