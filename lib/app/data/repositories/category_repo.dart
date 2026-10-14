import 'package:budgetbook_2026/app/data/models/category_model.dart';
import 'package:budgetbook_2026/app/data/services/category_api_service.dart';

class CategoryRepo {
  final CategoryApiService _service = CategoryApiService();

  // Categories GET
Future<CategoryResponse> getCategories() async {
  return await _service.fetchCategories();
}
// Post Category
Future<bool> createCategory({
    required String name,
    required String type,
  }) async {
    return await _service.addCategory(
      categoryName: name,
      categoryType: type,
    );
  }
}