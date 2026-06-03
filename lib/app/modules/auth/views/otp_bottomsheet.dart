import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class OtpBottomSheet extends GetView<AuthController> {
  const OtpBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Enter OTP",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          TextField(
            controller: controller.otpController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            textAlign: TextAlign.center,
            decoration: const InputDecoration(
              counterText: "",
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 20),

          Obx(() {
            final isVerifying = controller.isVerifyingOtp.value;

            return SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed:
                    isVerifying ? null : controller.verifyOtp,
                child: isVerifying
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text("Verify & Continue"),
              ),
            );
          }),
        ],
      ),
    );
  }
}