import 'package:budgetbook_2026/app/data/models/category_model.dart';
import 'package:budgetbook_2026/app/data/repositories/category_repo.dart';
import 'package:budgetbook_2026/app/data/repositories/income_api_repo.dart';
import 'package:budgetbook_2026/app/modules/details/controllers/in_ex_details_controller.dart';
import 'package:budgetbook_2026/app/modules/incomeExpense/controllers/income_expense_controller.dart';
import 'package:get/get.dart';

class IncomeExpenseEditController extends GetxController {
  final IncomeRepository _repo = IncomeRepository();
  final CategoryRepo _categoryRepo = CategoryRepo();

  final isLoading = false.obs;

  // Income Update (Post method)
  Future<void> submit({
    required int id,
    required int categoryId,
    required String amount,
    required DateTime date,
    String? description,
    String? receiptPath,
  }) async {
    try {
      isLoading.value = true;

      final formattedDate =
          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} "
          "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:00";

      final success = await _repo.updateIncome(
        id: id,
        categoryId: categoryId,
        amount: amount,
        incomeDate: formattedDate,
        description: description,
        receiptPath: receiptPath,
      );

      if (success) {
        /// Refresh list
        final incomeController = Get.find<IncomeExpenseController>();
        await incomeController.fetchIncome();

        // Refresh this screen controller
        final detailsController = Get.find<IncomeExpenseDetailsController>();
        detailsController.fetchIncome();
        Get.back();
        Get.snackbar("Success", "Income updated 🎉");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // Category Get Method

  /// ================= CATEGORY =================
  final RxList<CategoryModel> incomeCategories = <CategoryModel>[].obs;
  final RxBool isLoadingCategories = false.obs;

  final RxInt selectedCategoryIndex = (-1).obs;

Future<void> fetchIncomeCategories(int initialCategoryId) async {
  try {
    isLoadingCategories.value = true;

    final response = await _categoryRepo.getCategories();

    final filtered =
        response.data.where((c) => c.type == "Income").toList();

    incomeCategories.value = filtered;

    // ✅ PRESELECT HERE
    final index =
        incomeCategories.indexWhere((c) => c.id == initialCategoryId);

    if (index != -1) {
      selectedCategoryIndex.value = index;
    }

  } catch (e) {
    Get.snackbar("Error", e.toString());
  } finally {
    isLoadingCategories.value = false;
  }
}
  /// ================= PRESELECT CATEGORY =================
  void setInitialCategory(int categoryId) {
    final index = incomeCategories.indexWhere((c) => c.id == categoryId);
    if (index != -1) {
      selectedCategoryIndex.value = index;
    }
  }

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
