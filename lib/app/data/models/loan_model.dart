class LoanModelResponse {
  final String status;
  final int code;
  final String message;
  final List<LoanModel> data;

  LoanModelResponse({
    required this.status,
    required this.code,
    required this.message,
    required this.data,
  });

  factory LoanModelResponse.fromJson(Map<String, dynamic> json) {
    return LoanModelResponse(
      status: json["status"] ?? "",
      code: json["code"] ?? 0,
      message: json["message"] ?? "",
      data: (json["data"] as List? ?? [])
          .map((e) => LoanModel.fromJson(e))
          .toList(),
    );
  }
}

class LoanModel {
  final int id;
  final int customerId;
  final String nameOfLender;
  final String sanctionedAmount;
  final String dateOfDisbursement;
  final String disbursalAmount;
  final String chargesCutting;
  final String loanTerms;
  final String rateOfInterest;
  final String totalInterestAmount;
  final String instalmentAmount;
  final String startEMI;
  final String endEMI;
  final String totalAmount;
  final String loanStatus;
  final String status;

  LoanModel({
    required this.id,
    required this.customerId,
    required this.nameOfLender,
    required this.sanctionedAmount,
    required this.dateOfDisbursement,
    required this.disbursalAmount,
    required this.chargesCutting,
    required this.loanTerms,
    required this.rateOfInterest,
    required this.totalInterestAmount,
    required this.instalmentAmount,
    required this.startEMI,
    required this.endEMI,
    required this.totalAmount,
    required this.loanStatus,
    required this.status,
  });

  factory LoanModel.fromJson(Map<String, dynamic> json) {
    return LoanModel(
      id: int.tryParse(json["id"].toString()) ?? 0,
      customerId: int.tryParse(json["customerId"].toString()) ?? 0,
      nameOfLender: json["nameOfLender"] ?? "",
      sanctionedAmount: json["sanctionedAmount"] ?? "0",
      dateOfDisbursement: json["dateOfDisbursement"] ?? "",
      disbursalAmount: json["disbursalAmount"] ?? "0",
      chargesCutting: json["chargesCutting"] ?? "0",
      loanTerms: json["loanTerms"] ?? "0",
      rateOfInterest: json["rateOfInterest"] ?? "0",
      totalInterestAmount: json["totalInterestAmount"] ?? "0",
      instalmentAmount: json["instalmentAmount"] ?? "0",
      startEMI: json["startEMI"] ?? "",
      endEMI: json["endEMI"] ?? "",
      totalAmount: json["totalAmount"] ?? "0",
      loanStatus: json["loanStatus"] ?? "0",
      status: json["status"] ?? "0",
    );
  }
}