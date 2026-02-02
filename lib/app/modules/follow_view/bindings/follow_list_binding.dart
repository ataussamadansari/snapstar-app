import 'package:get/get.dart';
import 'package:snapstar/app/data/controllers/follow_controller.dart';
import 'package:snapstar/app/modules/follow_view/controllers/follow_list_controller.dart';

import '../../post_view/controllers/post_controller.dart';

class FollowListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FollowListController>(() => FollowListController());
  }
}