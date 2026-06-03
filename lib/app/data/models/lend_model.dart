class LendModelResponse {
  final String status;
  final int code;
  final String message;
  final List<LendModel> data;

  LendModelResponse({
    required this.status,
    required this.code,
    required this.message,
    required this.data,
  });

  factory LendModelResponse.fromJson(Map<String, dynamic> json) {
    return LendModelResponse(
      status: json["status"] ?? "",
      code: json["code"] ?? 0,
      message: json["message"] ?? "",
      data: (json["data"] as List? ?? [])
          .map((e) => LendModel.fromJson(e))
          .toList(),
    );
  }
}

class LendModel {
  final int id;
  final int customerId;
  final String givenTo;
  final String amount;
  final String givenDate;
  final String returnDate;
  final String rateOfInterest;
  final String description;
  final String? receipt;
  final String status;
  final String paidAmount;

  LendModel({
    required this.id,
    required this.customerId,
    required this.givenTo,
    required this.amount,
    required this.givenDate,
    required this.returnDate,
    required this.rateOfInterest,
    required this.description,
    this.receipt,
    required this.status,
    required this.paidAmount,
  });

  factory LendModel.fromJson(Map<String, dynamic> json) {
    return LendModel(
      id: int.tryParse(json["id"].toString()) ?? 0,
      customerId: int.tryParse(json["customerId"].toString()) ?? 0,
      givenTo: json["givenTo"] ?? "",
      amount: json["amount"] ?? "0",
      givenDate: json["givenDate"] ?? "",
      returnDate: json["returnDate"] ?? "",
      rateOfInterest: json["rateOfInterest"] ?? "0",
      description: json["description"] ?? "",
      receipt: json["receipt"],
      status: json["status"] ?? "0",
      paidAmount: json["paidAmount"] ?? "0",
    );
  }
}