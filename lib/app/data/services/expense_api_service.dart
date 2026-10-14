import 'package:budgetbook_2026/app/core/constant/app_url.dart';
import 'package:budgetbook_2026/app/core/network/api_client.dart';
import 'package:budgetbook_2026/app/data/models/expense_model.dart';
import 'package:dio/dio.dart';

class ExpenseService {
  final ApiClient _apiClient = ApiClient();

  ////////////////////////////////////////////////////////////
  /// GET EXPENSE
  ////////////////////////////////////////////////////////////
  Future<ExpenseResponse> fetchExpense() async {
    try {
      final response = await _apiClient.dio.get(
        AppUrl.allExpense, // 🔥 new endpoint
      );

      return ExpenseResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return ExpenseResponse(
          status: "success",
          code: 200,
          message: "No expense yet",
          data: [],
          totalAmount: 0,
        );
      }
      rethrow;
    }
  }

  ////////////////////////////////////////////////////////////
  /// POST EXPENSE
  ////////////////////////////////////////////////////////////
  Future<bool> postExpense({
    required int categoryId,
    required String amount,
    required String expenseDate,
    String? description,
    String? receiptPath,
  }) async {
    try {
      final formMap = {
        "categoryId": categoryId,
        "amount": amount,
        "expenseDate": expenseDate, // 🔥 important
      };

      if (description != null && description.isNotEmpty) {
        formMap["description"] = description;
      }

      if (receiptPath != null && receiptPath.isNotEmpty) {
        formMap["receipt"] = await MultipartFile.fromFile(
          receiptPath,
          filename: receiptPath.split('/').last,
        );
      }

      final formData = FormData.fromMap(formMap);

      final response = await _apiClient.dio.post(
        AppUrl.allExpense,
        data: formData,
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      throw Exception(e.response?.data["message"] ?? "Failed to add expense");
    }
  }

  ////////////////////////////////////////////////////////////
  /// UPDATE EXPENSE
  ////////////////////////////////////////////////////////////
  Future<bool> updateExpense({
    required int id,
    required int categoryId,
    required String amount,
    required String expenseDate,
    String? description,
    String? receiptPath,
  }) async {
    try {
      final formMap = {
        "categoryId": categoryId,
        "amount": amount,
        "expenseDate": expenseDate,
      };

      if (description != null && description.isNotEmpty) {
        formMap["description"] = description;
      }

      if (receiptPath != null && receiptPath.isNotEmpty) {
        formMap["receipt"] = await MultipartFile.fromFile(
          receiptPath,
          filename: receiptPath.split('/').last,
        );
      }

      final formData = FormData.fromMap(formMap);

      final response = await _apiClient.dio.post(
        "${AppUrl.allExpense}/$id",
        data: formData,
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      throw Exception(e.response?.data["message"] ?? "Failed to update expense");
    }
  }

  ////////////////////////////////////////////////////////////
  /// DELETE EXPENSE
  ////////////////////////////////////////////////////////////
  Future<bool> deleteExpense(int id) async {
    try {
      final response = await _apiClient.dio.delete(
        "${AppUrl.allExpense}/$id",
      );

      return response.statusCode == 200;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data["message"] ?? "Failed to delete expense",
      );
    }
  }
}