import 'package:budgetbook_2026/app/core/constant/app_url.dart';
import 'package:budgetbook_2026/app/core/network/api_client.dart';
import 'package:budgetbook_2026/app/data/models/income_model.dart';
import 'package:dio/dio.dart';

class IncomeService {
  final ApiClient _apiClient = ApiClient();

// Income GET
  Future<IncomeResponse> fetchIncome({String? token}) async {
    try {
      final response = await _apiClient.dio.get(
        AppUrl.allIncome,
      );

      return IncomeResponse.fromJson(response.data);

    } on DioException catch (e) {

      /// 🔥 HANDLE: No income data found (404)
      if (e.response?.statusCode == 404) {

        return IncomeResponse(
          status: "success",
          code: 200,
          message: "No income yet",
          data: [],
          totalAmount: 0,
        );
      }

      /// Other errors → rethrow
      rethrow;
    }
  }

// Post Income
Future<bool> postIncome({
  required int categoryId,
  required String amount,
  required String incomeDate,
  String? description,
  String? receiptPath, // 👈 file path
}) async {
  try {
    final formMap = {
      "categoryId": categoryId,
      "amount": amount,
      "incomeDate": incomeDate,
    };

    /// Optional description
    if (description != null && description.isNotEmpty) {
      formMap["description"] = description;
    }

    /// Optional receipt image
    if (receiptPath != null && receiptPath.isNotEmpty) {
      formMap["receipt"] = await MultipartFile.fromFile(
        receiptPath,
        filename: receiptPath.split('/').last,
      );
    }

    final formData = FormData.fromMap(formMap);

    final response = await _apiClient.dio.post(
      AppUrl.allIncome,
      data: formData,
    );

    return response.statusCode == 200 || response.statusCode == 201;

  } on DioException catch (e) {
    throw Exception(e.response?.data["message"] ?? "Failed to add income");
  }
}

// Update Income (Post method with ID in URL)
Future<bool> updateIncome({
  required int id,
  required int categoryId,
  required String amount,
  required String incomeDate,
  String? description,
  String? receiptPath,
}) async {
  try {
    final formMap = {
      "categoryId": categoryId,
      "amount": amount,
      "incomeDate": incomeDate,
    };

    /// Optional description
    if (description != null && description.isNotEmpty) {
      formMap["description"] = description;
    }

    /// Optional receipt file
    if (receiptPath != null && receiptPath.isNotEmpty) {
      formMap["receipt"] = await MultipartFile.fromFile(
        receiptPath,
        filename: receiptPath.split('/').last,
      );
    }

    final formData = FormData.fromMap(formMap);

    final response = await _apiClient.dio.post(
      "${AppUrl.allIncome}/$id", // 👉 /income/id
      data: formData,
    );

    return response.statusCode == 200 || response.statusCode == 201;

  } on DioException catch (e) {
    throw Exception(e.response?.data["message"] ?? "Failed to update income");
  }
}

// Delete Income
Future<bool> deleteIncome(int id) async {
  try {
    final response = await _apiClient.dio.delete(
      "${AppUrl.allIncome}/$id",
    );

    return response.statusCode == 200;
  } on DioException catch (e) {
    throw Exception(
      e.response?.data["message"] ?? "Failed to delete income",
    );
  }
}
}