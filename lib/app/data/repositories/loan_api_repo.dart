import 'package:budgetbook_2026/app/data/models/loan_model.dart';
import 'package:budgetbook_2026/app/data/services/loan_api_service.dart';

class LoanRepository {
  final LoanService _service = LoanService();

  /// 🔹 GET
  Future<LoanModelResponse> getLoans() async {
    return await _service.fetchLoans();
  }

  /// 🔹 CREATE
  Future<bool> createLoan({
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
  }) {
    return _service.createLoan(
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
  }

  /// 🔹 UPDATE
  Future<bool> updateLoan({
    required int id,
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
  }) {
    return _service.updateLoan(
      id: id,
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
  }

  /// 🔹 DELETE
  Future<bool> deleteLoan(int id) async {
    return await _service.deleteLoan(id);
  }
}