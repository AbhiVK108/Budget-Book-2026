import 'package:budgetbook_2026/app/core/utils/formate_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/post_chit_funds_controller.dart';

class PostChitFundsView extends GetView<PostChitFundsController> {
  PostChitFundsView({super.key});

  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final valueController = TextEditingController();
  final durationController = TextEditingController();
  final membersController = TextEditingController();
  final monthlyController = TextEditingController();
  final monthlyAfterController = TextEditingController();

  final Rx<DateTime> startDate = DateTime.now().obs;
  final Rx<DateTime> endDate = DateTime.now().obs;

  final RxString receiptPath = "".obs;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text("Create Chit")),

      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 🔹 CHIT NAME
              _sectionTitle("Chit Name"),
              SizedBox(height: 8.h),
              _glassCard(
                isDark,
                child: TextFormField(
                  controller: nameController,
                  validator: (v) => v!.isEmpty ? "Enter name" : null,
                  decoration: const InputDecoration(
                    filled: false,
                    border: InputBorder.none,
                    hintText: "Enter chit name",
                    hintStyle: TextStyle(fontFamily: "BalooBhai2"),
                  ),
                ),
              ),

              SizedBox(height: 20.h),

              /// 🔥 VALUE (HERO INPUT)
              Center(
                child: Column(
                  children: [
                    Text(
                      "Chit Value",
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
                          color: Color(0xFFB8E728).withOpacity(.3),
                        ),
                      ),
                      child: TextFormField(
                        controller: valueController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 26.sp,
                          fontWeight: FontWeight.bold,
                          fontFamily: "BalooBhai2",
                        ),
                        validator: (v) => v!.isEmpty ? "Enter value" : null,
                        decoration: const InputDecoration(
                    filled: false,

                          border: InputBorder.none,
                          prefixText: "₹ ",
                          hintText: "0",

                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24.h),

              /// 🔹 MEMBERS + DURATION
              Row(
                children: [
                  Expanded(
                    child: _inputCard("Members", membersController, isDark),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: _inputCard("Duration", durationController, isDark),
                  ),
                ],
              ),

              SizedBox(height: 16.h),

              /// 🔹 MONTHLY
              _inputCard("Monthly Amount", monthlyController, isDark),
              SizedBox(height: 12.h),
              _inputCard(
                "After Auction Monthly",
                monthlyAfterController,
                isDark,
              ),

              SizedBox(height: 16.h),

              /// 🔹 DATES
              Row(
                children: [
                  Expanded(
                    child: Obx(
                      () => _actionCard(
                        icon: Icons.calendar_today,
                        title: "Start",
                        subtitle: FormatHelper.formatDate(
                          startDate.value.toString(),
                        ),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: startDate.value,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) startDate.value = picked;
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Obx(
                      () => _actionCard(
                        icon: Icons.event,
                        title: "End",
                        subtitle: FormatHelper.formatDate(
                          endDate.value.toString(),
                        ),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: endDate.value,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) endDate.value = picked;
                        },
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12.h),

              /// 🔹 RECEIPT
              Obx(
                () => _actionCard(
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
                    if (file != null) receiptPath.value = file.path;
                  },
                ),
              ),

              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),

      /// 🔥 SUBMIT BUTTON
      bottomNavigationBar: Obx(() {
        return Padding(
          padding: EdgeInsets.all(16.w),
          child: SizedBox(
            height: 52.h,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFB8E728),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.r),
                ),
              ),
              onPressed: controller.isLoading.value
                  ? null
                  : () {
                      if (!_formKey.currentState!.validate()) return;

                      controller.createChit(
                        chitName: nameController.text,
                        chitValue: valueController.text,
                        chitStart: startDate.value.toString().split(" ")[0],
                        chitEnd: endDate.value.toString().split(" ")[0],
                        chitDuration: durationController.text,
                        chitMembers: membersController.text,
                        chitMonthly: monthlyController.text,
                        chitMonthlyAfter: monthlyAfterController.text,
                        chitStatus: "0",
                        status: "0",
                        receiptPath: receiptPath.value.isEmpty
                            ? null
                            : receiptPath.value,
                      );
                    },
              child: controller.isLoading.value
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      "Save Chit",
                      style: TextStyle(
                        fontSize: 15.sp,
                        color: Colors.white,
                        fontFamily: "BalooBhai2",
                      ),
                    ),
            ),
          ),
        );
      }),
    );
  }

  ////////////////////////////////////////////////////
  /// 🔹 HELPERS
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

  Widget _inputCard(
    String hint,
    TextEditingController controller,
    bool isDark,
  ) {
    return _glassCard(
      isDark,
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        validator: (v) => v!.isEmpty ? "Required" : null,
        decoration: InputDecoration(
                    filled: false,

          hintText: hint,
          border: InputBorder.none,
          hintStyle: const TextStyle(fontFamily: "BalooBhai2"),
        ),
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
      borderRadius: BorderRadius.circular(18.r),
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: Colors.grey.withOpacity(.2)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Color(0xFFB8E728).withOpacity(.1),
              child: Icon(icon, color: Color(0xFFB8E728)),
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
