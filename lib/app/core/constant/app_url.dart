class AppUrl {
  static const String baseUrl = 'https://s2swebsolutions.in/budgetbook/api/';
  static const String imageBaseUrl = 'https://s2swebsolutions.in/budgetbook/';

  static const String allIncome = 'income';
  static const String allExpense = 'expense'; 
  static const String allCategories = 'categories';
  static const addCategory = "categories";
  static const String lendGet = 'credit';
  static const String lendPost = 'credit';
  static const String lendUpdate = 'credit';
  static const String lendDelete = 'credit';
  static const String borrowGet = 'debit';
  static const String borrowPost = 'debit';
  static const String borrowUpdate = 'debit';
  static const String borrowDelete = 'debit';
  static const String loanGet = 'loans';
  static const String loanPost = 'loans';
  static const String loanUpdate = 'loans';
  static const String loanDelete = 'loans';
  static const String chitGet = 'chits';
  static const String chitPost = 'chits';
  static const String chitUpdate = 'chits';
  static const String chitDelete = 'chits';



  // Image Helper
  /// 🔥 Build full image URL safely
  static String getImageUrl(String? path) {
    if (path == null || path.isEmpty) return "";

    /// Already full URL
    if (path.startsWith("http")) return path;

    return imageBaseUrl + path;
  }

  /// TIMEOUT
  static const int timeout = 30;
}
