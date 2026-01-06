import 'package:get/get.dart';

import 'image_compose_freeze_logic.dart';

class ImageComposeFreezeBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(
      ImageComposeFreezeLogic(),
      permanent: true,
    );
  }
}
