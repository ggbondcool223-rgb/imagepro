import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../db_image_compose/data.dart';

class ImageComposeSettingsLogic extends GetxController {
  final DBImageCompose db = Get.find<DBImageCompose>();

  var appVersion = '1.0.0'.obs;

  cleanAllData() async {
    Get.dialog(AlertDialog(
      title: const Text('Warm reminder'),
      content: const Text('Do you want to clean all records?'),
      actions: [
        TextButton(
          onPressed: () {
            Get.back();
          },
          child: const Text(
            'Cancel',
            style: TextStyle(color: Colors.black),
          ),
        ),
        TextButton(
          onPressed: () async {
            await db.cleanAllData();
            Get.back();
          },
          child: const Text(
            'OK',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    ));
  }

  @override
  void onInit() async {
    var info = await PackageInfo.fromPlatform();
    appVersion.value = info.version;
    super.onInit();
  }
  
}

