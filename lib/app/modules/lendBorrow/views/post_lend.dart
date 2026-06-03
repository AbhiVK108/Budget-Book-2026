import 'package:budgetbook_2026/app/core/theme/app_colors.dart';
import 'package:budgetbook_2026/app/core/utils/formate_helper.dart';
import 'package:budgetbook_2026/app/modules/lendBorrow/controllers/post_lend_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class PostLend extends GetView<PostLendController> {
  PostLend({super.key});

  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final amountController = TextEditingController();
  final interestController = TextEditingController();
  final descriptionController = TextEditingController();

  final Rx<DateTime> givenDate = DateTime.now().obs;
  final Rx<DateTime> returnDate = DateTime.now().obs;
  final RxString receiptPath = "".obs;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text("Insert Lent")),

      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ================= PERSON =================
              _sectionTitle("Person Name"),
              SizedBox(height: 8.h),

              _glassCard(
                isDark,
                child: TextFormField(
                  controller: nameController,
                  validator: (v) =>
                      v == null || v.isEmpty ? "Enter name" : null,
                  decoration: const InputDecoration(
                    filled: false,
                    hintText: "Enter person name",
                    hintStyle: TextStyle(fontFamily: "BalooBhai2"),
                    border: InputBorder.none,
                  ),
                ),
              ),

              SizedBox(height: 20.h),

              /// ================= AMOUNT (HERO UI) =================
              Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Enter Amount",
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontFamily: "BalooBhai2",
                      ),
                    ),
                    SizedBox(height: 8.h),

                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(.3),
                        ),
                      ),
                      child: TextFormField(
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.bold,
                          fontFamily: "BalooBhai2",
                        ),
                        validator: (v) =>
                            v == null || v.isEmpty ? "Enter amount" : null,
                        decoration: const InputDecoration(
                          filled: false,
                          border: InputBorder.none,
                          hintText: "0",
                          hintStyle: TextStyle(fontFamily: "BalooBhai2"),
                          prefixText: "₹ ",
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24.h),

              /// ================= INTEREST =================
              _sectionTitle("Rate of Interest (%)"),
              SizedBox(height: 8.h),

              _glassCard(
                isDark,
                child: TextFormField(
                  controller: interestController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    filled: false,
                    hintStyle: TextStyle(fontFamily: "BalooBhai2"),

                    hintText: "Intrest rate",
                    border: InputBorder.none,
                  ),
                ),
              ),

              SizedBox(height: 20.h),

              /// ================= DESCRIPTION =================
              _glassCard(
                isDark,
                child: TextFormField(
                  controller: descriptionController,
                  maxLength: 100,
                  decoration: const InputDecoration(
                    filled: false,
                    hintStyle: TextStyle(fontFamily: "BalooBhai2"),

                    hintText: "Add note...",
                    border: InputBorder.none,
                    counterText: "",
                  ),
                ),
              ),

              SizedBox(height: 16.h),

              /// ================= GIVEN DATE =================
              Row(
                children: [
                  /// GIVEN DATE
                  Expanded(
                    child: Obx(() {
                      return _actionCard(
                        icon: Icons.calendar_today,
                        title: "Given",
                        subtitle: FormatHelper.formatDate(
                          givenDate.value.toString(),
                        ),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: givenDate.value,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );

                          if (picked != null) givenDate.value = picked;
                        },
                      );
                    }),
                  ),

                  SizedBox(width: 10.w),

                  /// RETURN DATE
                  Expanded(
                    child: Obx(() {
                      return _actionCard(
                        icon: Icons.event,
                        title: "Return",
                        subtitle: FormatHelper.formatDate(
                          returnDate.value.toString(),
                        ),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: returnDate.value,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );

                          if (picked != null) returnDate.value = picked;
                        },
                      );
                    }),
                  ),
                ],
              ),
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
            ],
          ),
        ),
      ),
      bottomNavigationBar: Obx(() {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: SizedBox(
              height: 52.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.r),
                  ),
                ),
                onPressed: controller.isLoading.value
                    ? null
                    : () {
                        if (!_formKey.currentState!.validate()) return;

                        controller.createLend(
                          givenTo: nameController.text,
                          amount: amountController.text,
                          givenDate: givenDate.value.toString().split(" ")[0],
                          rateOfInterest: interestController.text.isEmpty
                              ? "0"
                              : interestController.text,
                          returnDate: returnDate.value.toString().split(" ")[0],
                          description: descriptionController.text,
                          receiptPath: receiptPath.value.isEmpty
                              ? null
                              : receiptPath.value,
                        );
                      },
                child: controller.isLoading.value
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        "Save",
                        style: TextStyle(
                          fontSize: 15.sp,
                          color: Colors.white,
                          fontFamily: "BalooBhai2",
                        ),
                      ),
              ),
            ),
          ),
        );
      }),
    );
  }

  /// ================= HELPERS =================

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        fontFamily: "BalooBhai2",
      ),
    );
  }

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
              backgroundColor: AppColors.primary.withOpacity(.1),
              child: Icon(icon, color: AppColors.primary),
            ),
            SizedBox(width: 12.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 12.sp, fontFamily: "BalooBhai2"),
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
          ],
        ),
      ),
    );
  }

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
