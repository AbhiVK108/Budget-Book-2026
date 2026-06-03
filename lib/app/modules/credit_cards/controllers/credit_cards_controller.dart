import 'package:budgetbook_2026/app/modules/credit_cards/views/credit_cards_view.dart';
import 'package:get/get.dart';

class CreditCardsController extends GetxController {
var cards = <CardModel>[].obs;

  @override
  void onInit() {
    super.onInit();

    /// 🔥 Dummy now → Replace with API later
    cards.addAll([
      CardModel(
          bank: "HDFC Bank",
          number: "**** 4589",
          used: 45000,
          limit: 80000,
          dueDate: "12 Apr"),
      CardModel(
          bank: "ICICI Bank",
          number: "**** 2231",
          used: 12000,
          limit: 50000,
          dueDate: "08 Apr"),
    ]);
  }

  double get totalUsed =>
      cards.fold(0, (sum, item) => sum + item.used);

  double get totalLimit =>
      cards.fold(0, (sum, item) => sum + item.limit);
}
