class CategoryModel {
  final int id;
  final String name;
  final String type;
  final String image;

  CategoryModel({
    required this.id,
    required this.name,
    required this.type,
    required this.image,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: int.parse(json["id"]),
      name: json["categoryName"] ?? "",
      type: json["categoryType"] ?? "",
      image: json["categoryImg"] ?? "",
    );
  }
}

class CategoryResponse {
  final String status;
  final int code;
  final String message;
  final List<CategoryModel> data;

  CategoryResponse({
    required this.status,
    required this.code,
    required this.message,
    required this.data,
  });

  factory CategoryResponse.fromJson(Map<String, dynamic> json) {
    return CategoryResponse(
      status: json["status"] ?? "",
      code: json["code"] ?? 0,
      message: json["message"] ?? "",
      data: (json["data"] as List)
          .map((e) => CategoryModel.fromJson(e))
          .toList(),
    );
  }
}