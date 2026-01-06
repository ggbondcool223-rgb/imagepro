import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:styled_widget/styled_widget.dart';
import 'image_compose_settings_logic.dart';

class ImageComposeSettingsView extends GetView<ImageComposeSettingsLogic> {
  const ImageComposeSettingsView({super.key});

  Widget _item(int index) {
    final titles = ['Clean all records', 'App version'];
    return Container(
      width: double.infinity,
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: <Widget>[
        Expanded(
            child: Text(
              titles[index],
              style: const TextStyle(color: Colors.white),
            )),
        index == 0
            ? const Icon(
          Icons.keyboard_arrow_right,
          color: Colors.white,
          size: 25,
        )
            : Obx(() {
          return Text(
            controller.appVersion.value,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          );
        })
      ].toRow(mainAxisAlignment: MainAxisAlignment.spaceBetween),
    )
        .decorated(
        color: const Color(0xff242c39),
        borderRadius: BorderRadius.circular(10))
        .marginOnly(bottom: 10)
        .gestures(onTap: () {
      if (index == 0) {
        controller.cleanAllData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B1E),
      appBar: AppBar(
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF00FFC2), Color(0xFFFF00C7)],
          ).createShader(bounds),
          child: const Text(
            'Settings',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: const Color(0xFF0B0B1E),
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          children: [
            _item(0),
            _item(1),
          ],
        ),
      ),
    );
  }
}

