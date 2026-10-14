import 'package:budgetbook_2026/app/core/constant/app_url.dart';
import 'package:budgetbook_2026/app/core/network/api_client.dart';
import 'package:budgetbook_2026/app/data/models/category_model.dart';
import 'package:dio/dio.dart';

class CategoryApiService {
  final ApiClient _apiClient = ApiClient();

  // Categories GET
  Future<CategoryResponse> fetchCategories() async {
    try {
      final response = await _apiClient.dio.get(
        AppUrl.allCategories, // your endpoint
      );

      return CategoryResponse.fromJson(response.data);
    } on DioException catch (e) {
      /// 🔥 HANDLE: No categories found
      if (e.response?.statusCode == 404) {
        return CategoryResponse(
          status: "success",
          code: 200,
          message: "No categories",
          data: [],
        );
      }

      rethrow;
    }
  }

  // Post Category
  Future<bool> addCategory({
    required String categoryName,
    required String categoryType, // Income / Expense
  }) async {
    try {
      final formData = FormData.fromMap({
        "categoryName": categoryName,
        "categoryType": categoryType,
      });

      final response = await _apiClient.dio.post(
        AppUrl.addCategory,
        data: formData,
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      throw Exception(e.response?.data["message"] ?? "Failed to add category");
    }
  }
}
