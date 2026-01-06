import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:convert';
import 'image_compose_preview_logic.dart';

class ImageComposePreviewView extends GetView<ImageComposePreviewLogic> {
  const ImageComposePreviewView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Image Preview',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download, color: Colors.white),
            onPressed: controller.onDownloadTap,
          ),
        ],
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: GetBuilder<ImageComposePreviewLogic>(
        builder: (logic) {
          if (logic.imageBytes == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          
          return Center(
            child: InteractiveViewer(
              child: Image.memory(
                logic.imageBytes!,
                fit: BoxFit.contain,
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          border: const Border(top: BorderSide(color: Color(0xFF1A1A2E))),
        ),
        child: ElevatedButton.icon(
          onPressed: controller.onDeleteTap,
          icon: const Icon(Icons.delete),
          label: const Text('Delete'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
          ),
        ),
      ),
    );
  }
}

