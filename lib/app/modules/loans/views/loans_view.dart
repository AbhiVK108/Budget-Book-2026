import 'package:budgetbook_2026/app/core/utils/formate_helper.dart';
import 'package:budgetbook_2026/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/loans_controller.dart';

class LoansView extends GetView<LoansController> {
  const LoansView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      floatingActionButton: addLoanFAB(),
      backgroundColor: isDark ? const Color(0xFF1C1C28) : Colors.grey.shade100,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF1C1C28) : Colors.white,
        centerTitle: true,
        title: Text(
          "Your Loans",
          style: TextStyle(
            fontFamily: "BalooBhai2",
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final totalLoan = controller.getTotalLoanAmount();
        final totalInterest = controller.getTotalInterest();
        final totalEMI = controller.getTotalEMI();

        final list = controller.loanList;

        return Padding(
          padding: EdgeInsets.all(18.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              ////////////////////////////////////////////////////
              /// 🔥 OVERVIEW CARD (RED THEME)
              ////////////////////////////////////////////////////
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.redAccent, Colors.red],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Loan Overview",
                      style: TextStyle(
                        fontFamily: "BalooBhai2",
                        fontSize: 13.sp,
                        color: Colors.white70,
                      ),
                    ),

                    SizedBox(height: 10.h),

                    /// 🔥 TOTAL LIABILITY
                    Text(
                      FormatHelper.formatINR(totalLoan),
                      style: TextStyle(
                        fontFamily: "BalooBhai2",
                        fontSize: 26.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    SizedBox(height: 4.h),

                    Text(
                      "Total Payable",
                      style: TextStyle(
                        fontFamily: "BalooBhai2",
                        fontSize: 11.sp,
                        color: Colors.white70,
                      ),
                    ),

                    SizedBox(height: 16.h),

                    /// 🔹 METRICS
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _metric("Interest", totalInterest),
                        _metric("Monthly EMI", totalEMI),
                        _metric("Loans", list.length.toDouble()),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20.h),

              /// 🔹 HEADER
              Text(
                "Active Loans",
                style: TextStyle(
                  fontFamily: "BalooBhai2",
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 10.h),

              /// 🔹 LIST
              Expanded(
                child: list.isEmpty
                    ? const Center(child: Text("No Loans"))
                    : ListView.builder(
                        itemCount: list.length,
                        itemBuilder: (context, index) {
                          final item = list[index];
                          return _loanTile(item, isDark);
                        },
                      ),
              ),
            ],
          ),
        );
      }),
    );
  }

  ////////////////////////////////////////////////////
  /// 🔹 METRIC
  ////////////////////////////////////////////////////
  Widget _metric(String title, double amount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: "BalooBhai2",
            fontSize: 10.sp,
            color: Colors.white70,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          FormatHelper.formatCompact(amount),
          style: TextStyle(
            fontFamily: "BalooBhai2",
            fontSize: 13.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  ////////////////////////////////////////////////////
  /// 🔹 LOAN TILE
  ////////////////////////////////////////////////////
  Widget _loanTile(item, bool isDark) {
    double total = double.tryParse(item.totalAmount) ?? 0;
    double emi = double.tryParse(item.instalmentAmount) ?? 0;

    return InkWell(
      borderRadius: BorderRadius.circular(18.r),
      onTap: () {
        _showBottomSheet(Get.context!, item, isDark);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 14.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A2A3C) : Colors.white,
          borderRadius: BorderRadius.circular(18.r),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22.r,
              backgroundColor: Colors.red.withOpacity(.15),
              child: Text(
                item.nameOfLender[0].toUpperCase(),
                style: TextStyle(
                  fontFamily: "BalooBhai2",
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ),

            SizedBox(width: 12.w),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.nameOfLender,
                    style: TextStyle(
                      fontFamily: "BalooBhai2",
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    "EMI: ${FormatHelper.formatINR(emi)}",
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            Text(
              FormatHelper.formatINR(total),
              style: TextStyle(
                fontFamily: "BalooBhai2",
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  ////////////////////////////////////////////////////
  /// 🔹 BOTTOM SHEET
  ////////////////////////////////////////////////////
  void _showBottomSheet(BuildContext context, item, bool isDark) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(18.w),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1C28) : Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              item.nameOfLender,
              style: TextStyle(
                fontFamily: "BalooBhai2",
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 16.h),

            _info("Total Amount", item.totalAmount),
            _info("Interest", item.totalInterestAmount),
            _info("EMI", item.instalmentAmount),
            _info("Duration", "${item.loanTerms} months"),

            SizedBox(height: 20.h),

            ElevatedButton(
              onPressed: () async {
                Get.back();
                await controller.deleteLoan(item.id);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text("Delete Loan"),
            ),
          ],
        ),
      ),
    );
  }

    Widget addLoanFAB() {
    return FloatingActionButton.extended(
      onPressed: () {
        Get.toNamed(Routes.PostLoanView);
      },
      backgroundColor:  Colors.red,
      icon: const Icon(Icons.add),
      label: Text("Insert", style: TextStyle(fontFamily: "BalooBhai2")),
    );
  }

  Widget _info(String title, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}