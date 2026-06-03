import 'package:budgetbook_2026/app/core/theme/app_colors.dart';
import 'package:budgetbook_2026/app/data/models/chit_model.dart';
import 'package:budgetbook_2026/app/modules/chit_funds/controllers/edit_chit_funds_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

class EditChitFundsView extends GetView<EditChitFundsController> {
  EditChitFundsView({super.key});

  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final valueController = TextEditingController();
  final membersController = TextEditingController();
  final durationController = TextEditingController();
  final monthlyController = TextEditingController();
  final afterMonthlyController = TextEditingController();
  final liftController = TextEditingController();
  final liftAmountController = TextEditingController();

  final Rx<DateTime> startDate = DateTime.now().obs;
  final Rx<DateTime> endDate = DateTime.now().obs;
  final RxString receiptPath = "".obs;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final ChitModel item = Get.arguments;
    final int id = int.tryParse(item.id.toString()) ?? 0;

    /// 🔥 PREFILL
    nameController.text = item.chitName ?? "";
    valueController.text = item.chitValue ?? "";
    membersController.text = item.chitMembers ?? "";
    durationController.text = item.chitDuration ?? "";
    monthlyController.text = item.chitMonthly ?? "";
    afterMonthlyController.text = item.chitMonthlyAfter ?? "";
    liftController.text = item.chitLift ?? "";
    liftAmountController.text = item.chitLiftAmount ?? "";

    if (item.chitStart != null && item.chitStart!.isNotEmpty) {
      startDate.value = DateTime.parse(item.chitStart!);
    }

    if (item.chitEnd != null && item.chitEnd!.isNotEmpty) {
      endDate.value = DateTime.parse(item.chitEnd!);
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Modify Chit")),

      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ================= CHIT NAME =================
              _sectionTitle("Chit Name"),
              SizedBox(height: 8.h),

              _glassCard(
                isDark,
                child: TextFormField(
                  controller: nameController,
                  validator: (v) =>
                      v == null || v.isEmpty ? "Enter chit name" : null,
                  decoration: const InputDecoration(
                    hintText: "Enter chit name",
                    border: InputBorder.none,
                  ),
                ),
              ),

              SizedBox(height: 20.h),

              /// ================= TOTAL VALUE =================
              Center(
                child: Column(
                  children: [
                    Text("Total Value", style: TextStyle(fontSize: 13.sp)),
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
                        controller: valueController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        validator: (v) =>
                            v == null || v.isEmpty ? "Enter value" : null,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "0",
                          prefixText: "₹ ",
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24.h),

              /// ================= MEMBERS =================
              _sectionTitle("Members"),
              SizedBox(height: 8.h),

              _glassCard(
                isDark,
                child: TextFormField(
                  controller: membersController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: "Enter members",
                    border: InputBorder.none,
                  ),
                ),
              ),

              SizedBox(height: 16.h),

              /// ================= DURATION =================
              _sectionTitle("Duration (Months)"),
              SizedBox(height: 8.h),

              _glassCard(
                isDark,
                child: TextFormField(
                  controller: durationController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: "Enter duration",
                    border: InputBorder.none,
                  ),
                ),
              ),

              SizedBox(height: 20.h),

              /// ================= MONTHLY =================
              _sectionTitle("Monthly"),
              SizedBox(height: 8.h),

              _glassCard(
                isDark,
                child: TextFormField(
                  controller: monthlyController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: "Monthly amount",
                    border: InputBorder.none,
                  ),
                ),
              ),

              SizedBox(height: 16.h),

              /// ================= AFTER MONTHLY =================
              _sectionTitle("After Monthly"),
              SizedBox(height: 8.h),

              _glassCard(
                isDark,
                child: TextFormField(
                  controller: afterMonthlyController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: "After lift monthly",
                    border: InputBorder.none,
                  ),
                ),
              ),

              SizedBox(height: 20.h),

              /// ================= LIFT =================
              _sectionTitle("Lift Month"),
              SizedBox(height: 8.h),

              _glassCard(
                isDark,
                child: TextFormField(
                  controller: liftController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: "Enter lift month",
                    border: InputBorder.none,
                  ),
                ),
              ),

              SizedBox(height: 16.h),

              /// ================= LIFT AMOUNT =================
              _sectionTitle("Lift Amount"),
              SizedBox(height: 8.h),

              _glassCard(
                isDark,
                child: TextFormField(
                  controller: liftAmountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: "Enter lift amount",
                    border: InputBorder.none,
                  ),
                ),
              ),

              SizedBox(height: 20.h),

              /// ================= START DATE =================
              Obx(() {
                return _actionCard(
                  icon: Icons.calendar_today,
                  title: "Start Date",
                  subtitle: "${startDate.value.toLocal()}".split(' ')[0],
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: startDate.value,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );

                    if (picked != null) startDate.value = picked;
                  },
                );
              }),

              SizedBox(height: 12.h),

              /// ================= END DATE =================
              Obx(() {
                return _actionCard(
                  icon: Icons.event,
                  title: "End Date",
                  subtitle: "${endDate.value.toLocal()}".split(' ')[0],
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: endDate.value,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );

                    if (picked != null) endDate.value = picked;
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

              /// ================= UPDATE BUTTON =================
              Obx(() {
                return SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.r),
                      ),
                    ),
                    onPressed: controller.isUpdateLoading.value
                        ? null
                        : () {
                            if (!_formKey.currentState!.validate()) return;

                            controller.updateChit(
                              id: id,
                              chitName: nameController.text,
                              chitValue: valueController.text,
                              chitStart: startDate.value.toString().split(
                                " ",
                              )[0],
                              chitEnd: endDate.value.toString().split(" ")[0],
                              chitDuration: durationController.text,
                              chitMembers: membersController.text,
                              chitLift: liftController.text,
                              chitLiftAmount: liftAmountController.text,
                              chitMonthly: monthlyController.text,
                              chitMonthlyAfter: afterMonthlyController.text,
                              chitStatus: "0",
                              status: "0",
                              receiptPath: receiptPath.value.isEmpty
                                  ? null
                                  : receiptPath.value,
                            );
                          },
                    child: controller.isUpdateLoading.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            "Update Chit",
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

  /// ================= TITLE =================
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

  /// ================= ACTION CARD =================
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
                Text(title, style: TextStyle(fontSize: 12.sp)),
                Text(
                  subtitle,
                  style: TextStyle(
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

  /// ================= GLASS CARD =================
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
