class BorrowModelResponse {
  final String status;
  final int code;
  final String message;
  final List<BorrowModel> data;

  BorrowModelResponse({
    required this.status,
    required this.code,
    required this.message,
    required this.data,
  });

  factory BorrowModelResponse.fromJson(Map<String, dynamic> json) {
    return BorrowModelResponse(
      status: json["status"] ?? "",
      code: json["code"] ?? 0,
      message: json["message"] ?? "",
      data: (json["data"] as List? ?? [])
          .map((e) => BorrowModel.fromJson(e))
          .toList(),
    );
  }
}
class BorrowModel {
  final int id;
  final int customerId;
  final String receiveFrom;
  final String amount;
  final String receiveDate;
  final String returnDate;
  final String rateOfInterest;
  final String description;
  final String? receipt;
  final String status;
  final String paidAmount; // ✅ ADD THIS

  BorrowModel({
    required this.id,
    required this.customerId,
    required this.receiveFrom,
    required this.amount,
    required this.receiveDate,
    required this.returnDate,
    required this.rateOfInterest,
    required this.description,
    this.receipt,
    required this.status,
    required this.paidAmount,
  });

  factory BorrowModel.fromJson(Map<String, dynamic> json) {
    return BorrowModel(
      id: int.tryParse(json["id"].toString()) ?? 0,
      customerId: int.tryParse(json["customerId"].toString()) ?? 0,

      /// ✅ FIXED KEYS
      receiveFrom: json["receiveFrom"] ?? "",
      receiveDate: json["receiveDate"] ?? "",

      amount: json["amount"].toString(),
      returnDate: json["returnDate"] ?? "",
      rateOfInterest: json["rateOfInterest"].toString(),
      description: json["description"] ?? "",
      receipt: json["receipt"],
      status: json["status"].toString(),

      /// ✅ IMPORTANT
      paidAmount: json["paidAmount"]?.toString() ?? "0",
    );
  }
}