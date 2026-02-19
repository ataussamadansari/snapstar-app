import 'dart:io';

import 'package:get/get.dart';
import 'package:snapstar_app/app/core/utils/auth_helper.dart';
import '../models/story_model.dart';
import '../models/story_user_model.dart';
import '../models/story_view_model.dart';
import '../repositories/story_repository.dart';
import '../models/user_model.dart';

class StoryController extends GetxController {

  final StoryRepository repo = Get.find();

  RxList<StoryModel> stories = <StoryModel>[].obs;
  RxList<StoryUserModel> groupedStories = <StoryUserModel>[].obs;

  RxBool isLoading = false.obs;


  Future<void> postStory({
    required File file,
    required bool isVideo,
    required List<UserModel> users,
  }) async {

    if (AuthHelper.currentUserId.isEmpty) return;

    isLoading.value = true;

    await repo.uploadStory(
      file: file,
      userId: AuthHelper.currentUserId,
      isVideo: isVideo,
    );

    // Refresh stories after upload
    await loadStories(users, AuthHelper.currentUserId);

    isLoading.value = false;
  }


  Future<void> loadStories(List<UserModel> users, String currentUserId) async {
    isLoading.value = true;

    final fetchedStories = await repo.getActiveStories();
    stories.assignAll(fetchedStories);

    final storyIds = fetchedStories.map((e) => e.id).toList();
    final views = await repo.getViews(storyIds);

    _groupStories(users, views, currentUserId);

    isLoading.value = false;
  }

  void _groupStories(
      List<UserModel> users,
      List<StoryViewModel> views,
      String currentUserId,
      ) {

    final Map<String, List<StoryModel>> map = {};

    for (var story in stories) {
      map.putIfAbsent(story.userId, () => []);
      map[story.userId]!.add(story);
    }

    final result = map.entries.map((entry) {

      final user = users.firstWhere(
            (u) => u.id == entry.key,
        orElse: () => users.first,
      );

      final userStories = entry.value;

      final hasUnseen = userStories.any((story) =>
      !views.any((view) =>
      view.storyId == story.id &&
          view.viewerId == currentUserId));

      return StoryUserModel(
        userId: entry.key,
        userName: user.name,
        avatarUrl: user.avatarUrl,
        stories: userStories,
        hasUnseen: hasUnseen,
      );
    }).toList();

    groupedStories.assignAll(result);
  }
}
