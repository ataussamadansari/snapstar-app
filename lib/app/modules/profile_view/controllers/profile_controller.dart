import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/models/post_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/post_repository.dart';
import '../../../data/repositories/user_repository.dart';

class ProfileController extends GetxController
    with GetSingleTickerProviderStateMixin {

  UserRepository get _userRepo => Get.find<UserRepository>();
  PostRepository get _postRepo => Get.find<PostRepository>();
  final _supabase = Supabase.instance.client;

  late TabController tabController;

  RxList<PostModel> allPosts = <PostModel>[].obs;
  RxList<PostModel> imagePosts = <PostModel>[].obs;
  RxList<PostModel> videoPosts = <PostModel>[].obs;

  RxBool isPostLoading = false.obs;

  Rxn<UserModel> userProfile = Rxn<UserModel>();
  RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();

    tabController = TabController(length: 3, vsync: this);

    fetchMyProfile();
    fetchAllMyPosts();   // 🔥 only once
  }

  Future<void> fetchAllMyPosts() async {
    try {
      isPostLoading.value = true;

      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final posts = await _postRepo.fetchUserPosts(user.id);

      allPosts.assignAll(posts);
      imagePosts.assignAll(
          posts.where((p) => p.mediaType == MediaType.image));
      videoPosts.assignAll(
          posts.where((p) => p.mediaType == MediaType.video));

    } finally {
      isPostLoading.value = false;
    }
  }

  Future<void> fetchMyProfile() async {
    try {
      isLoading.value = true;
      final user = _supabase.auth.currentUser;
      if (user != null) {
        final profile = await _userRepo.fetchProfile(user.id);
        userProfile.value = profile;
      }
    } finally {
      isLoading.value = false;
    }
  }
}
