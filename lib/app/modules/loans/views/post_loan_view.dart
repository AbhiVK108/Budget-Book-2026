import 'package:budgetbook_2026/app/core/utils/formate_helper.dart';
import 'package:budgetbook_2026/app/modules/loans/controllers/post_loan_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class PostLoanView extends GetView<PostLoanController> {
  PostLoanView({super.key});

  final _formKey = GlobalKey<FormState>();

  final lenderController = TextEditingController();
  final sanctionedController = TextEditingController();
  final disbursalController = TextEditingController();
  final chargesController = TextEditingController();
  final loanTermsController = TextEditingController();
  final interestController = TextEditingController();
  final totalInterestController = TextEditingController();
  final emiController = TextEditingController();
  final totalAmountController = TextEditingController();

  final Rx<DateTime> disbursementDate = DateTime.now().obs;
  final Rx<DateTime> startEMI = DateTime.now().obs;
  final Rx<DateTime> endEMI = DateTime.now().obs;
  final RxString receiptPath = "".obs;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text("Add Loan")),

      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// 🔴 LENDER NAME
              _sectionTitle("Lender Name"),
              SizedBox(height: 8.h),
              _glassCard(isDark,
                  child: TextFormField(
                controller: lenderController,
                validator: (v) => v!.isEmpty ? "Enter lender" : null,
                decoration: const InputDecoration(
                  hintText: "Enter lender name",
                  border: InputBorder.none,
                ),
              )),

              SizedBox(height: 20.h),

              /// 🔴 SANCTIONED AMOUNT
              _amountField("Sanctioned Amount", sanctionedController),

              SizedBox(height: 16.h),

              _amountField("Disbursal Amount", disbursalController),

              SizedBox(height: 16.h),

              _amountField("Charges Cutting", chargesController),

              SizedBox(height: 16.h),

              _glassCard(isDark,
                  child: TextFormField(
                controller: loanTermsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: "Loan Terms (months)",
                  border: InputBorder.none,
                ),
              )),

              SizedBox(height: 16.h),

              _amountField("Interest %", interestController),

              SizedBox(height: 16.h),

              _amountField("Total Interest", totalInterestController),

              SizedBox(height: 16.h),

              _amountField("EMI Amount", emiController),

              SizedBox(height: 16.h),

              _amountField("Total Amount", totalAmountController),

              SizedBox(height: 20.h),

              /// 📅 DATES
              Row(
                children: [
                  Expanded(
                    child: Obx(() => _actionCard(
                          title: "Disbursement",
                          subtitle: FormatHelper.formatDate(
                              disbursementDate.value.toString()),
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: disbursementDate.value,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              disbursementDate.value = picked;
                            }
                          },
                        )),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Obx(() => _actionCard(
                          title: "Start EMI",
                          subtitle: FormatHelper.formatDate(
                              startEMI.value.toString()),
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: startEMI.value,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) startEMI.value = picked;
                          },
                        )),
                  ),
                ],
              ),

              SizedBox(height: 12.h),

              Obx(() => _actionCard(
                    title: "End EMI",
                    subtitle:
                        FormatHelper.formatDate(endEMI.value.toString()),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: endEMI.value,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) endEMI.value = picked;
                    },
                  )),

              SizedBox(height: 16.h),

              /// 📎 RECEIPT
              Obx(() => _actionCard(
                    title: "Attach Receipt",
                    subtitle: receiptPath.value.isEmpty
                        ? "Optional"
                        : "Attached ✓",
                    onTap: () async {
                      final picker = ImagePicker();
                      final file =
                          await picker.pickImage(source: ImageSource.gallery);

                      if (file != null) {
                        receiptPath.value = file.path;
                      }
                    },
                  )),

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
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.r),
                ),
              ),
              onPressed: controller.isLoading.value
                  ? null
                  : () {
                      if (!_formKey.currentState!.validate()) return;

                      controller.createLoan(
                        nameOfLender: lenderController.text,
                        sanctionedAmount: sanctionedController.text,
                        dateOfDisbursement: disbursementDate.value
                            .toString()
                            .split(" ")[0],
                        disbursalAmount: disbursalController.text,
                        chargesCutting: chargesController.text,
                        loanTerms: loanTermsController.text,
                        rateOfInterest: interestController.text,
                        totalInterestAmount: totalInterestController.text,
                        instalmentAmount: emiController.text,
                        startEMI:
                            startEMI.value.toString().split(" ")[0],
                        endEMI: endEMI.value.toString().split(" ")[0],
                        totalAmount: totalAmountController.text,
                        receiptPath: receiptPath.value.isEmpty
                            ? null
                            : receiptPath.value,
                      );
                    },
              child: controller.isLoading.value
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      "Save Loan",
                      style: TextStyle(
                        fontFamily: "BalooBhai2",
                        fontSize: 15.sp,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        );
      }),
    );
  }

  /// 🔹 HELPERS

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

  Widget _amountField(String hint, TextEditingController controller) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: Colors.redAccent.withOpacity(.3)),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          prefixText: "₹ ",
        ),
      ),
    );
  }

  Widget _actionCard({
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
            Icon(Icons.calendar_today, color: Colors.red),
            SizedBox(width: 10.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 12.sp)),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _glassCard(bool isDark, {required Widget child}) {
    return Container(
      padding: EdgeInsets.all(12.w),
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