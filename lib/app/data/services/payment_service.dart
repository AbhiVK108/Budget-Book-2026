import 'package:budgetbook_2026/app/core/constant/app_url.dart';
import 'package:budgetbook_2026/app/core/network/api_client.dart';
import 'package:dio/dio.dart';

class PaymentService {
  final ApiClient _apiClient = ApiClient();

  /// 🔥 ADD PAYMENT (REPAY BORROW)
  Future<bool> addPayment({
    required int debitId,
    required String paymentDate,
    required String paymentAmount,
  }) async {
    try {
      final formData = FormData.fromMap({
        "debitId": debitId,
        "paymentDate": paymentDate,
        "paymentAmount": paymentAmount,
      });

      final response = await _apiClient.dio.post(
        '', // 👉 add this in AppUrl
        data: formData,
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      throw Exception(e.response?.data["message"] ?? "Failed to add payment");
    }
  }
}
