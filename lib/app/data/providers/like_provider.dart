import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/firebase_constants.dart';

class LikeProvider {

  DocumentReference _postRef(String postId) =>
      db.collection('posts').doc(postId);

  DocumentReference _likeRef(String postId, String uid) =>
      _postRef(postId).collection('likes').doc(uid);

  /// ✅ Already liked?
  Future<bool> isPostLiked(String postId, String uid) async {
    final doc = await _likeRef(postId, uid).get();
    return doc.exists;
  }

  /// ❤️ Like
  Future<void> likePost(String postId, String uid) async {
    final batch = db.batch();

    batch.set(_likeRef(postId, uid), {
      'userId': uid,
      'createdAt': FieldValue.serverTimestamp(),
    });

    batch.update(_postRef(postId), {
      'likeCount': FieldValue.increment(1),
    });

    await batch.commit();
  }

  /// 💔 Unlike
  Future<void> unlikePost(String postId, String uid) async {
    final batch = db.batch();

    batch.delete(_likeRef(postId, uid));

    batch.update(_postRef(postId), {
      'likeCount': FieldValue.increment(-1),
    });

    await batch.commit();
  }
}
