import 'package:get/get.dart';
import '../../../data/models/follow_user_model.dart';
import '../../../data/providers/user_provider.dart';

class FollowListController extends GetxController {
  final UserProvider _userProvider = UserProvider();

  // Ab hum UserModel ki jagah FollowUserModel use karenge
  var followUsers = <FollowUserModel>[].obs;
  var isLoading = true.obs;

  void fetchUsers(String uid, bool isFollowers) async {
    isLoading.value = true;
    followUsers.clear();

    try {
      // Direct data fetch kar rahe hain, alag se users collection call karne ki zaroorat nahi
      List<Map<String, dynamic>> data = isFollowers
          ? await _userProvider.getFollowersData(uid)
          : await _userProvider.getFollowingData(uid);

      if (data.isNotEmpty) {
        followUsers.value = data.map((e) => FollowUserModel.fromMap(e)).toList();
      }
    } finally {
      isLoading.value = false;
    }
  }
}