import 'package:budgetbook_2026/app/core/constant/app_url.dart';
import 'package:budgetbook_2026/app/core/network/api_client.dart';
import 'package:budgetbook_2026/app/data/models/chit_model.dart';
import 'package:dio/dio.dart';

class ChitService {
  final ApiClient _apiClient = ApiClient();

  /// 🔹 GET CHITS
  Future<ChitModelResponse> fetchChits() async {
    try {
      final response = await _apiClient.dio.get(AppUrl.chitGet);

      return ChitModelResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return ChitModelResponse(
          status: "success",
          code: 200,
          message: "No chits",
          data: [],
        );
      }

      throw Exception(e.response?.data["message"] ?? "Failed to fetch chits");
    }
  }

  /// 🔥 CREATE CHIT
  Future<bool> createChit({
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
      final Map<String, dynamic> formMap = {
        "chitName": chitName,
        "chitValue": chitValue,
        "chitStart": chitStart,
        "chitEnd": chitEnd,
        "chitDuration": chitDuration,
        "chitMembers": chitMembers,
        "chitMonthly": chitMonthly,
        "chitMonthlyAfter": chitMonthlyAfter,
        "chitStatus": chitStatus,
        "status": status,
      };

      if (receiptPath != null && receiptPath.isNotEmpty) {
        formMap["receipt"] = await MultipartFile.fromFile(
          receiptPath,
          filename: receiptPath.split('/').last,
        );
      }

      print("📤 CREATE CHIT DATA:");
      formMap.forEach((k, v) => print("$k : $v"));

      final response = await _apiClient.dio.post(
        AppUrl.chitPost,
        data: FormData.fromMap(formMap),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      throw Exception(e.response?.data["message"] ?? "Create chit failed");
    }
  }

  /// 🔥 UPDATE CHIT
  Future<bool> updateChit({
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
      final Map<String, dynamic> formMap = {
        "chitName": chitName,
        "chitValue": chitValue,
        "chitStart": chitStart,
        "chitEnd": chitEnd,
        "chitDuration": chitDuration,
        "chitMembers": chitMembers,
        "chitLift": chitLift,
        "chitLiftAmount": chitLiftAmount,
        "chitMonthly": chitMonthly,
        "chitMonthlyAfter": chitMonthlyAfter,
        "chitStatus": chitStatus,
        "status": status,
      };

      if (receiptPath != null && receiptPath.isNotEmpty) {
        formMap["receipt"] = await MultipartFile.fromFile(
          receiptPath,
          filename: receiptPath.split('/').last,
        );
      }

      print("📤 UPDATE CHIT DATA:");
      formMap.forEach((k, v) => print("$k : $v"));

      final response = await _apiClient.dio.post(
        "${AppUrl.chitUpdate}/$id",
        data: FormData.fromMap(formMap),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      throw Exception(e.response?.data["message"] ?? "Update chit failed");
    }
  }

  /// 🔥 DELETE CHIT
  Future<bool> deleteChit(int id) async {
    try {
      final response =
          await _apiClient.dio.delete("${AppUrl.chitDelete}/$id");

      return response.statusCode == 200;
    } on DioException catch (e) {
      throw Exception(e.response?.data["message"] ?? "Delete chit failed");
    }
  }
}