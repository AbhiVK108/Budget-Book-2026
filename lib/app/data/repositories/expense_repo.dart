import 'package:budgetbook_2026/app/data/models/expense_model.dart';
import 'package:budgetbook_2026/app/data/services/expense_api_service.dart';

class ExpenseRepository {
  final ExpenseService _service = ExpenseService();

  Future<ExpenseResponse> getExpense({String? token}) async {
    return await _service.fetchExpense(token: token);
  }

  Future<bool> addExpense({
    required int categoryId,
    required String amount,
    required String expenseDate,
    String? description,
    String? receiptPath,
  }) async {
    return await _service.postExpense(
      categoryId: categoryId,
      amount: amount,
      expenseDate: expenseDate,
      description: description,
      receiptPath: receiptPath,
    );
  }

  Future<bool> updateExpense({
    required int id,
    required int categoryId,
    required String amount,
    required String expenseDate,
    String? description,
    String? receiptPath,
  }) async {
    return await _service.updateExpense(
      id: id,
      categoryId: categoryId,
      amount: amount,
      expenseDate: expenseDate,
      description: description,
      receiptPath: receiptPath,
    );
  }

  Future<bool> deleteExpense(int id) async {
    return await _service.deleteExpense(id);
  }
}