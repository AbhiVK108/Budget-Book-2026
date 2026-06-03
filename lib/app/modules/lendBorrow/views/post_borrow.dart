import 'package:budgetbook_2026/app/modules/incomeExpense/views/income.dart'
    as FormatHelper;
import 'package:budgetbook_2026/app/modules/lendBorrow/controllers/post_borrow_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:image_picker/image_picker.dart';

class PostBorrow extends GetView<PostBorrowController> {
  PostBorrow({super.key});

  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final amountController = TextEditingController();
  final interestController = TextEditingController();
  final descriptionController = TextEditingController();

  final Rx<DateTime> receiveDate = DateTime.now().obs;
  final Rx<DateTime> returnDate = DateTime.now().obs;
  final RxString receiptPath = "".obs;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text("Insert Borrow")),

      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// PERSON
              _sectionTitle("Received From"),
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

              /// AMOUNT
              Center(
                child: Column(
                  children: [
                    Text(
                      "Enter Amount",
                      style: TextStyle(fontFamily: "BalooBhai2"),
                    ),
                    SizedBox(height: 8.h),

                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: Colors.orange.withOpacity(.4),
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

                          border: InputBorder.none,
                          prefixText: "₹",
                          hintText: "0",
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24.h),

              /// INTEREST
              _sectionTitle("Interest (%)"),
              SizedBox(height: 8.h),

              _glassCard(
                isDark,
                child: TextFormField(
                  controller: interestController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    filled: false,
                    hintText: "Interest rate",
                    hintStyle: TextStyle(fontFamily: "BalooBhai2"),
                    border: InputBorder.none,
                  ),
                ),
              ),

              SizedBox(height: 20.h),

              /// DESCRIPTION
              _glassCard(
                isDark,
                child: TextFormField(
                  controller: descriptionController,
                  maxLength: 100,
                  decoration: const InputDecoration(
                    filled: false,
                    hintText: "Add note...",
                    border: InputBorder.none,
                    hintStyle: TextStyle(fontFamily: "BalooBhai2"),
                    counterText: "",
                  ),
                ),
              ),

              SizedBox(height: 16.h),

              Row(
                children: [
                  /// RECEIVE DATE
                  Expanded(
                    child: Obx(() {
                      return _actionCard(
                        icon: Icons.calendar_today,
                        title: "Receive",
                        subtitle: FormatHelper.formatDate(
                          receiveDate.value.toString(),
                        ),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: receiveDate.value,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );

                          if (picked != null) receiveDate.value = picked;
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

              /// RECEIPT
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
                  backgroundColor: Colors.orangeAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.r),
                  ),
                ),
                onPressed: controller.isLoading.value
                    ? null
                    : () {
                        if (!_formKey.currentState!.validate()) return;

                        controller.createBorrow(
                          receiveFrom: nameController.text,
                          amount: amountController.text,
                          receiveDate: receiveDate.value.toString().split(
                            " ",
                          )[0],
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
                          fontFamily: "BalooBhai2",
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        );
      }),
    );
  }

  /// HELPERS
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
              backgroundColor: Colors.orangeAccent.withOpacity(.1),
              child: Icon(icon, color: Colors.orangeAccent),
            ),
            SizedBox(width: 12.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontFamily: "BalooBhai2")),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
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
      ),
      child: child,
    );
  }
}
