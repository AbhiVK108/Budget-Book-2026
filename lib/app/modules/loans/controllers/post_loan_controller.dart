import 'package:budgetbook_2026/app/data/repositories/loan_api_repo.dart';
import 'package:get/get.dart';

class PostLoanController extends GetxController {
  final LoanRepository _repo = LoanRepository();

  final isLoading = false.obs;

  /// 🔥 CREATE LOAN
Future<void> createLoan({
  required String nameOfLender,
  required String sanctionedAmount,
  required String dateOfDisbursement,
  required String disbursalAmount,
  required String chargesCutting,
  required String loanTerms,
  required String rateOfInterest,
  required String totalInterestAmount,
  required String instalmentAmount,
  required String startEMI,
  required String endEMI,
  required String totalAmount,
  String? receiptPath,
}) async {
  try {
    isLoading.value = true;

    /// 🔥 DEBUG INPUT
    print("🚀 CREATE LOAN REQUEST");
    print("nameOfLender: $nameOfLender");
    print("sanctionedAmount: $sanctionedAmount");
    print("dateOfDisbursement: $dateOfDisbursement");
    print("disbursalAmount: $disbursalAmount");
    print("chargesCutting: $chargesCutting");
    print("loanTerms: $loanTerms");
    print("rateOfInterest: $rateOfInterest");
    print("totalInterestAmount: $totalInterestAmount");
    print("instalmentAmount: $instalmentAmount");
    print("startEMI: $startEMI");
    print("endEMI: $endEMI");
    print("totalAmount: $totalAmount");
    print("receiptPath: $receiptPath");

    final success = await _repo.createLoan(
      nameOfLender: nameOfLender,
      sanctionedAmount: sanctionedAmount,
      dateOfDisbursement: dateOfDisbursement,
      disbursalAmount: disbursalAmount,
      chargesCutting: chargesCutting,
      loanTerms: loanTerms,
      rateOfInterest: rateOfInterest,
      totalInterestAmount: totalInterestAmount,
      instalmentAmount: instalmentAmount,
      startEMI: startEMI,
      endEMI: endEMI,
      totalAmount: totalAmount,
      receiptPath: receiptPath,
    );

    print("✅ API SUCCESS: $success");

    if (success) {
      Get.back();
      Get.snackbar("Success", "Loan Created Successfully");
    }
  } catch (e) {
    print("❌ CREATE LOAN ERROR: $e");
    Get.snackbar("Error", e.toString());
  } finally {
    isLoading.value = false;
  }
}

}