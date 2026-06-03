import 'package:flutter/material.dart';

class AppColors {
  /// Gradient for onboarding / buttons
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [
      Color(0xFF00C9A7),
      Color(0xFF007C6E),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Solid colors
  static const Color primary = Color(0xFF00C9A7);
  static const Color primaryDark = Color(0xFF007C6E);

  static const Color secondary = Color(0xFF2EC4B6);
  static const Color scaffoldLight = Color(0xFFF4F7FA);
  static const Color scaffoldDark = Color(0xFF0F111A);
}
