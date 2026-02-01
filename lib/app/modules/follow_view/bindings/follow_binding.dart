import 'package:get/get.dart';
import 'package:snapstar/app/data/controllers/follow_controller.dart';

import '../../post_view/controllers/post_controller.dart';

class PostBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FollowController>(() => FollowController());
  }
}