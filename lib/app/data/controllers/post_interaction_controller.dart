import 'dart:async';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/post_model.dart';
import '../../data/repositories/like_repository.dart';

class PostInteractionController extends GetxController {
  final LikeRepository _likeRepo = LikeRepository();

  final RxBool isLiked = false.obs;
  final RxInt likeCount = 0.obs;
  final RxInt commentCount = 0.obs;

  late String postId;
  StreamSubscription? _postSub;

  /// 🔥 INIT (REALTIME)
  Future<void> init(PostModel post) async {
    postId = post.postId;

    // 1️⃣ initial optimistic values
    likeCount.value = post.likeCount;
    commentCount.value = post.commentCount;

    // 2️⃣ check user like
    isLiked.value = await _likeRepo.isLiked(postId);

    // 3️⃣ REALTIME POST LISTENER (MOST IMPORTANT)
    _postSub = FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .snapshots()
        .listen((doc) {
      if (!doc.exists) return;

      likeCount.value = doc['likeCount'] ?? 0;
      commentCount.value = doc['commentCount'] ?? 0;
    });
  }

  /// ❤️ / 💔 TOGGLE LIKE (OPTIMISTIC)
  Future<void> toggleLike() async {
    final previous = isLiked.value;

    // optimistic UI
    isLiked.value = !previous;
    likeCount.value += previous ? -1 : 1;

    try {
      await _likeRepo.toggleLike(postId, previous);
    } catch (e) {
      // rollback
      isLiked.value = previous;
      likeCount.value += previous ? 1 : -1;
    }
  }

  @override
  void onClose() {
    _postSub?.cancel();
    super.onClose();
  }
}

