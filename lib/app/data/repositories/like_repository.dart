import 'package:snapstar/app/core/constants/firebase_constants.dart';

import '../providers/like_provider.dart';

class LikeRepository {
  final LikeProvider _provider = LikeProvider();

  String get _uid => firebaseAuth.currentUser!.uid;

  Future<bool> isLiked(String postId) {
    return _provider.isPostLiked(postId, _uid);
  }

  Future<void> toggleLike(String postId, bool alreadyLiked) async {
    if (alreadyLiked) {
      await _provider.unlikePost(postId, _uid);
    } else {
      await _provider.likePost(postId, _uid);
    }
  }
}
