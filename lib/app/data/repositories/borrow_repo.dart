import 'package:budgetbook_2026/app/data/models/borrow_model.dart';
import 'package:budgetbook_2026/app/data/services/borrow_api_service.dart';

class BorrowRepository {
  final BorrowService _service = BorrowService();

  Future<BorrowModelResponse> getBorrows() async {
    return await _service.fetchBorrows();
  }

  Future<bool> createBorrow({
    required String receiveFrom,
    required String amount,
    required String receiveDate,
    required String rateOfInterest,
    required String returnDate,
    String? description,
    String? receiptPath,
  }) {
    return _service.createBorrow(
      receiveFrom: receiveFrom,
      amount: amount,
      receiveDate: receiveDate,
      rateOfInterest: rateOfInterest,
      returnDate: returnDate,
      description: description,
      receiptPath: receiptPath,
    );
  }

  Future<bool> updateBorrow({
    required int id,
    required String receiveFrom,
    required String amount,
    required String receiveDate,
    required String rateOfInterest,
    required String returnDate,
    String? description,
    String? receiptPath,
  }) {
    return _service.updateBorrow(
      id: id,
      receiveFrom: receiveFrom,
      amount: amount,
      receiveDate: receiveDate,
      rateOfInterest: rateOfInterest,
      returnDate: returnDate,
      description: description,
      receiptPath: receiptPath,
    );
  }

  Future<bool> deleteBorrow(int id) {
    return _service.deleteBorrow(id);
  }
}