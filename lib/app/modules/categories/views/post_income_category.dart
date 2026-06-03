import 'package:budgetbook_2026/app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/categories_controller.dart';

class PostIncomeCategory extends GetView<CategoriesController> {
  PostIncomeCategory({super.key});

  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text("Category"), centerTitle: true),

      /// 🔥 FLOATING ACTION STYLE BUTTON
    
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 🔥 HEADER SECTION (UX IMPROVEMENT)
              Text(
                "Create Income Category",
                style: TextStyle(
                  fontFamily: "BalooBhai2",
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),

              SizedBox(height: 6.h),

              Text(
                "Organize your income sources for better tracking",
                style: TextStyle(
                  fontFamily: "BalooBhai2",
                  fontSize: 12.sp,
                  color: theme.textTheme.bodySmall!.color,
                ),
              ),

              SizedBox(height: 20.h),

              /// 🔥 INCOME ILLUSTRATION
              Center(
                child: Container(
                  margin: EdgeInsets.only(top: 10.h, bottom: 20.h),
                  child: Image.asset(
                    "assets/images/income_category.png", // 👈 your image
                    height: 250.h,
                    fit: BoxFit.contain,

                    /// Optional: better look in dark mode
                    colorBlendMode: BlendMode.srcIn,
                  ),
                ),
              ),
              // SizedBox(height: 20.h),

              /// 🔥 TYPE BADGE (UPGRADED)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30.r),
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(.15),
                      AppColors.secondary.withOpacity(.15),
                    ],
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.trending_up,
                      size: 16.sp,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      controller.categoryType, // Income
                      style: TextStyle(
                        fontFamily: "BalooBhai2",
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20.h),

              /// 🔥 INPUT LABEL
              Text(
                "Category Name",
                style: TextStyle(
                  fontFamily: "BalooBhai2",
                  fontSize: 13.sp,
                  color: theme.textTheme.bodySmall!.color,
                ),
              ),

              SizedBox(height: 10.h),

              /// 🔥 HERO INPUT FIELD (IMPROVED)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.r),
                  color: isDark
                      ? Colors.white.withOpacity(.05)
                      : Colors.grey.withOpacity(.08),
                  border: Border.all(color: AppColors.primary.withOpacity(.3)),
                ),
                child: TextFormField(
                  controller: nameController,
                  maxLength: 10,
                  textAlignVertical: TextAlignVertical.center, // ✅ FIX
                  style: TextStyle(
                    fontFamily: "BalooBhai2",
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  validator: (v) =>
                      v!.trim().isEmpty ? "Enter category name" : null,
                  decoration: InputDecoration(
                    filled: false,
                    fillColor: Colors.transparent,
                    isDense: true, // ✅ important
                    contentPadding: EdgeInsets.symmetric(vertical: 14.h),

                    prefixIcon: Padding(
                      padding: EdgeInsets.only(left: 8.w, right: 8.w),
                      child: Icon(Icons.category, color: AppColors.primary),
                    ),
                    prefixIconConstraints: BoxConstraints(
                      minHeight: 20.h,
                      minWidth: 20.w,
                    ),

                    hintText: "Eg: Salary, Freelance, Gift....",
                    hintStyle: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey.withOpacity(.6),
                      fontStyle: FontStyle.italic, // 🔥 nice touch
                    ),

                    border: InputBorder.none,
                    counterText: "",
                  ),
                ),
              ),
              SizedBox(height: 8.h),

              /// 🔥 HELPER TEXT
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.info_outline, size: 12.sp, color: Colors.grey),
                  SizedBox(width: 4.w),
                  Text(
                    "Max 10 characters",
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.grey,
                      fontFamily: "BalooBhai2",
                    ),
                  ),
                ],
              ),

              SizedBox(height: 30.h), // space for bottom button
              Obx(
          () => SizedBox(
            height: 54.h,
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.r),
                ),
                elevation: 6,
              ),
              onPressed: controller.isLoading.value
                  ? null
                  : () {
                      if (!_formKey.currentState!.validate()) return;

                      controller.nameController.value = nameController.text;

                      controller.addCategory();
                    },
              child: controller.isLoading.value
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      "Create Category",
                      style: TextStyle(
                        fontFamily: "BalooBhai2",
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ),

              SizedBox(height: 30.h), // space for bottom button


            ],
          ),
        ),
      ),
    );
  }
}
