import 'package:budgetbook_2026/app/core/constant/app_url.dart';
import 'package:budgetbook_2026/app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../controllers/expense_edit_controller.dart';

class ExpenseEditView extends GetView<ExpenseEditController> {
  ExpenseEditView({super.key});

  final _formKey = GlobalKey<FormState>();

  final TextEditingController amountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxString receiptPath = "".obs;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final args = Get.arguments ?? {};

    final int expenseId = int.tryParse(args["id"].toString()) ?? 0;
    final int categoryId = int.tryParse(args["categoryId"].toString()) ?? 0;

    final String amount = args["amount"]?.toString() ?? "";
    final String description = args["description"]?.toString() ?? "";
    final String dateString = args["date"]?.toString() ?? "";

    amountController.text = amount;
    descriptionController.text = description;

    if (dateString.isNotEmpty) {
      selectedDate.value = DateTime.parse(dateString);
    }

    controller.fetchExpenseCategories(categoryId);

    return Scaffold(
      appBar: AppBar(title: const Text("Modify Expense")),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ================= CATEGORY =================
              _categoryHeader(),

              SizedBox(height: 14.h),

              Obx(() {
                return Wrap(
                  spacing: 10.w,
                  runSpacing: 10.h,
                  children: List.generate(controller.expenseCategories.length, (
                    index,
                  ) {
                    final item = controller.expenseCategories[index];
                    final selected =
                        controller.selectedCategoryIndex.value == index;

                    return GestureDetector(
                      onTap: () =>
                          controller.selectedCategoryIndex.value = index,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 10.h,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18.r),
                          gradient: selected
                              ? LinearGradient(
                                  colors: [
                                    const Color(0xFFFF6B6B),
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
                            /// CATEGORY IMAGE
                            Container(
                              height: 18.h,
                              width: 18.w,
                              margin: EdgeInsets.only(right: 6.w),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6.r),
                                child: Image.network(
                                  AppUrl.getImageUrl(
                                    item.image,
                                  ), // 👈 your image path
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Icon(Icons.category, size: 16.sp),
                                ),
                              ),
                            ),

                            /// CATEGORY NAME
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
                  }),
                );
              }),

              SizedBox(height: 26.h),

              /// ================= AMOUNT =================
              Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Enter Amount",
                      style: TextStyle(
                        fontFamily: "BalooBhai2",
                        fontSize: 13.sp,
                        color: theme.textTheme.bodySmall!.color,
                      ),
                    ),

                    SizedBox(height: 8.h),

                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: const Color(0xFFFF6B6B).withOpacity(.3),
                        ),
                      ),
                      child: TextFormField(
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: "BalooBhai2",
                          fontSize: 28.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLength: 10,
                        validator: (v) =>
                            v == null || v.isEmpty ? "Enter amount" : null,
                        decoration: const InputDecoration(
                          filled: false,
                          border: InputBorder.none,
                          counterText: "",
                          hintText: "0",
                          prefixText: "₹ ",
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24.h),

              /// ================= DESCRIPTION =================
              _glassCard(
                isDark,
                child: TextFormField(
                  controller: descriptionController,
                  maxLength: 100,
                  decoration: const InputDecoration(
                    filled: false,
                    border: InputBorder.none,
                    hintText: "Add note...",
                    counterText: "",
                  ),
                ),
              ),

              SizedBox(height: 16.h),

              /// ================= DATE =================
              Obx(() {
                return _actionCard(
                  icon: Icons.calendar_today,
                  title: "Date",
                  subtitle: "${selectedDate.value.toLocal()}".split(' ')[0],
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate.value,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );

                    if (picked != null) {
                      selectedDate.value = picked;
                    }
                  },
                );
              }),

              SizedBox(height: 12.h),

              /// ================= RECEIPT =================
              Obx(() {
                return _actionCard(
                  icon: Icons.image,
                  title: "Receipt",
                  subtitle: receiptPath.value.isEmpty
                      ? "Optional"
                      : "Attached ✓",
                  onTap: () async {
                    final picker = ImagePicker();
                    final file = await picker.pickImage(
                      source: ImageSource.gallery,
                    );

                    if (file != null) {
                      receiptPath.value = file.path;
                    }
                  },
                );
              }),

              SizedBox(height: 30.h),

              /// ================= SUBMIT =================
              Obx(() {
                return SizedBox(
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

                            if (controller.selectedCategoryIndex.value == -1) {
                              Get.snackbar("Error", "Select category");
                              return;
                            }

                            final categoryId = controller
                                .expenseCategories[controller
                                    .selectedCategoryIndex
                                    .value]
                                .id;

                            controller.submit(
                              id: expenseId,
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
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            "Submit",
                            style: TextStyle(
                              fontFamily: "BalooBhai2",
                              fontSize: 15.sp,
                              color: Colors.white,
                            ),
                          ),
                  ),
                );
              }),

              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  /// HEADER
  Widget _categoryHeader() {
    return Text(
      "Select Category",
      style: TextStyle(
        fontFamily: "BalooBhai2",
        fontSize: 15.sp,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  /// ACTION CARD
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
          border: Border.all(color: Colors.grey.withOpacity(.2)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFFFF6B6B).withOpacity(.1),
              child: Icon(icon, color: const Color(0xFFFF6B6B)),
            ),
            SizedBox(width: 12.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: "BalooBhai2",
                    fontSize: 12.sp,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: "BalooBhai2",
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
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

  /// GLASS CARD
  Widget _glassCard(bool isDark, {required Widget child}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
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
