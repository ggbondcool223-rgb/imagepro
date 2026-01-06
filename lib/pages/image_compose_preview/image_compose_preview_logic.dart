import 'dart:convert';
import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import '../../db_image_compose/image_compose_entity.dart';
import '../../db_image_compose/data.dart';

class ImageComposePreviewLogic extends GetxController {
  final DBImageCompose db = Get.find<DBImageCompose>();
  Uint8List? imageBytes;
  ImageComposeEntity? record;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null && args['record'] != null) {
      record = args['record'] as ImageComposeEntity;
      imageBytes = record!.imageData;
      update();
    }
  }

  Future<void> onDownloadTap() async {
    if (imageBytes == null) return;
    try {
      final result = await ImageGallerySaverPlus.saveImage(
        imageBytes!,
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

  Future<void> onDeleteTap() async {
    if (record?.id == null) return;
    try {
      await db.deleteImageComposeRecord(record!.id!);
      Fluttertoast.showToast(msg: 'Deleted successfully');
      Get.back();
    } catch (e) {
      Fluttertoast.showToast(msg: 'Delete failed: $e');
    }
  }
}

