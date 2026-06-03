import 'package:budgetbook_2026/app/core/constant/app_url.dart';
import 'package:budgetbook_2026/app/core/network/api_client.dart';
import 'package:budgetbook_2026/app/data/models/loan_model.dart';
import 'package:dio/dio.dart';

class LoanService {
  final ApiClient _apiClient = ApiClient();

  /// 🔹 GET LOANS
  Future<LoanModelResponse> fetchLoans() async {
    try {
      final response = await _apiClient.dio.get(AppUrl.loanGet);

      return LoanModelResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return LoanModelResponse(
          status: "success",
          code: 200,
          message: "No loan data",
          data: [],
        );
      }

      throw Exception(e.response?.data["message"] ?? "Failed to fetch loans");
    }
  }

  /// 🔥 CREATE LOAN
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
  }) async {
    try {
      final Map<String, dynamic> formMap = {
        "nameOfLender": nameOfLender,
        "sanctionedAmount": sanctionedAmount,
        "dateOfDisbursement": dateOfDisbursement,
        "disbursalAmount": disbursalAmount,
        "chargesCutting": chargesCutting,
        "loanTerms": loanTerms,
        "rateOfInterest": rateOfInterest,
        "totalInterestAmount": totalInterestAmount,
        "instalmentAmount": instalmentAmount,
        "startEMI": startEMI,
        "endEMI": endEMI,
        "totalAmount": totalAmount,
      };

      if (receiptPath != null && receiptPath.isNotEmpty) {
        formMap["receipt"] = await MultipartFile.fromFile(
          receiptPath,
          filename: receiptPath.split('/').last,
        );
      }

      print("📤 FORM DATA:");
formMap.forEach((key, value) {
  print("$key : $value");
});

      final response = await _apiClient.dio.post(
        AppUrl.loanPost,
        data: FormData.fromMap(formMap),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      throw Exception(e.response?.data["message"] ?? "Failed to create loan");
    }
  }

  /// 🔥 UPDATE LOAN
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
  }) async {
    try {
      final Map<String, dynamic> formMap = {
        "nameOfLender": nameOfLender,
        "sanctionedAmount": sanctionedAmount,
        "dateOfDisbursement": dateOfDisbursement,
        "disbursalAmount": disbursalAmount,
        "chargesCutting": chargesCutting,
        "loanTerms": loanTerms,
        "rateOfInterest": rateOfInterest,
        "totalInterestAmount": totalInterestAmount,
        "instalmentAmount": instalmentAmount,
        "startEMI": startEMI,
        "endEMI": endEMI,
        "totalAmount": totalAmount,
      };

      if (receiptPath != null && receiptPath.isNotEmpty) {
        formMap["receipt"] = await MultipartFile.fromFile(
          receiptPath,
          filename: receiptPath.split('/').last,
        );
      }

      final response = await _apiClient.dio.post(
        "${AppUrl.loanUpdate}/$id",
        data: FormData.fromMap(formMap),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      throw Exception(e.response?.data["message"] ?? "Failed to update loan");
    }
  }

  /// 🔥 DELETE LOAN
  Future<bool> deleteLoan(int id) async {
    try {
      final response = await _apiClient.dio.delete("${AppUrl.loanDelete}/$id");

      return response.statusCode == 200;
    } on DioException catch (e) {
      throw Exception(e.response?.data["message"] ?? "Failed to delete loan");
    }
  }
}
