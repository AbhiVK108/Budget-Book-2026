import 'package:budgetbook_2026/app/modules/info/controllers/info_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

class Profile extends GetView<InfoController> {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SizedBox.expand(
        child: Stack(
          children: [
            ////////////////////////////////////////////////////////////
            /// Gradient Header
            ////////////////////////////////////////////////////////////
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 220.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? const [Color(0xFF1C1C28), Color(0xFF2A2A3C)]
                        : const [Colors.white, Color(0xFFF3F6F9)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),

            ////////////////////////////////////////////////////////////
            /// Content
            ////////////////////////////////////////////////////////////
            SafeArea(
              child: Column(
                children: [
                  SizedBox(height: 20.h),

                  Text(
                    "Account",
                    style: TextStyle(
                      fontFamily: "BalooBhai2",
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),

                  SizedBox(height: 20.h),

                  /// Avatar + Phone
                  CircleAvatar(
                    radius: 45.r,
                    backgroundColor: Colors.teal.withOpacity(.15),
                    child: Icon(Icons.person, size: 50.sp, color: Colors.teal),
                  ),

                  SizedBox(height: 12.h),

                  Text(
                    "+91 98765 43210",
                    style: TextStyle(
                      fontFamily: "BalooBhai2",
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),

                  SizedBox(height: 25.h),

                  ////////////////////////////////////////////////////////
                  /// Main Content
                  ////////////////////////////////////////////////////////
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 25.h,
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF121212) : Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30.r),
                          topRight: Radius.circular(30.r),
                        ),
                      ),
                      child: ListView(
                        children: [
                          _sectionTitle("Security"),
                          _tile(isDark, Icons.lock, "Change App PIN"),
                          _tile(
                            isDark,
                            Icons.fingerprint,
                            "Enable Biometric Login",
                          ),
                          // _tile(isDark, Icons.devices, "Manage Devices"),

                          SizedBox(height: 25.h),

                          _sectionTitle("Preferences"),
                          _tile(isDark, Icons.dark_mode, "Appearance"),
                          _tile(isDark, Icons.currency_rupee, "Currency"),
                          _tile(isDark, Icons.language, "Language"),

                          SizedBox(height: 25.h),

                          _sectionTitle("Data & Support"),
                          _tile(isDark, Icons.download, "Export Transactions"),
                          _tile(isDark, Icons.help_outline, "Help Center"),
                          _tile(isDark, Icons.info_outline, "About App"),

                          SizedBox(height: 30.h),

                          /// Logout
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14.r),
                              color: Colors.red.withOpacity(.1),
                            ),
                            child: Center(
                              child: Text(
                                "Logout",
                                style: TextStyle(
                                  fontFamily: "BalooBhai2",
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  //////////////////////////////////////////////////////////////
  /// Section Title
  //////////////////////////////////////////////////////////////
  Widget _sectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: "BalooBhai2",
          fontSize: 14.sp,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  //////////////////////////////////////////////////////////////
  /// Option Tile
  //////////////////////////////////////////////////////////////
  Widget _tile(bool isDark, IconData icon, String title) {
    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18.r),
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(.05),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.teal, size: 20.sp),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontFamily: "BalooBhai2",
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 14.sp, color: Colors.grey),
        ],
      ),
    );
  }
}
