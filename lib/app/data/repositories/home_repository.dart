import 'package:snapstar/app/data/models/post_model.dart';
import 'package:snapstar/app/data/providers/home_provider.dart';
import 'package:snapstar/app/data/repositories/user_repository.dart';

import '../../core/constants/firebase_constants.dart';
import '../models/story_model.dart';
import '../models/user_model.dart';


class HomeRepository {
  final HomeProvider _provider = HomeProvider();
  final UserRepository _userRepo = UserRepository();


  Stream<List<PostModel>> getHomePosts() {
    // 1. Raw posts ki stream lein
    return _provider.getGlobalFeed().asyncMap((list) async {

      // 2. Raw maps ko PostModels mein convert karein
      List<PostModel> posts = list.map((m) => PostModel.fromMap(m)).toList();

      // 3. Unique User IDs nikaalein (Performance ke liye)
      final userIds = posts.map((p) => p.userId).toSet().toList();

      // 4. Saare users ka data parallel fetch karein
      final usersData = await Future.wait(
          userIds.map((id) => _userRepo.getUserDetailsById(id))
      );

      // 5. Ek Map banayein [uid -> UserModel] fast access ke liye
      final userCache = {for (var u in usersData) if (u != null) u.uid: u};

      // 6. Har post mein uska relevant user data inject karein
      for (var post in posts) {
        post.user = userCache[post.userId];
      }

      posts.shuffle();
      return posts;
    });
  }


  Stream<List<StoryModel>> getHomeStories() {
    return _provider.getActiveStories().map((list) =>
        list.map((m) => StoryModel.fromMap(m)).toList());
  }
}
