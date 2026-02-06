import 'package:get/get.dart';
import 'package:snapstar/app/modules/follow_view/controllers/follow_list_controller.dart';

class FollowListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FollowListController>(() => FollowListController());
  }
}