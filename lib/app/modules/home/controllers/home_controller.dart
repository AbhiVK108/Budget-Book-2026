import 'package:budgetbook_2026/app/data/models/income_model.dart';
import 'package:budgetbook_2026/app/data/repositories/income_api_repo.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final IncomeRepository _repo = IncomeRepository();

  final isLoading = false.obs;
  final incomeList = <IncomeModel>[].obs;
  final totalIncome = 0.0.obs;
  final errorMessage = "".obs;

  @override
  void onInit() {
    fetchIncome();
    super.onInit();
  }

Future<void> fetchIncome({String? token}) async {
  try {
    isLoading.value = true;
    errorMessage.value = '';

    final response = await _repo.getIncome(token: token);

    incomeList.value = response.data;
    totalIncome.value = response.totalAmount;

  } on DioException catch (e) {

    /// 🔥 HANDLE 404 AS EMPTY DATA
    if (e.response?.statusCode == 404) {

      incomeList.clear();
      totalIncome.value = 0.0;

      /// IMPORTANT → do NOT set error message
      errorMessage.value = '';

    } else {

      /// Real error (network/server/etc)
      errorMessage.value = "Failed to load income";
    }

  } catch (e) {

    /// Non-Dio unexpected error
    errorMessage.value = "Something went wrong";
    
  } finally {
    isLoading.value = false;
  }
}
}
