import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_compose/main.dart';
import 'package:image_compose/pages/image_compose_records/image_compose_records_logic.dart';
import 'image_compose_tab_logic.dart';
import '../image_compose_home/image_compose_home_view.dart';
import '../image_compose_records/image_compose_records_view.dart';
import '../image_compose_settings/image_compose_settings_view.dart';

class ImageComposeTabView extends GetView<ImageComposeTabLogic> {
  const ImageComposeTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: controller.pageController,
        children:const [
          ImageComposeHomeView(),
          ImageComposeRecordsView(),
          ImageComposeSettingsView(),
        ],
      ),
      bottomNavigationBar: Obx(() => _navImageBars()),
    );
  }

  Widget _navImageBars() {
    return BottomNavigationBar(
      items: [
        BottomNavigationBarItem(
          icon: const Icon(
            Icons.home,
            size: 22,
            color: Colors.grey,
          ),
          activeIcon: Icon(Icons.home, size: 22, color: primaryColor),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: const Icon(
            Icons.image,
            size: 22,
            color: Colors.grey,
          ),
          activeIcon: Icon(Icons.image, size: 22, color: primaryColor),
          label: 'Records',
        ),
        BottomNavigationBarItem(
          icon: const Icon(
            Icons.settings,
            size: 22,
            color: Colors.grey,
          ),
          activeIcon: Icon(Icons.settings, size: 22, color: primaryColor),
          label: 'Setting',
        ),
      ],
      currentIndex: controller.currentIndex.value,
      onTap: (index) async {
        controller.currentIndex.value = index;
        controller.pageController.jumpToPage(index);
        if (index == 1) {
          ImageComposeRecordsLogic recordsLogic = Get.find();
          recordsLogic.loadRecords();
        }
      },
    );
  }
}
