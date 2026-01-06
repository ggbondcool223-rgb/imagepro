import 'package:get/get.dart';
import 'image_compose_edit_logic.dart';

class ImageComposeEditBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ImageComposeEditLogic());
  }
}

