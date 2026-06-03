import 'package:budgetbook_2026/app/core/constant/app_url.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReceiptViewerHelper {
  static void open(String url) {
    Get.to(() => ReceiptView(url: url));
  }
}

class ReceiptView extends StatelessWidget {
  final String url;

  const ReceiptView({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Receipt"), centerTitle: true),
      body: _buildImageView(),
    );
  }

  /// ================= IMAGE VIEW =================
  Widget _buildImageView() {
    print("Load img url: ${AppUrl.getImageUrl(url)}");
    return Center(
      child: InteractiveViewer(
        child: Image.network(
          AppUrl.getImageUrl(url),
          fit: BoxFit.contain,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(child: CircularProgressIndicator());
          },
          errorBuilder: (_, __, ___) =>
              const Center(child: Text("Failed to load image")),
        ),
      ),
    );
  }
}
