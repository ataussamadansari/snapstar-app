import '../models/like_model.dart';
import '../models/user_model.dart';
import '../providers/like_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LikeRepository {
  final LikeProvider provider;
  LikeRepository(this.provider);
  final _supabase = Supabase.instance.client;

  Future<bool> toggleLike(String postId) async {
    final myId = _supabase.auth.currentUser!.id;

    final isLiked = await provider.isPostLiked(postId, myId);

    if (isLiked) {
      await provider.removeLike(postId, myId);
      return false;
    } else {
      await provider.addLike(postId, myId);
      return true;
    }
  }


  /// 🔹 Get Likes List (For "Liked by..." screen)
  Future<List<UserModel>> getLikesList(String postId) async {
    final rawLikes = await provider.fetchLikes(postId);
    return rawLikes
        .map((l) => LikeModel.fromJson(l).user!)
        .toList();
  }

  /// 🔹 Initial check for UI
  Future<bool> checkLikeStatus(String postId) async {
    final myId = _supabase.auth.currentUser?.id;
    if (myId == null) return false;
    return await provider.isPostLiked(postId, myId);
  }
}