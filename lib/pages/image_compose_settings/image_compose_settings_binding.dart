import 'package:get/get.dart';
import 'image_compose_settings_logic.dart';

class ImageComposeSettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ImageComposeSettingsLogic());
  }
}

