import 'package:budgetbook_2026/app/data/models/lend_model.dart';
import 'package:budgetbook_2026/app/data/services/lend_api_service.dart';

class LendRepository {
  final LendService _service = LendService();

  /// 🔹 GET LEND
  Future<LendModelResponse> getLends() async {
    return await _service.fetchLends();
  }

  // LEND POST

  Future<bool> createLend({
  required String givenTo,
  required String amount,
  required String givenDate,
  required String rateOfInterest,
  required String returnDate,
  String? description,
  String? receiptPath,
}) {
  return _service.createLend(
    givenTo: givenTo,
    amount: amount,
    givenDate: givenDate,
    rateOfInterest: rateOfInterest,
    returnDate: returnDate,
    description: description,
    receiptPath: receiptPath,
  );
}

   /// UPDATE
  Future<bool> updateLend({
    required int id,
    required String givenTo,
    required String amount,
    required String givenDate,
    required String rateOfInterest,
    required String returnDate,
    String? description,
    String? receiptPath,
  }) async {
    return await _service.updateLend(
      id: id,
      givenTo: givenTo,
      amount: amount,
      givenDate: givenDate,
      rateOfInterest: rateOfInterest,
      returnDate: returnDate,
      description: description,
      receiptPath: receiptPath,
    );
  }

  /// DELETE
  Future<bool> deleteLend(int id) async {
    return await _service.deleteLend(id);
  }
}