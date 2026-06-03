import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppStatusWrapper extends StatelessWidget {
  final Widget child;

  const AppStatusWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness:
            isDark ? Brightness.dark : Brightness.light,
      ),
      child: child,
    );
  }
}