import 'package:budgetbook_2026/app/core/constant/app_url.dart';
import 'package:budgetbook_2026/app/core/network/api_client.dart';
import 'package:budgetbook_2026/app/data/models/lend_model.dart';
import 'package:dio/dio.dart';

class LendService {
  final ApiClient _apiClient = ApiClient();

  /// 🔹 GET LEND (CREDIT)
  Future<LendModelResponse> fetchLends() async {
    try {
      final response = await _apiClient.dio.get(
        AppUrl.lendGet,
      );

      return LendModelResponse.fromJson(response.data);

    } on DioException catch (e) {

      /// ✅ HANDLE EMPTY CASE
      if (e.response?.statusCode == 404) {
        return LendModelResponse(
          status: "success",
          code: 200,
          message: "No lend data",
          data: [],
        );
      }

      throw Exception(
        e.response?.data["message"] ?? "Failed to fetch lend data",
      );
    }
  }


/// 🔥 CREATE LEND (POST)
Future<bool> createLend({
  required String givenTo,
  required String amount,
  required String givenDate,
  required String rateOfInterest,
  required String returnDate,
  String? description,
  String? receiptPath,
}) async {
  try {
    final Map<String, dynamic> formMap = {
      "givenTo": givenTo,
      "amount": amount,
      "givenDate": givenDate,
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
      AppUrl.lendPost, // 🔥 /credit endpoint
      data: FormData.fromMap(formMap),
    );

    return response.statusCode == 200 || response.statusCode == 201;

  } on DioException catch (e) {
    throw Exception(e.response?.data["message"] ?? "Failed to create lend");
  }
}

  // Update Lend (Post method)
Future<bool> updateLend({
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
    /// 🔥 IMPORTANT FIX
    final Map<String, dynamic> formMap = {
      "givenTo": givenTo,
      "amount": amount,
      "givenDate": givenDate,
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
      "${AppUrl.lendUpdate}/$id",
      data: FormData.fromMap(formMap),
    );

    return response.statusCode == 200 || response.statusCode == 201;

  } on DioException catch (e) {
    throw Exception(e.response?.data["message"] ?? "Failed to update lend");
  }
}
  /// 🔥 DELETE LEND
  Future<bool> deleteLend(int id) async {
    try {
      final response = await _apiClient.dio.delete(
        "${AppUrl.lendDelete}/$id",
      );

      return response.statusCode == 200;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data["message"] ?? "Failed to delete lend",
      );
    }
  }
}