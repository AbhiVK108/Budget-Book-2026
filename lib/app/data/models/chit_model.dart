class ChitModelResponse {
  final String status;
  final int code;
  final String message;
  final List<ChitModel> data;

  ChitModelResponse({
    required this.status,
    required this.code,
    required this.message,
    required this.data,
  });

  factory ChitModelResponse.fromJson(Map<String, dynamic> json) {
    return ChitModelResponse(
      status: json["status"] ?? "",
      code: json["code"] ?? 0,
      message: json["message"] ?? "",
      data: json["data"] is List
          ? (json["data"] as List)
              .map((e) => ChitModel.fromJson(e))
              .toList()
          : json["data"] != null
              ? [ChitModel.fromJson(json["data"])]
              : [],
    );
  }
}

class ChitModel {
  final int id;
  final int customerId;
  final String chitName;
  final String chitValue;
  final String chitStart;
  final String chitEnd;
  final String chitDuration;
  final String chitMembers;
  final String chitLift;
  final String chitLiftAmount;
  final String chitMonthly;
  final String chitMonthlyAfter;
  final String chitStatus;
  final String status;

  ChitModel({
    required this.id,
    required this.customerId,
    required this.chitName,
    required this.chitValue,
    required this.chitStart,
    required this.chitEnd,
    required this.chitDuration,
    required this.chitMembers,
    required this.chitLift,
    required this.chitLiftAmount,
    required this.chitMonthly,
    required this.chitMonthlyAfter,
    required this.chitStatus,
    required this.status,
  });

  factory ChitModel.fromJson(Map<String, dynamic> json) {
    return ChitModel(
      id: int.tryParse(json["id"].toString()) ?? 0,
      customerId: int.tryParse(json["customerId"].toString()) ?? 0,
      chitName: json["chitName"] ?? "",
      chitValue: json["chitValue"] ?? "0",
      chitStart: json["chitStart"] ?? "",
      chitEnd: json["chitEnd"] ?? "",
      chitDuration: json["chitDuration"] ?? "0",
      chitMembers: json["chitMembers"] ?? "0",
      chitLift: json["chitLift"] ?? "0",
      chitLiftAmount: json["chitLiftAmount"] ?? "0",
      chitMonthly: json["chitMonthly"] ?? "0",
      chitMonthlyAfter: json["chitMonthlyAfter"] ?? "0",
      chitStatus: json["chitStatus"] ?? "0",
      status: json["status"] ?? "0",
    );
  }
}