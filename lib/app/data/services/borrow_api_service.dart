import 'package:budgetbook_2026/app/core/constant/app_url.dart';
import 'package:budgetbook_2026/app/core/network/api_client.dart';
import 'package:budgetbook_2026/app/data/models/borrow_model.dart';
import 'package:dio/dio.dart';

class BorrowService {
  final ApiClient _apiClient = ApiClient();

  /// 🔹 GET DEBIT
  Future<BorrowModelResponse> fetchBorrows() async {
    try {
      final response = await _apiClient.dio.get(
        AppUrl.borrowGet, // 🔥 /debit
      );

      return BorrowModelResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return BorrowModelResponse(
          status: "success",
          code: 200,
          message: "No borrow data",
          data: [],
        );
      }

      throw Exception(
        e.response?.data["message"] ?? "Failed to fetch borrow data",
      );
    }
  }

  /// 🔥 CREATE (POST)
  Future<bool> createBorrow({
    required String receiveFrom,
    required String amount,
    required String receiveDate,
    required String rateOfInterest,
    required String returnDate,
    String? description,
    String? receiptPath,
  }) async {
    try {
      final Map<String, dynamic> formMap = {
        // ✅ FIX HERE
        "receiveFrom": receiveFrom,
        "amount": amount,
        "receiveDate": receiveDate,
        "rateOfInterest": rateOfInterest,
        "returnDate": returnDate,
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

      final response = await _apiClient.dio.post(
        AppUrl.borrowPost,
        data: FormData.fromMap(formMap),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      throw Exception(e.response?.data["message"] ?? "Failed to create borrow");
    }
  }

  /// 🔥 UPDATE
  Future<bool> updateBorrow({
    required int id,
    required String receiveFrom,
    required String amount,
    required String receiveDate,
    required String rateOfInterest,
    required String returnDate,
    String? description,
    String? receiptPath,
  }) async {
    try {
      final Map<String, dynamic> formMap = {
        // ✅ FIX HERE
        "receiveFrom": receiveFrom,
        "amount": amount,
        "receiveDate": receiveDate,
        "rateOfInterest": rateOfInterest,
        "returnDate": returnDate,
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

      final response = await _apiClient.dio.post(
        "${AppUrl.borrowUpdate}/$id",
        data: FormData.fromMap(formMap),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      throw Exception(e.response?.data["message"] ?? "Failed to update borrow");
    }
  }

  /// 🔥 DELETE
  Future<bool> deleteBorrow(int id) async {
    try {
      final response = await _apiClient.dio.delete(
        "${AppUrl.borrowDelete}/$id",
      );

      return response.statusCode == 200;
    } on DioException catch (e) {
      throw Exception(e.response?.data["message"] ?? "Failed to delete borrow");
    }
  }
}
