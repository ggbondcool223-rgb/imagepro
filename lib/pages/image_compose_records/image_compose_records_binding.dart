import 'package:get/get.dart';
import 'image_compose_records_logic.dart';

class ImageComposeRecordsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ImageComposeRecordsLogic());
  }
}

