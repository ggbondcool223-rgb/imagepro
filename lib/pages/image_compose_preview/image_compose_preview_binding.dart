import 'package:get/get.dart';
import 'image_compose_preview_logic.dart';

class ImageComposePreviewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ImageComposePreviewLogic());
  }
}

