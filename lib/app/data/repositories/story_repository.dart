import 'dart:io';

import '../models/story_model.dart';
import '../models/story_view_model.dart';
import '../providers/story_provider.dart';

class StoryRepository {
  final StoryProvider _provider;

  StoryRepository(this._provider);

  Future<void> uploadStory({
    required File file,
    required String userId,
    required bool isVideo,
  }) async {

    final url = await _provider.uploadStoryFile(file, userId);

    await _provider.insertStory(
      userId: userId,
      mediaUrl: url,
      mediaType: isVideo ? "video" : "image",
    );
  }

  Future<List<StoryModel>> getActiveStories() {
    return _provider.fetchActiveStories();
  }

  Future<List<StoryViewModel>> getViews(
      List<String> storyIds) {
    return _provider.fetchStoryViews(storyIds);
  }

  Future<void> markViewed(
      String storyId, String viewerId) {
    return _provider.markStoryViewed(storyId, viewerId);
  }
}
