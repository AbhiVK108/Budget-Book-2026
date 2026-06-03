import 'package:budgetbook_2026/app/core/storage/token_manager.dart';
import 'package:budgetbook_2026/app/core/theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await TokenManager().init();

  // Static Token Later Save token from Login Response
  await TokenManager().setToken(
    "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJjdXN0b21lciIsImxvZ2luSWQiOiIzMiIsImlhdCI6MTc3NjA1ODc4MiwiZXhwIjoxNzc2MDYyMzgyfQ.qOEssv3eLOWzPQKCVgb2zy_GvXX2OVLr3v6uVcJLusY",
  );
  
  await Firebase.initializeApp();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  /// Edge-to-Edge UI
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return const RootApp();
      },
    );
  }
}

class RootApp extends StatelessWidget {
  const RootApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Application",

      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,

      themeMode: ThemeMode.system,

      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,

      builder: (context, child) {
        final paddingTop = MediaQuery.of(context).padding.top;
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Stack(
          children: [
            Container(
              height: paddingTop,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF0F2027), const Color(0xFF203A43)]
                      : [const Color(0xFF0FB9B1), const Color(0xFFB2F7EF)],
                ),
              ),
            ),

            SafeArea(
              top: false, 
              bottom: true,
              child: child ?? const SizedBox(),
            ),
          ],
        );
      },
    );
  }
}
