import 'package:get/get.dart';
import 'package:image_compose/pages/image_compose_home/image_compose_home_logic.dart';
import 'package:image_compose/pages/image_compose_records/image_compose_records_logic.dart';
import 'package:image_compose/pages/image_compose_settings/image_compose_settings_logic.dart';
import 'image_compose_tab_logic.dart';

class ImageComposeTabBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ImageComposeTabLogic());
    Get.lazyPut(() => ImageComposeHomeLogic());
    Get.lazyPut(() => ImageComposeRecordsLogic());
    Get.lazyPut(() => ImageComposeSettingsLogic());
  }
}

