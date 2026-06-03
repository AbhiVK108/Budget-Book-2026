import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/info_controller.dart';

class InfoView extends GetView<InfoController> {
  const InfoView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SizedBox.expand(
        child: Stack(
          children: [
            /// 🔥 Top Gradient Background
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 220.h,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.teal, Color(0xFFB2F7EF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),

            /// Content
            SafeArea(
              child: Column(
                children: [
                  SizedBox(height: 20.h),

                  /// Title
                  Text(
                    "Notifications",
                    style: TextStyle(
                      fontFamily: "BalooBhai2",
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  SizedBox(height: 25.h),

                  /// Notification List
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF121212) : Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30.r),
                          topRight: Radius.circular(30.r),
                        ),
                      ),
                      child: ListView(
                        padding: EdgeInsets.only(top: 20.h),
                        children: [
                          _notificationTile(
                            isDark: isDark,
                            title: "Budget Limit Exceeded",
                            subtitle: "You crossed your food budget by ₹1,200",
                            time: "2 min ago",
                            isUnread: true,
                          ),
                          _notificationTile(
                            isDark: isDark,
                            title: "New Feature Added 🎉",
                            subtitle: "Track your savings with smart insights",
                            time: "1 hour ago",
                          ),
                          _notificationTile(
                            isDark: isDark,
                            title: "Reminder",
                            subtitle: "Don't forget to log today’s expenses",
                            time: "Yesterday",
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
  /// Notification Tile
  //////////////////////////////////////////////////////////////

  Widget _notificationTile({
    required bool isDark,
    required String title,
    required String subtitle,
    required String time,
    bool isUnread = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(.06),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Icon
          Container(
            height: 42.w,
            width: 42.w,
            decoration: BoxDecoration(
              color: Colors.teal.withOpacity(.15),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: const Icon(Icons.notifications_active, color: Colors.teal),
          ),

          SizedBox(width: 14.w),

          /// Text Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontFamily: "BalooBhai2",
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                    Text(
                      time,
                      style: TextStyle(
                        fontFamily: "BalooBhai2",
                        fontSize: 11.sp,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: "BalooBhai2",
                    fontSize: 12.sp,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),

          /// Unread Dot
          if (isUnread)
            Container(
              margin: EdgeInsets.only(left: 6.w, top: 6.h),
              height: 8.w,
              width: 8.w,
              decoration: const BoxDecoration(
                color: Colors.teal,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}
