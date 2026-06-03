import 'package:budgetbook_2026/app/data/repositories/chit_api_repo.dart';
import 'package:get/get.dart';
import 'package:budgetbook_2026/app/data/models/chit_model.dart';

class ChitFundsController extends GetxController {
  final ChitRepository _repo = ChitRepository();

  var isLoading = false.obs;
  var isDeleteLoading = false.obs;

  var chits = <ChitModel>[].obs;

  /// 🔥 FETCH CHITS
  Future<void> fetchChits() async {
    try {
      isLoading.value = true;

      final res = await _repo.getChits();
      chits.value = res.data ?? [];
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// 🔥 DELETE CHIT
Future<void> deleteChit(int id) async {
  try {
    isDeleteLoading.value = true;

    final success = await _repo.deleteChit(id);

    if (success) {
      Get.snackbar("Success", "Chit deleted");

      /// 🔥 REFRESH FROM API
      await fetchChits();
    }
  } catch (e) {
    Get.snackbar("Error", e.toString());
  } finally {
    isDeleteLoading.value = false;
  }
}

  /// 🔥 CALCULATIONS (REAL DASHBOARD)
  double get totalValue => chits.fold(
    0,
    (sum, e) => sum + (double.tryParse(e.chitValue ?? "0") ?? 0),
  );

  double get totalMonthly => chits.fold(
    0,
    (sum, e) => sum + (double.tryParse(e.chitMonthly ?? "0") ?? 0),
  );

  int get activeChits => chits.where((e) => e.status == "0").length;

  @override
  void onInit() {
    fetchChits();
    super.onInit();
  }
}
