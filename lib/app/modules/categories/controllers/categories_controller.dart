import 'package:budgetbook_2026/app/data/repositories/category_repo.dart';
import 'package:budgetbook_2026/app/modules/incomeExpense/controllers/expense_controller.dart';
import 'package:get/get.dart';
import 'package:budgetbook_2026/app/modules/incomeExpense/controllers/income_expense_controller.dart';

class CategoriesController extends GetxController {
  final CategoryRepo _repo = CategoryRepo();

  final isLoading = false.obs;

  final nameController = "".obs;

  late String categoryType; // 🔥 dynamic (Income / Expense)

  @override
  void onInit() {
    super.onInit();

    /// 🔥 DEBUG: Check what you receive
    print("➡️ Route Argument: ${Get.arguments}");

    categoryType = Get.arguments ?? "Income";

    print("✅ Category Type Set To: $categoryType");
  }

  Future<void> addCategory() async {
    try {
      print("🚀 addCategory called");
      if (nameController.value.trim().isEmpty) {
        print("🚀 addCategory called");
        Get.snackbar("Error", "Enter category name");
        return;
      }
      print("📌 Category Name: ${nameController.value}");
      print("📌 Category Type: $categoryType");

      isLoading.value = true;

      final success = await _repo.createCategory(
        name: nameController.value.trim(),
        type: categoryType, // 🔥 AUTO SET
      );

      print("📡 API Response: $success");
      if (success) {
        print("✅ Category Added Successfully");

        Get.back();

        /// 🔥 CORRECT CONTROLLER CALL
        if (categoryType == "Income") {
          if (Get.isRegistered<IncomeExpenseController>()) {
            Get.find<IncomeExpenseController>().fetchIncomeCategories();
          }
        } else {
          if (Get.isRegistered<ExpenseController>()) {
            Get.find<ExpenseController>().fetchExpenseCategories();
          }
        }

        Get.snackbar("Success", "$categoryType category added 🎉");
      }
    } catch (e) {
      print("🔥 ERROR: $e");
      Get.snackbar("Error", e.toString());
    } finally {
      print("🔄 Loading finished");
      isLoading.value = false;
    }
  }
}
