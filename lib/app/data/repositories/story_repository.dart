import 'dart:io';

import '../models/story_model.dart';
import '../models/user_model.dart';
import '../providers/story_provider.dart';
import '../providers/user_provider.dart';

class StoryRepository {
  final StoryProvider _provider = StoryProvider();
  final UserProvider _userProvider = UserProvider();

  Future<void> uploadNewStory({
    required File file,
    required UserModel currentUser,
    required bool isVideo,
  }) async {
    try {
      // 1. Upload File
      String mediaUrl = await _provider.uploadStoryFile(file, currentUser.uid);

      // 2. Create Model
      String storyId = DateTime.now().millisecondsSinceEpoch.toString();
      StoryModel newStory = StoryModel(
        storyId: storyId,
        userId: currentUser.uid,
        username: currentUser.username,
        userImage: currentUser.photoUrl,
        mediaUrl: mediaUrl,
        isVideo: isVideo,
        createdAt: DateTime.now(),
      );

      // 3. Save to Firestore
      await _provider.createStory(newStory);
    } catch (e) {
      rethrow;
    }
  }

  /// 🌐 Get Active Stories for Home
  Stream<List<StoryModel>> getActiveStories(String myUid) async* {
    // 1. Un logo ki IDs lo jinhe main follow karta hoon
    final followingIds = await _userProvider.getFollowingIds(myUid);

    // 2. Apni ID bhi add karo taaki apni story bhi dikhe
    followingIds.add(myUid);

    if (followingIds.isEmpty) {
      yield [];
    } else {
      // 3. Batch followingIds if > 10 (Firestore 'whereIn' limit)
      yield* _provider.getStories(followingIds.take(10).toList()).map(
            (list) => list.map((e) => StoryModel.fromMap(e)).toList(),
      );
    }
  }
}