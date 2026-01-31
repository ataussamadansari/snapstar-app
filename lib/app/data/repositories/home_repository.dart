import 'package:snapstar/app/data/models/post_model.dart';
import 'package:snapstar/app/data/providers/home_provider.dart';
import '../models/story_model.dart';

class HomeRepository {
  final HomeProvider _provider = HomeProvider();

  /// 🔥 FAST HOME FEED (NO USER FETCH)
  Stream<List<PostModel>> getHomePosts() {
    return _provider.getGlobalFeed().map((list) {
      final posts = list.map((m) => PostModel.fromMap(m)).toList();

      // Optional: randomize feed (basic)
      posts.shuffle();

      return posts;
    });
  }

  Stream<List<StoryModel>> getHomeStories() {
    return _provider.getActiveStories().map(
          (list) => list.map((m) => StoryModel.fromMap(m)).toList(),
    );
  }
}
