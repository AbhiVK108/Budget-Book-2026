import 'package:budgetbook_2026/app/data/models/lend_model.dart';
import 'package:budgetbook_2026/app/data/repositories/lend_repo.dart';
import 'package:get/get.dart';

class LendController extends GetxController {
  final LendRepository _repo = LendRepository();

  final isLoading = false.obs;
  final lendList = <LendModel>[].obs;
  final isDeleteLoading = false.obs;


    /// 🔥 DELETE
  Future<void> deleteLend(int id) async {
    try {
      isDeleteLoading.value = true;

      final success = await _repo.deleteLend(id);

      if (success) {
        lendList.removeWhere((e) => e.id == id);
        Get.snackbar("Success", "Deleted successfully");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isDeleteLoading.value = false;
    }
  }


  /// 🔹 FETCH LEND DATA
 
Future<void> fetchLends() async {
  try {
    isLoading.value = true;

    final response = await _repo.getLends();

    lendList.value = response.data;

    applyFilter(); // 🔥 VERY IMPORTANT
  } catch (e) {
    Get.snackbar("Error", e.toString());
  } finally {
    isLoading.value = false;
  }
}

  double getTotalLendAmount() {
    return lendList.fold(
      0,
      (sum, item) => sum + (double.tryParse(item.amount) ?? 0),
    );
  }

  double getTotalPendingAmount() {
    return lendList.fold(
      0,
      (sum, item) =>
          sum +
          ((double.tryParse(item.amount) ?? 0) -
              (double.tryParse(item.paidAmount) ?? 0)),
    );
  }

  // Filtering Lends
  var selectedFilter = 0.obs;

final filters = ["All", "7 Days", "This Month", "Custom"];

DateTime? startDate;
DateTime? endDate;

final filteredList = <LendModel>[].obs;

void applyFilter() {
  final now = DateTime.now();

  if (selectedFilter.value == 0) {
    /// ✅ FIX: create new list (important)
    filteredList.value = List.from(lendList);
  } 
  else if (selectedFilter.value == 1) {
    /// 🔥 LAST 7 DAYS
    filteredList.value = lendList.where((item) {
      final date = DateTime.parse(item.givenDate);
      return now.difference(date).inDays <= 7;
    }).toList();
  } 
  else if (selectedFilter.value == 2) {
    /// 🔥 THIS MONTH
    filteredList.value = lendList.where((item) {
      final date = DateTime.parse(item.givenDate);
      return date.month == now.month && date.year == now.year;
    }).toList();
  } 
  else if (selectedFilter.value == 3 &&
      startDate != null &&
      endDate != null) {
    
    /// 🔥 CUSTOM RANGE (FIXED)
    filteredList.value = lendList.where((item) {
      final date = DateTime.parse(item.givenDate);

      return (date.isAfter(startDate!) || date.isAtSameMomentAs(startDate!)) &&
             (date.isBefore(endDate!) || date.isAtSameMomentAs(endDate!));
    }).toList();
  }
}

  @override
  void onInit() {
    fetchLends(); // 🔥 auto load
    super.onInit();
  }

  
}
