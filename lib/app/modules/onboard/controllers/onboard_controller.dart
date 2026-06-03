import 'package:flutter/animation.dart';
import 'package:get/get.dart';

class OnboardController extends GetxController
    with GetTickerProviderStateMixin {

  late AnimationController floatController;

  @override
  void onInit() {
    super.onInit();

    floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(); // infinite loop
  }

  @override
  void onClose() {
    floatController.dispose();
    super.onClose();
  }
}
