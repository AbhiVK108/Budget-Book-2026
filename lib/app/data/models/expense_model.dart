class ExpenseModel {
  final String id;
  final String customerId;
  final String categoryId;
  final String amount;
  final DateTime expenseDate; // 🔥 changed
  final String description;
  final String? receipt;
  final String status;
  final String categoryType;
  final String categoryName;
  final String categoryImg;

  ExpenseModel({
    required this.id,
    required this.customerId,
    required this.categoryId,
    required this.amount,
    required this.expenseDate,
    required this.description,
    this.receipt,
    required this.status,
    required this.categoryType,
    required this.categoryName,
    required this.categoryImg,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'].toString(),
      customerId: json['customerId'].toString(),
      categoryId: json['categoryId'].toString(),
      amount: json['amount'].toString(),

      /// 🔥 KEY CHANGE
      expenseDate: DateTime.parse(json['expenseDate']),

      description: json['description'] ?? '',
      receipt: json['receipt'],
      status: json['status'] ?? '',
      categoryType: json['categoryType'] ?? '',
      categoryName: json['categoryName'] ?? '',
      categoryImg: json['categoryImg'] ?? '',
    );
  }
}

class ExpenseResponse {
  final String status;
  final int code;
  final String message;
  final List<ExpenseModel> data;
  final double totalAmount;

  ExpenseResponse({
    required this.status,
    required this.code,
    required this.message,
    required this.data,
    required this.totalAmount,
  });

  factory ExpenseResponse.fromJson(Map<String, dynamic> json) {
    return ExpenseResponse(
      status: json['status'] ?? '',
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      data: (json['data'] as List? ?? [])
          .map((e) => ExpenseModel.fromJson(e))
          .toList(),

      /// 🔥 SAME KEY AS INCOME
      totalAmount: (json['data1'] as num?)?.toDouble() ?? 0.0,
    );
  }
}