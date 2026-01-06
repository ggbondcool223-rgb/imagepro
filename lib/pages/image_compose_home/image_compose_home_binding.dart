import 'package:get/get.dart';
import 'image_compose_home_logic.dart';

class ImageComposeHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ImageComposeHomeLogic());
  }
}

