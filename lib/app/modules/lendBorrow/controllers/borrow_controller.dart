import 'package:budgetbook_2026/app/data/models/borrow_model.dart';
import 'package:budgetbook_2026/app/data/repositories/borrow_repo.dart';
import 'package:get/get.dart';

class BorrowController extends GetxController {
  final BorrowRepository _repo = BorrowRepository();

  final isLoading = false.obs;
  final borrowList = <BorrowModel>[].obs;
  final isDeleteLoading = false.obs;

  /// 🔥 DELETE
  Future<void> deleteBorrow(int id) async {
    try {
      isDeleteLoading.value = true;

      final success = await _repo.deleteBorrow(id);

      if (success) {
        borrowList.removeWhere((e) => e.id == id);
        Get.snackbar("Success", "Deleted successfully");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isDeleteLoading.value = false;
    }
  }

  /// 🔹 FETCH BORROW DATA
  Future<void> fetchBorrows() async {
    try {
      isLoading.value = true;

      final response = await _repo.getBorrows();

      borrowList.value = response.data;

      applyFilter(); // 🔥 VERY IMPORTANT
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// 🔥 TOTAL BORROWED
  double getTotalBorrowAmount() {
    return borrowList.fold(
      0,
      (sum, item) => sum + (double.tryParse(item.amount) ?? 0),
    );
  }

  /// 🔥 TOTAL PENDING (you still owe)
 double getTotalPendingAmount() {
  return borrowList.fold(0, (sum, item) {
    double amount = double.tryParse(item.amount) ?? 0;
    double paid = double.tryParse(item.paidAmount) ?? 0;

    return sum + (amount - paid);
  });
}

double getTotalPaidAmount() {
  return borrowList.fold(
    0,
    (sum, item) => sum + (double.tryParse(item.paidAmount) ?? 0),
  );
}

  /// ================= FILTERING =================

  var selectedFilter = 0.obs;

  final filters = ["All", "7 Days", "This Month", "Custom"];

  DateTime? startDate;
  DateTime? endDate;

  final filteredList = <BorrowModel>[].obs;

void applyFilter() {
  final now = DateTime.now();

  if (selectedFilter.value == 0) {
    /// ✅ IMPORTANT: create new list
    filteredList.value = List.from(borrowList);
  } 
  else if (selectedFilter.value == 1) {
    /// 🔥 LAST 7 DAYS
    filteredList.value = borrowList.where((item) {
      final date = DateTime.parse(item.receiveDate);
      return now.difference(date).inDays <= 7;
    }).toList();
  } 
  else if (selectedFilter.value == 2) {
    /// 🔥 THIS MONTH
    filteredList.value = borrowList.where((item) {
      final date = DateTime.parse(item.receiveDate);
      return date.month == now.month && date.year == now.year;
    }).toList();
  } 
  else if (selectedFilter.value == 3 &&
      startDate != null &&
      endDate != null) {
    
    /// 🔥 CUSTOM RANGE (FIXED)
    filteredList.value = borrowList.where((item) {
      final date = DateTime.parse(item.receiveDate);

      return (date.isAfter(startDate!) || date.isAtSameMomentAs(startDate!)) &&
             (date.isBefore(endDate!) || date.isAtSameMomentAs(endDate!));
    }).toList();
  }
}

  @override
  void onInit() {
    fetchBorrows(); // 🔥 AUTO LOAD
    super.onInit();
  }
}