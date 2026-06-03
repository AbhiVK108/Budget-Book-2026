import 'package:budgetbook_2026/app/data/models/borrow_model.dart';
import 'package:budgetbook_2026/app/modules/lend_borrow_edit/controllers/borrow_edit_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BorrowEditView extends GetView<BorrowEditController> {
  BorrowEditView({super.key});

  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController interestController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  final Rx<DateTime> receiveDate = DateTime.now().obs;
  final Rx<DateTime> returnDate = DateTime.now().obs;
  final RxString receiptPath = "".obs;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final BorrowModel item = Get.arguments;
    final int id = int.tryParse(item.id.toString()) ?? 0;

    /// PREFILL
    nameController.text = item.receiveFrom ?? "";
    amountController.text = item.amount ?? "";
    interestController.text = item.rateOfInterest ?? "";
    descriptionController.text = item.description ?? "";

    if (item.receiveDate.isNotEmpty) {
      receiveDate.value = DateTime.parse(item.receiveDate);
    }

    if (item.returnDate.isNotEmpty) {
      returnDate.value = DateTime.parse(item.returnDate);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Modify Borrow",
          style: TextStyle(fontFamily: "BalooBhai2"),
        ),
      ),

      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// PERSON
              _sectionTitle("Person Name"),
              SizedBox(height: 8.h),

              _glassCard(
                isDark,
                child: TextFormField(
                  controller: nameController,
                  style: const TextStyle(fontFamily: "BalooBhai2"),
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
                          // prefixStyle: TextStyle(fontFamily: "BalooBhai2"),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24.h),

              /// INTEREST
              _sectionTitle("Rate of Interest (%)"),
              SizedBox(height: 8.h),

              _glassCard(
                isDark,
                child: TextFormField(
                  controller: interestController,
                  style: const TextStyle(fontFamily: "BalooBhai2"),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    filled: false,
                    hintText: "Optional",
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
                  style: const TextStyle(fontFamily: "BalooBhai2"),
                  maxLength: 100,
                  decoration: const InputDecoration(
                    filled: false,
                    hintText: "Add note...",
                    hintStyle: TextStyle(fontFamily: "BalooBhai2"),
                    border: InputBorder.none,
                    counterText: "",
                  ),
                ),
              ),

              SizedBox(height: 16.h),

              /// RECEIVE DATE
              Obx(() {
                return _actionCard(
                  icon: Icons.calendar_today,
                  title: "Receive Date",
                  subtitle: "${receiveDate.value}".split(' ')[0],
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

              SizedBox(height: 12.h),

              /// RETURN DATE
              Obx(() {
                return _actionCard(
                  icon: Icons.event,
                  title: "Return Date",
                  subtitle: "${returnDate.value}".split(' ')[0],
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

              /// UPDATE BUTTON
              Obx(() {
                return SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.r),
                      ),
                    ),
                    onPressed: controller.isUpdateLoading.value
                        ? null
                        : () {
                            if (!_formKey.currentState!.validate()) return;

                            controller.updateBorrow(
                              id: id,
                              receiveFrom: nameController.text,
                              amount: amountController.text,
                              receiveDate: receiveDate.value.toString().split(
                                " ",
                              )[0],
                              rateOfInterest: interestController.text.isEmpty
                                  ? "0"
                                  : interestController.text,
                              returnDate: returnDate.value.toString().split(
                                " ",
                              )[0],
                              description: descriptionController.text,
                              receiptPath: receiptPath.value.isEmpty
                                  ? null
                                  : receiptPath.value,
                            );
                          },
                    child: controller.isUpdateLoading.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            "Submit",
                            style: TextStyle(
                              fontSize: 15.sp,
                              color: Colors.white,
                              fontFamily: "BalooBhai2",
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

  ////////////////////////////////////////////////////

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
              backgroundColor: Colors.orange.withOpacity(.15),
              child: Icon(icon, color: Colors.orange),
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
            const Icon(Icons.arrow_forward_ios, size: 14),
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
