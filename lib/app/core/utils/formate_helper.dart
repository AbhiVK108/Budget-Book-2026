import 'package:intl/intl.dart';

class FormatHelper {
  /// 👉 Standard INR format (₹1,00,000)
  static String formatINR(num amount) {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  /// 👉 Compact format (1.2K, 3.5L, 2Cr)
  static String formatCompact(num amount) {
    if (amount >= 10000000) {
      // Crore
      return "${(amount / 10000000).toStringAsFixed(2)}Cr";
    } else if (amount >= 100000) {
      // Lakh
      return "${(amount / 100000).toStringAsFixed(2)}L";
    } else if (amount >= 1000) {
      // Thousand
      return "${(amount / 1000).toStringAsFixed(1)}K";
    } else {
      return amount.toStringAsFixed(0);
    }
  }

  // Date
  
 static String formatDate(String date) {
  final parsedDate = DateTime.parse(date);
  return DateFormat('d MMM yyyy').format(parsedDate);
}

}