import 'package:get/get.dart';
import 'package:snapstar_app/app/data/controllers/story_controller.dart';
import 'package:snapstar_app/app/data/repositories/subscriber_repository.dart';
import '../../../data/models/post_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/post_repository.dart';
import '../../../data/repositories/user_repository.dart';

class HomeController extends GetxController {
  UserRepository get userRepo => Get.find<UserRepository>();
  PostRepository get postRepo => Get.find<PostRepository>();
  SubscriberRepository get subscriberRepo => Get.find<SubscriberRepository>();
  StoryController get storyController => Get.find<StoryController>();

  RxList<UserModel> users = <UserModel>[].obs;
  RxList<PostModel> posts = <PostModel>[].obs;

  RxBool isLoadingUsers = false.obs;
  RxBool isLoadingPosts = false.obs;

  @override
  void onInit() {
    super.onInit();
    refreshAll();
  }

  Future<void> refreshAll() async {
    await loadUsers(refresh: true);
    await loadPosts();

    // 👇 Sirf stories refresh karni hain
    await storyController.fetchStories();
  }

  Future<void> loadUsers({bool refresh = false}) async {
    if (isLoadingUsers.value) return;

    if (refresh) users.clear();

    isLoadingUsers.value = true;

    final newUsers = await subscriberRepo.getSuggestedUsers(
      limit: 15,
      offset: 0,
    );

    users.addAll(newUsers);

    isLoadingUsers.value = false;
  }

  Future<void> loadPosts() async {
    if (isLoadingPosts.value) return;

    isLoadingPosts.value = true;

    final feed = await postRepo.fetchFeedPosts();

    posts.assignAll(feed);

    isLoadingPosts.value = false;
  }
}

/*
import 'package:get/get.dart';
import 'package:snapstar_app/app/data/controllers/story_controller.dart';
import 'package:snapstar_app/app/data/repositories/story_repository.dart';
import 'package:snapstar_app/app/data/repositories/subscriber_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/utils/auth_helper.dart';
import '../../../data/models/post_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/post_repository.dart';
import '../../../data/repositories/user_repository.dart';

class HomeController extends GetxController {
  UserRepository get userRepo => Get.find<UserRepository>();

  PostRepository get postRepo => Get.find<PostRepository>();

  SubscriberRepository get subscriberRepo => Get.find<SubscriberRepository>();

  StoryController get storyController => Get.find<StoryController>();

  RxList<UserModel> users = <UserModel>[].obs;
  RxList<PostModel> posts = <PostModel>[].obs;

  RxBool isLoadingUsers = false.obs;
  RxBool isLoadingPosts = false.obs;

  @override
  void onInit() {
    super.onInit();
    refreshAll();
  }

  Future<void> refreshAll() async {
    await Future.wait([loadUsers(refresh: true), loadPosts()]);
    await storyController.loadStories(users, AuthHelper.currentUserId);
  }

  Future<void> loadUsers({bool refresh = false}) async {
    if (isLoadingUsers.value) return;
    if (refresh) users.clear();
    isLoadingUsers.value = true;
    final newUsers = await subscriberRepo.getSuggestedUsers(
      limit: 15,
      offset: 0,
    );
    users.addAll(newUsers);
    isLoadingUsers.value = false;
  }

  Future<void> loadPosts() async {
    if (isLoadingPosts.value) return;
    isLoadingPosts.value = true;
    final feed = await postRepo.fetchFeedPosts();
    posts.assignAll(feed);
    isLoadingPosts.value = false;
  }
}
*/
