import 'package:get/get.dart';

import '../repositories/subscriber_repository.dart';

import '../../core/utils/subscribe_state.dart';


class SubscriberController extends GetxController {
  final SubscriberRepository repo = Get.find<SubscriberRepository>();

  RxBool isLoading = false.obs;

  /// userId -> relation state
  RxMap<String, SubscribeState> relationMap =
      <String, SubscribeState>{}.obs;

  /// 🔹 Load relation status (A <-> B)
  Future<void> loadStatus(String userId) async {
    try {
      final state = await repo.getRelationStatus(userId);
      relationMap[userId] = state;
    } catch (e) {
      relationMap[userId] = SubscribeState.none;
    }
  }

  /// 🔹 Get current relation state
  SubscribeState getState(String userId) {
    return relationMap[userId] ?? SubscribeState.none;
  }

  /// 🔹 Toggle subscribe
  Future<void> toggle(String userId) async {
    try {
      isLoading.value = true;

      // Toggle in DB
      await repo.toggleSubscribe(userId);

      // Reload relation after toggle
      final newState = await repo.getRelationStatus(userId);
      relationMap[userId] = newState;

    } catch (e) {
      // Optional: debug log
      print("Toggle Subscribe Error: $e");
    } finally {
      isLoading.value = false;
    }
  }
}


/*class SubscriberController extends GetxController {
  final SubscriberRepository repo = Get.find<SubscriberRepository>();

  RxBool isLoading = false.obs;
  RxMap<String, bool> subscribeStatus = <String, bool>{}.obs;

  /// Check & store status
  Future<void> checkStatus(String userId) async {
    final status = await repo.isSubscribed(userId);
    subscribeStatus[userId] = status;
  }

  /// Toggle subscribe
  Future<void> toggle(String userId) async {
    isLoading.value = true;

    final result = await repo.toggleSubscribe(userId);
    subscribeStatus[userId] = result;

    isLoading.value = false;
  }

  bool isSubscribed(String userId) {
    return subscribeStatus[userId] ?? false;
  }
}*/
