import 'package:get/get.dart';
import 'package:snapstar/app/data/repositories/user_repository.dart';
import 'package:snapstar/app/routes/app_routes.dart';

import '../../../core/constants/firebase_constants.dart';
import '../../../data/models/post_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/post_repository.dart';
import '../../../data/repositories/profile_repository.dart';

class ProfileController extends GetxController {
  final ProfileRepository _profileRepo = ProfileRepository();

  var userModel = Rxn<UserModel>();
  var userPosts = <PostModel>[].obs;
  var filteredPosts = <PostModel>[].obs;

  // Real-time stats
  var followersCount = 0.obs;
  var followingCount = 0.obs;
  var selectedFilter = 0.obs;

  @override
  void onInit() {
    super.onInit();
    final uid = firebaseAuth.currentUser!.uid;

    /// 🔥 Live Data Binding
    userModel.bindStream(_profileRepo.getProfileStream(uid));

    userPosts.bindStream(_profileRepo.getUserPostsStream(uid));

    followersCount.bindStream(_profileRepo.getFollowersCount(uid));

    followingCount.bindStream(_profileRepo.getFollowingCount(uid));

    /// 🔥 Listen for post changes to auto-apply filters
    ever(userPosts, (_) => applyFilter(selectedFilter.value));
  }

  void applyFilter(int index) {
    selectedFilter.value = index;
    if (index == 0) {
      filteredPosts.assignAll(userPosts);
    } else if (index == 1) {
      filteredPosts.assignAll(userPosts.where((p) => p.mediaType == MediaType.image));
    } else if (index == 2) {
      filteredPosts.assignAll(userPosts.where((p) => p.mediaType == MediaType.video));
    }
  }

  Future<void> logout() async {
    try {
      await _profileRepo.logout();
      Get.offAllNamed(Routes.login);
    } catch (e) {
      Get.snackbar("Error", "Logout failed. Please try again.");
    }
  }
}