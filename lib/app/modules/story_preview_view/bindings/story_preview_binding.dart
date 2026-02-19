import 'package:get/get.dart';

import '../controllers/story_preview_controller.dart';

class StoryPreviewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StoryPreviewController>(() => StoryPreviewController());
  }

}