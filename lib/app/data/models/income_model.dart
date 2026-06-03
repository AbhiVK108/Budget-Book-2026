class IncomeModel {
  final String id;
  final String customerId;
  final String categoryId;
  final String amount;
  final DateTime incomeDate;
  final String description;
  final String? receipt;
  final String status;
  final String categoryType;
  final String categoryName;
  final String categoryImg;

  IncomeModel({
    required this.id,
    required this.customerId,
    required this.categoryId,
    required this.amount,
    required this.incomeDate,
    required this.description,
    this.receipt,
    required this.status,
    required this.categoryType,
    required this.categoryName,
    required this.categoryImg,
  });

  factory IncomeModel.fromJson(Map<String, dynamic> json) {
    return IncomeModel(
      id: json['id'].toString(),
      customerId: json['customerId'].toString(),
      categoryId: json['categoryId'].toString(),
      amount: json['amount'].toString(),
      incomeDate: DateTime.parse(json['incomeDate']),
      description: json['description'] ?? '',
      receipt: json['receipt'],
      status: json['status'] ?? '',
      categoryType: json['categoryType'] ?? '',
      categoryName: json['categoryName'] ?? '',
      categoryImg: json['categoryImg'] ?? '',
    );
  }
}

// Total Response Model
class IncomeResponse {
  final String status;
  final int code;
  final String message;
  final List<IncomeModel> data;
  final double totalAmount;

  IncomeResponse({
    required this.status,
    required this.code,
    required this.message,
    required this.data,
    required this.totalAmount,
  });

  factory IncomeResponse.fromJson(Map<String, dynamic> json) {
    return IncomeResponse(
      status: json['status'] ?? '',
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      data: (json['data'] as List? ?? [])
          .map((e) => IncomeModel.fromJson(e))
          .toList(),
      totalAmount: (json['data1'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
