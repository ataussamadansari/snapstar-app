import 'package:get/get.dart';

import '../controllers/subscriber_list_controller.dart';

class SubscriberListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SubscriberListController>(() => SubscriberListController());
  }
}