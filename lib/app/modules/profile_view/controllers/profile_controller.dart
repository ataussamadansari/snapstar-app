import 'package:get/get.dart';
import 'package:snapstar/app/data/repositories/user_repository.dart';

import '../../../core/constants/firebase_constants.dart';
import '../../../data/models/post_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/post_repository.dart';

class ProfileController extends GetxController {
  final UserRepository _userRepo = UserRepository();
  final PostRepository _postRepo = PostRepository();

  var userModel = Rxn<UserModel>();
  var userPosts = <PostModel>[].obs;
  var filteredPosts = <PostModel>[].obs;
  var selectedFilter = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProfileData();
  }

  void fetchProfileData() {
    final uid = firebaseAuth.currentUser!.uid;

    /// 🔥 USER REALTIME
    _userRepo.provider.getUserStream(uid).listen((data) {
      userModel.value = data;
    });

    /// 🔥 POSTS REALTIME
    _postRepo.getUserPosts(uid).listen((posts) {
      userPosts.assignAll(posts);
      applyFilter(selectedFilter.value);
    });
  }

  void applyFilter(int index) {
    selectedFilter.value = index;

    if (index == 0) {
      filteredPosts.assignAll(userPosts);
    } else if (index == 1) {
      filteredPosts.assignAll(
        userPosts.where((p) => p.mediaType == MediaType.image),
      );
    } else if (index == 2) {
      filteredPosts.assignAll(
        userPosts.where((p) => p.mediaType == MediaType.video),
      );
    }
  }
}
