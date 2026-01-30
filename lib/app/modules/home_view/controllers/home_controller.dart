import 'package:get/get.dart';

import '../../../data/models/post_model.dart';
import '../../../data/models/story_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/home_repository.dart';
import '../../../data/repositories/user_repository.dart';

class HomeController extends GetxController {
  final HomeRepository _repository = HomeRepository();
  final UserRepository _userRepo = UserRepository();

  var allPosts = <PostModel>[].obs;
  var allStories = <StoryModel>[].obs;
  var currentUser = Rxn<UserModel>();
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCurrentUser();
    syncHomeData();
  }

  void fetchCurrentUser() async {
    currentUser.value = await _userRepo.getCurrentUserDetails();
  }

  void syncHomeData() {
    _repository.getHomePosts().listen((posts) {
      allPosts.assignAll(posts);
      isLoading.value = false;
    });

    _repository.getHomeStories().listen((stories) {
      allStories.assignAll(stories);
    });
  }
}