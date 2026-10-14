

import 'package:budgetbook_2026/app/data/models/income_model.dart';
import 'package:budgetbook_2026/app/data/services/income_api_service.dart';

class IncomeRepository {
  final IncomeService _service = IncomeService();

// Income GET
  Future<IncomeResponse> getIncome() async {
    return await _service.fetchIncome();
  }
// Income POST
Future<bool> addIncome({
  required int categoryId,
  required String amount,
  required String incomeDate,
  String? description,
  String? receiptPath,
}) async {
  return await _service.postIncome(
    categoryId: categoryId,
    amount: amount,
    incomeDate: incomeDate,
    description: description,
    receiptPath: receiptPath,
  );
}

// Income Update (Post method)
Future<bool> updateIncome({
  required int id,
  required int categoryId,
  required String amount,
  required String incomeDate,
  String? description,
  String? receiptPath,
}) async {
  return await _service.updateIncome(
    id: id,
    categoryId: categoryId,
    amount: amount,
    incomeDate: incomeDate,
    description: description,
    receiptPath: receiptPath,
  );
}

// Income Delete
Future<bool> deleteIncome(int id) async {
  return await _service.deleteIncome(id);
}
}