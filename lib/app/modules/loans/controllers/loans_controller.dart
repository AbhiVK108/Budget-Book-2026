import 'package:budgetbook_2026/app/data/models/loan_model.dart';
import 'package:budgetbook_2026/app/data/repositories/loan_api_repo.dart';
import 'package:get/get.dart';

class LoansController extends GetxController {
  final LoanRepository _repo = LoanRepository();

  final isLoading = false.obs;
  final loanList = <LoanModel>[].obs;
  final isDeleteLoading = false.obs;

  /// 🔹 FETCH LOANS
  Future<void> fetchLoans() async {
    try {
      isLoading.value = true;

      final response = await _repo.getLoans();

      loanList.value = response.data;
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// 🔥 DELETE LOAN
  Future<void> deleteLoan(int id) async {
    try {
      isDeleteLoading.value = true;

      final success = await _repo.deleteLoan(id);

      if (success) {
        loanList.removeWhere((e) => e.id == id);
        Get.snackbar("Success", "Loan deleted");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isDeleteLoading.value = false;
    }
  }

  /// 🔹 TOTALS (Dashboard)
  double getTotalLoanAmount() {
    return loanList.fold(
      0,
      (sum, item) =>
          sum + (double.tryParse(item.totalAmount) ?? 0),
    );
  }

  double getTotalInterest() {
    return loanList.fold(
      0,
      (sum, item) =>
          sum + (double.tryParse(item.totalInterestAmount) ?? 0),
    );
  }

  double getTotalEMI() {
    return loanList.fold(
      0,
      (sum, item) =>
          sum + (double.tryParse(item.instalmentAmount) ?? 0),
    );
  }

  @override
  void onInit() {
    fetchLoans();
    super.onInit();
  }
}