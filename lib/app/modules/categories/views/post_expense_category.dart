import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:budgetbook_2026/app/modules/categories/controllers/categories_controller.dart';

class PostExpenseCategory extends GetView<CategoriesController> {
  PostExpenseCategory({super.key});

  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    /// 🔥 IMPORTANT: force type = Expense
    controller.categoryType = "Expense";

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Category"),
        centerTitle: true,
      ),

      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 🔥 HEADER
              Text(
                "Create Expense Category",
                style: TextStyle(
                  fontFamily: "BalooBhai2",
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),

              SizedBox(height: 6.h),

              Text(
                "Organize your expenses for better tracking",
                style: TextStyle(
                  fontFamily: "BalooBhai2",
                  fontSize: 12.sp,
                  color: theme.textTheme.bodySmall!.color,
                ),
              ),

              SizedBox(height: 20.h),

              /// 🔥 EXPENSE IMAGE
              Center(
                child: Container(
                  margin: EdgeInsets.only(top: 10.h, bottom: 20.h),
                  child: Image.asset(
                    "assets/images/expense_category.png", // 👈 use your expense image
                    height: 250.h,
                    fit: BoxFit.contain,
                    colorBlendMode: BlendMode.srcIn,
                  ),
                ),
              ),

              /// 🔥 TYPE BADGE (Expense)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30.r),
                  gradient: LinearGradient(
                    colors: [
                      Colors.redAccent.withOpacity(.15),
                      Colors.orange.withOpacity(.15),
                    ],
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.trending_down,
                      size: 16.sp,
                      color: Colors.redAccent,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      "Expense",
                      style: TextStyle(
                        fontFamily: "BalooBhai2",
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.redAccent,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20.h),

              /// 🔥 LABEL
              Text(
                "Category Name",
                style: TextStyle(
                  fontFamily: "BalooBhai2",
                  fontSize: 13.sp,
                  color: theme.textTheme.bodySmall!.color,
                ),
              ),

              SizedBox(height: 10.h),

              /// 🔥 INPUT FIELD
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.r),
                  color: isDark
                      ? Colors.white.withOpacity(.05)
                      : Colors.grey.withOpacity(.08),
                  border: Border.all(
                    color: Colors.redAccent.withOpacity(.3),
                  ),
                ),
                child: TextFormField(
                  controller: nameController,
                  maxLength: 10,
                  textAlignVertical: TextAlignVertical.center,
                  style: TextStyle(
                    fontFamily: "BalooBhai2",
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  validator: (v) =>
                      v!.trim().isEmpty ? "Enter category name" : null,
                  decoration: InputDecoration(
                    filled: false,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 14.h),

                    prefixIcon: Padding(
                      padding: EdgeInsets.only(left: 8.w, right: 8.w),
                      child: Icon(Icons.category, color: Colors.redAccent),
                    ),
                    prefixIconConstraints: BoxConstraints(
                      minHeight: 20.h,
                      minWidth: 20.w,
                    ),

                    hintText: "Eg: Food, Travel, Rent...",
                    hintStyle: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey.withOpacity(.6),
                      fontStyle: FontStyle.italic,
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

              SizedBox(height: 30.h),

              /// 🔥 SUBMIT BUTTON
              Obx(
                () => SizedBox(
                  height: 54.h,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.r),
                      ),
                      elevation: 6,
                    ),
                    onPressed: controller.isLoading.value
                        ? null
                        : () {
                            if (!_formKey.currentState!.validate()) return;

                            controller.nameController.value =
                                nameController.text;

                            controller.addCategory(); // 🔥 same API
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

              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }
}