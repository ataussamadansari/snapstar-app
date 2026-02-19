import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../data/repositories/like_repository.dart';

class LikeController extends GetxController {
  LikeRepository get _likeRepo => Get.find<LikeRepository>();

  var likedPosts = <String, bool>{}.obs;
  var likeCounts = <String, int>{}.obs;

  /// 🔹 Call when post loads
  void initializePost(String postId, int dbLikeCount) {
    debugPrint("🟡 initializePost -> $postId");
    debugPrint("📦 DB Like Count -> $dbLikeCount");

    likedPosts[postId] ??= false;
    likeCounts[postId] ??= dbLikeCount;

    _fetchLikeStatus(postId);
  }

  Future<void> _fetchLikeStatus(String postId) async {
    try {
      final status =
      await _likeRepo.checkLikeStatus(postId);

      likedPosts[postId] = status;

      debugPrint("✅ Like Status Loaded [$postId] -> $status");
    } catch (e) {
      debugPrint("❌ Error fetching like status [$postId] -> $e");
    }
  }

  /// 🔥 Optimistic Like + Count Update
  Future<void> toggleLike(String postId) async {
    final wasLiked = likedPosts[postId] ?? false;

    debugPrint("🔄 Toggle Like -> $postId");
    debugPrint("📌 Previous State -> $wasLiked");
    debugPrint("📊 Previous Count -> ${likeCounts[postId]}");

    // 🔥 Optimistic Update
    likedPosts[postId] = !wasLiked;

    if (wasLiked) {
      likeCounts[postId] =
          (likeCounts[postId] ?? 0) - 1;
    } else {
      likeCounts[postId] =
          (likeCounts[postId] ?? 0) + 1;
    }

    debugPrint(
        "⚡ Optimistic State -> ${likedPosts[postId]}");
    debugPrint(
        "⚡ Optimistic Count -> ${likeCounts[postId]}");

    try {
      await _likeRepo.toggleLike(postId);
      debugPrint("✅ DB Like Toggle Success [$postId]");
    } catch (e) {
      debugPrint("❌ DB Like Toggle Failed [$postId] -> $e");

      // Rollback
      likedPosts[postId] = wasLiked;

      if (wasLiked) {
        likeCounts[postId] =
            (likeCounts[postId] ?? 0) + 1;
      } else {
        likeCounts[postId] =
            (likeCounts[postId] ?? 0) - 1;
      }

      debugPrint("🔁 Rollback State -> ${likedPosts[postId]}");
      debugPrint("🔁 Rollback Count -> ${likeCounts[postId]}");
    }
  }

  bool isLiked(String postId) =>
      likedPosts[postId] ?? false;

  int likeCount(String postId) =>
      likeCounts[postId] ?? 0;
}
