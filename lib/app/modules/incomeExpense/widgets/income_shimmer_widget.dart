import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class IncomeShimmerHelper {
  static Widget shimmerContainer({
    double? height,
    double? width,
    double radius = 12,
  }) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.withOpacity(0.3),
      highlightColor: Colors.grey.withOpacity(0.1),
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }

  /// 🔥 HERO CARD SHIMMER
  static Widget heroCard() {
    return Container(
      height: 260.h,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26.r),
        color: Colors.grey.withOpacity(.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          shimmerContainer(width: 100.w, height: 14.h),
          SizedBox(height: 10.h),

          shimmerContainer(width: 160.w, height: 26.h),
          SizedBox(height: 20.h),

          /// fake chart bars
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              6,
              (index) => shimmerContainer(
                width: 10.w,
                height: (20 + index * 5).toDouble(),
                radius: 6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🔥 GRID SHIMMER
  static Widget grid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
      ),
      itemBuilder: (_, __) {
        return Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18.r),
            color: Colors.grey.withOpacity(.2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              shimmerContainer(height: 30.w, width: 30.w, radius: 50),
              SizedBox(height: 8.h),
              shimmerContainer(height: 10.h, width: 50.w),
              SizedBox(height: 6.h),
              shimmerContainer(height: 12.h, width: 40.w),
            ],
          ),
        );
      },
    );
  }

  /// 🔥 LIST SHIMMER (MATCH YOUR CARD UI)
  static Widget list() {
    return Column(
      children: List.generate(
        5,
        (index) => Container(
          margin: EdgeInsets.only(bottom: 12.h),
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18.r),
            color: Colors.grey.withOpacity(.2),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ICON
              shimmerContainer(height: 40.w, width: 40.w, radius: 12),

              SizedBox(width: 12.w),

              /// TEXT
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    shimmerContainer(width: 80.w, height: 12.h),
                    SizedBox(height: 6.h),
                    shimmerContainer(width: double.infinity, height: 10.h),
                  ],
                ),
              ),

              SizedBox(width: 10.w),

              /// RIGHT SIDE
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  shimmerContainer(width: 50.w, height: 10.h),
                  SizedBox(height: 6.h),
                  shimmerContainer(width: 60.w, height: 14.h),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}