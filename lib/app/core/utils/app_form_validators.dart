class AppValidators {
  static String? amount(String value) {
    if (value.isEmpty) return "Amount is required";

    final parsed = double.tryParse(value);
    if (parsed == null) return "Invalid amount";

    if (parsed <= 0) return "Amount must be greater than 0";

    if (parsed > 10000000) return "Max limit is ₹1Cr";

    return null;
  }

  static String? description(String value) {
    if (value.length > 100) return "Max 100 characters allowed";
    return null;
  }
}