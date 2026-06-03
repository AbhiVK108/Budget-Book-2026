import 'package:budgetbook_2026/app/data/models/chit_model.dart';
import 'package:budgetbook_2026/app/data/services/chit_api_service.dart';

class ChitRepository {
  final ChitService _service = ChitService();

  /// 🔹 GET
  Future<ChitModelResponse> getChits() async {
    return await _service.fetchChits();
  }

  /// 🔹 CREATE
  Future<bool> createChit({
    required String chitName,
    required String chitValue,
    required String chitStart,
    required String chitEnd,
    required String chitDuration,
    required String chitMembers,
    required String chitMonthly,
    required String chitMonthlyAfter,
    required String chitStatus,
    required String status,
    String? receiptPath,
  }) {
    return _service.createChit(
      chitName: chitName,
      chitValue: chitValue,
      chitStart: chitStart,
      chitEnd: chitEnd,
      chitDuration: chitDuration,
      chitMembers: chitMembers,
      chitMonthly: chitMonthly,
      chitMonthlyAfter: chitMonthlyAfter,
      chitStatus: chitStatus,
      status: status,
      receiptPath: receiptPath,
    );
  }

  /// 🔹 UPDATE
  Future<bool> updateChit({
    required int id,
    required String chitName,
    required String chitValue,
    required String chitStart,
    required String chitEnd,
    required String chitDuration,
    required String chitMembers,
    required String chitLift,
    required String chitLiftAmount,
    required String chitMonthly,
    required String chitMonthlyAfter,
    required String chitStatus,
    required String status,
    String? receiptPath,
  }) {
    return _service.updateChit(
      id: id,
      chitName: chitName,
      chitValue: chitValue,
      chitStart: chitStart,
      chitEnd: chitEnd,
      chitDuration: chitDuration,
      chitMembers: chitMembers,
      chitLift: chitLift,
      chitLiftAmount: chitLiftAmount,
      chitMonthly: chitMonthly,
      chitMonthlyAfter: chitMonthlyAfter,
      chitStatus: chitStatus,
      status: status,
      receiptPath: receiptPath,
    );
  }

  /// 🔹 DELETE
  Future<bool> deleteChit(int id) async {
    return await _service.deleteChit(id);
  }
}