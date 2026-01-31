import 'package:get/get.dart';
import 'package:snapstar/app/data/repositories/post_repository.dart';

import '../../../data/models/post_model.dart';
import '../../../data/models/story_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/home_repository.dart';
import '../../../data/repositories/user_repository.dart';

class HomeController extends GetxController {
  final PostRepository _postRepo = PostRepository();
  final UserRepository _userRepo = UserRepository();

  final allPosts = <PostModel>[].obs;
  final allStories = <StoryModel>[].obs;
  final currentUser = Rxn<UserModel>();
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadCurrentUser();
    _postRepo.getHomePosts().listen(allPosts.assignAll);
    // _syncHome();
  }

  void _loadCurrentUser() async {
    currentUser.value = await _userRepo.getCurrentUserDetails();
  }
/*
  void _syncHome() {
    _repository.getHomePosts().listen((posts) {
      allPosts.assignAll(posts);
      isLoading.value = false;
    });

    _repository.getHomeStories().listen((stories) {
      allStories.assignAll(stories);
    });
  }*/
}