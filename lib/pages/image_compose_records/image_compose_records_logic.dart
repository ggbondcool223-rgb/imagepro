import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'dart:convert';
import 'dart:typed_data';
import '../../db_image_compose/data.dart';
import '../../db_image_compose/image_compose_entity.dart';

class ImageComposeRecordsLogic extends GetxController {
  final DBImageCompose db = Get.find<DBImageCompose>();
  var records = <ImageComposeEntity>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadRecords();
  }

  @override
  void onReady() {
    super.onReady();
    loadRecords();
  }

  Future<void> loadRecords() async {
    try {
      records.value = await db.getImageComposeRecords();
      update();
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to load records');
    }
  }

  void onImageTap(ImageComposeEntity record) {
    Get.toNamed(
      '/image_compose_preview',
      arguments: {'record': record},
    )?.then((_){
      loadRecords();
    });
  }

  void onMoreTap(ImageComposeEntity record) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A2E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.only(bottom: 20.h),
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            _buildMenuItem(
              icon: Icons.download,
              title: 'Download',
              onTap: () {
                Get.back();
                onDownloadTap(record);
              },
            ),
            SizedBox(height: 12.h),
            _buildMenuItem(
              icon: Icons.delete,
              title: 'Delete',
              onTap: () {
                Get.back();
                onDeleteTap(record);
              },
              isDestructive: true,
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: Colors.grey[800]!.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive ? Colors.red : const Color(0xFF00D4FF),
              size: 24,
            ),
            SizedBox(width: 16.w),
            Text(
              title,
              style: TextStyle(
                color: isDestructive ? Colors.red : Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> onDownloadTap(ImageComposeEntity record) async {
    try {
      final result = await ImageGallerySaverPlus.saveImage(
        record.imageData,
        quality: 100,
      );
      if (result['isSuccess'] == true) {
        Fluttertoast.showToast(msg: 'Downloaded successfully');
      } else {
        Fluttertoast.showToast(msg: 'Download failed');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Download failed: $e');
    }
  }

  Future<void> onDeleteTap(ImageComposeEntity record) async {
    try {
      await db.deleteImageComposeRecord(record.id!);
      Fluttertoast.showToast(msg: 'Deleted successfully');
      loadRecords();
    } catch (e) {
      Fluttertoast.showToast(msg: 'Delete failed: $e');
    }
  }

}

