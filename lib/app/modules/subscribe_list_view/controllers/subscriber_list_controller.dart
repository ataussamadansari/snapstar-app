import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/models/user_model.dart';
import '../../../data/repositories/subscriber_repository.dart';

enum SubscriberListType { subscribers, subscribing }

class SubscriberListController extends GetxController {
  final SubscriberRepository _repo = Get.find();

  RxList<UserModel> users = <UserModel>[].obs;
  RxBool isLoading = true.obs;

  late SubscriberListType type;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      load(Get.arguments as SubscriberListType);
    }
  }

  Future<void> load(SubscriberListType listType) async {
    type = listType;
    isLoading.value = true;

    final uid = Supabase.instance.client.auth.currentUser!.id;

    if (type == SubscriberListType.subscribers) {
      users.value = await _repo.fetchSubscribersUsers(uid);
    } else {
      users.value = await _repo.fetchSubscribingUsers(uid);
    }

    isLoading.value = false;
  }
}
