import 'dart:async';
import 'package:get/get.dart';

import '../../../core/utils/auth_helper.dart';
import '../../../data/controllers/story_controller.dart';
import '../../../data/models/story_model.dart';

class StoryViewerController extends GetxController {

  final StoryController storyController = Get.find();

  RxList<StoryModel> userStories = <StoryModel>[].obs;

  RxInt currentIndex = 0.obs;
  RxDouble progress = 0.0.obs;

  Timer? _timer;

  late String userId;

  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  Future<void> _initialize() async {

    final StoryModel tappedStory = Get.arguments;

    userId = tappedStory.userId;

    userStories.assignAll(
      storyController.stories
          .where((s) => s.userId == userId)
          .toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt)),
    );

    currentIndex.value = userStories.indexWhere(
          (s) => s.id == tappedStory.id,
    );

    if (currentIndex.value < 0) {
      currentIndex.value = 0;
    }

    await markCurrentViewed();
    startProgress();
  }

  void loadUserStories() {
    userStories.assignAll(
        storyController.stories
            .where((s) => s.userId == userId)
            .toList()
          ..sort((a,b) => a.createdAt.compareTo(b.createdAt))
    );

    startProgress();
    markCurrentViewed();
  }

  void startProgress() {
    progress.value = 0;
    _timer?.cancel();

    _timer = Timer.periodic(
      const Duration(milliseconds: 50),
          (timer) {
        progress.value += 0.01;

        if (progress.value >= 1) {
          nextStory();
        }
      },
    );
  }

  void nextStory() {
    if (currentIndex.value < userStories.length - 1) {
      currentIndex.value++;
      startProgress();
      markCurrentViewed();
    } else {
      Get.back();
    }
  }

  void previousStory() {
    if (currentIndex.value > 0) {
      currentIndex.value--;
      startProgress();
      markCurrentViewed();
    }
  }

  void pause() {
    _timer?.cancel();
  }

  void resume() {
    startProgress();
  }

  Future<void> markCurrentViewed() async {

    final story = userStories[currentIndex.value];

    if (story.isViewed) return;

    await storyController.markViewed(
      storyId: story.id,
      viewerId: AuthHelper.currentUserId,
    );
  }

  /*void markCurrentViewed() {
    final story = userStories[currentIndex.value];

    storyController.markViewed(
      storyId: story.id,
      viewerId: AuthHelper.currentUserId,
    );
  }*/


  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}