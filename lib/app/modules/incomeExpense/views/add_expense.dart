import 'package:budgetbook_2026/app/core/constant/app_url.dart';
import 'package:budgetbook_2026/app/core/theme/app_colors.dart';
import 'package:budgetbook_2026/app/core/utils/app_form_validators.dart';
import 'package:budgetbook_2026/app/modules/incomeExpense/controllers/add_expense_controller.dart';
import 'package:budgetbook_2026/app/modules/incomeExpense/controllers/expense_controller.dart';
import 'package:budgetbook_2026/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class AddExpenseView extends StatelessWidget {
  AddExpenseView({super.key});

  final _formKey = GlobalKey<FormState>();

  final amountController = TextEditingController();
  final descriptionController = TextEditingController();

  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxString receiptPath = "".obs;
  final RxInt selectedCategory = (-1).obs;

  final controller = Get.put(AddExpenseController());
  final mainController = Get.find<ExpenseController>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text("Insert Expense")),

      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ================= CATEGORY =================
              _categoryHeader(isDark),
              SizedBox(height: 14.h),

              Obx(() => Wrap(
                    spacing: 10.w,
                    runSpacing: 10.h,
                    children: List.generate(
                      mainController.expenseCategories.length,
                      (index) {
                        final item =
                            mainController.expenseCategories[index];
                        final selected = selectedCategory.value == index;

                        return GestureDetector(
                          onTap: () => selectedCategory.value = index,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            padding: EdgeInsets.symmetric(
                                horizontal: 14.w, vertical: 10.h),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18.r),

                              /// 🔥 RED GRADIENT
                              gradient: selected
                                  ? const LinearGradient(
                                      colors: [
                                        Color(0xFFFF6B6B),
                                        Color(0xFFFF9A9A),
                                      ],
                                    )
                                  : null,

                              color: selected
                                  ? null
                                  : (isDark
                                      ? Colors.white.withOpacity(.05)
                                      : Colors.grey.withOpacity(.1)),

                              border: Border.all(
                                color: selected
                                    ? Colors.transparent
                                    : Colors.grey.withOpacity(.2),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6.r),
                                  child: item.image.isNotEmpty
                                      ? Image.network(
                                          AppUrl.getImageUrl(item.image),
                                          width: 18.w,
                                          height: 18.w,
                                          fit: BoxFit.cover,
                                        
                                          errorBuilder: (_, __, ___) => Icon(
                                            Icons.category,
                                            size: 16.sp,
                                            color: selected
                                                ? Colors.white
                                                : Colors.grey,
                                          ),
                                        )
                                      : Icon(
                                          Icons.category,
                                          size: 16.sp,
                                          color: selected
                                              ? Colors.white
                                              : Colors.grey,
                                        ),
                                ),
                                SizedBox(width: 6.w),
                                Text(
                                  item.name,
                                  style: TextStyle(
                                    fontFamily: "BalooBhai2",
                                    fontSize: 13.sp,
                                    color: selected
                                        ? Colors.white
                                        : theme.textTheme.bodyMedium!.color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  )),

              SizedBox(height: 26.h),

              /// ================= AMOUNT =================
              Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Enter Amount",
                      style: TextStyle(fontSize: 13.sp),
                    ),
                    SizedBox(height: 8.h),

                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: Colors.redAccent.withOpacity(.4),
                        ),
                      ),
                      child: TextFormField(
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        validator: (v) =>
                            v == null || v.isEmpty ? "Enter amount" : null,
                        decoration: const InputDecoration(
                          filled: false,
                          prefixText: "₹ ",
                          border: InputBorder.none,
                          hintText: "0",
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24.h),

              /// ================= NOTE =================
             _glassCard(
  isDark,
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      /// 🔥 TITLE (same as income)
      Text(
        "Add Note",
        style: TextStyle(
          fontFamily: "BalooBhai2",
          fontSize: 13.sp,
          color: theme.textTheme.bodySmall!.color,
        ),
      ),

      SizedBox(height: 6.h),

      /// 🔥 INPUT FIELD
      TextFormField(
        controller: descriptionController,
        maxLength: 100,
        validator: (v) => AppValidators.description(v ?? ""),
        style: TextStyle(
          fontFamily: "BalooBhai2",
          fontSize: 14.sp,
        ),
        decoration: const InputDecoration(
          hintText: "Eg: Food, Travel...",
          border: InputBorder.none,
          counterText: "", // 🔥 hides counter
        ),
      ),
    ],
  ),
),
              SizedBox(height: 16.h),

              /// ================= DATE + RECEIPT =================
              Column(
                children: [
                  Obx(() => _actionCard(
                        icon: Icons.calendar_today,
                        title: "Date",
                        subtitle: "${selectedDate.value}".split(' ')[0],
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate.value,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );

                          if (picked != null) selectedDate.value = picked;
                        },
                      )),

                  SizedBox(height: 12.h),

                  Obx(() => _actionCard(
                        icon: Icons.image,
                        title: "Attachment",
                        subtitle: receiptPath.value.isEmpty
                            ? "Add receipt"
                            : "Attached ✓",
                        onTap: () async {
                          final picker = ImagePicker();
                          final file = await picker.pickImage(
                              source: ImageSource.gallery);

                          if (file != null) {
                            receiptPath.value = file.path;
                          }
                        },
                      )),
                ],
              ),

              SizedBox(height: 30.h),

              /// ================= SUBMIT =================
              Obx(() => SizedBox(
                    width: double.infinity,
                    height: 52.h,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B6B),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.r),
                        ),
                      ),
                      onPressed: controller.isLoading.value
                          ? null
                          : () {
                              if (!_formKey.currentState!.validate()) return;

                              if (selectedCategory.value == -1) {
                                Get.snackbar("Error", "Select category");
                                return;
                              }

                              final categoryId = mainController
                                  .expenseCategories[selectedCategory.value]
                                  .id;

                              controller.submit(
                                categoryId: categoryId,
                                amount: amountController.text,
                                date: selectedDate.value,
                                description: descriptionController.text,
                                receiptPath: receiptPath.value.isEmpty
                                    ? null
                                    : receiptPath.value,
                              );
                            },
                      child: controller.isLoading.value
                          ? const CircularProgressIndicator(
                              color: Colors.white)
                          : const Text("Submit",style: TextStyle( fontFamily: "BalooBhai2",color: Colors.white),),
                    ),
                  )),

              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  // Helper Widgets
  
  Widget _categoryHeader(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Select Category",
          style: TextStyle(
            fontFamily: "BalooBhai2",
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
          ),
        ),

        /// 🔥 ADD BUTTON (PRO STYLE)
        InkWell(
          borderRadius: BorderRadius.circular(12.r),
          onTap: () {
            Get.toNamed(
  Routes.PostExpenseCategory,
  arguments: "Expense", // 🔥 THIS IS MISSING
);
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              color: isDark
                  ? Colors.white.withOpacity(.05)
                  : Colors.grey.withOpacity(.08),
              border: Border.all(color: AppColors.primary.withOpacity(.4)),
            ),
            child: Row(
              children: [
                Icon(Icons.add, size: 16.sp, color: AppColors.primary),
                SizedBox(width: 4.w),
                Text(
                  "Category",
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
        ),
      ],
    );
  }

  /// ================= HELPERS =================

  Widget _actionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18.r),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18.r),
          color: Colors.transparent,
          border: Border.all(color: Colors.grey.withOpacity(.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(.1),
              ),
              child: Icon(icon, color: AppColors.primary),
            ),

            SizedBox(width: 12.w),

            /// TEXT
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey,
                    fontFamily: "BalooBhai2",
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    fontFamily: "BalooBhai2",
                  ),
                ),
              ],
            ),

            const Spacer(),

            const Icon(Icons.arrow_forward_ios, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _glassCard(bool isDark, {required Widget child}) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18.r),
        color: isDark
            ? Colors.white.withOpacity(.05)
            : Colors.grey.withOpacity(.08),
        border: Border.all(color: Colors.grey.withOpacity(.15)),
      ),
      child: child,
    );
  }

}