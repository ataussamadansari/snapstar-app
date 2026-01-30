import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart'; // SettableMetadata ke liye zaroori hai
import 'package:snapstar/app/core/constants/firebase_constants.dart';
import 'package:snapstar/app/core/utils/selected_media.dart';
import 'package:snapstar/app/data/models/post_model.dart';

class PostProvider {

  Future<List<Map<String, dynamic>>> getUserPostsRaw(String uid) async {
    final snap = await db.collection('posts')
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .get();

    return snap.docs.map((doc) => doc.data()).toList();
  }

  Future<String> uploadFile(SelectedMedia media, String path) async {
    try {
      final ref = storage.ref().child(path);

      // Video ke liye sahi content type set karein
      final metadata = SettableMetadata(
        contentType: media.isVideo ? 'video/mp4' : 'image/jpeg',
      );

      // Pura object nahi balki media.file upload karein
      final uploadTask = await ref.putFile(media.file, metadata);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> savePost(PostModel post) async {
    await db.collection('posts').doc(post.postId).set(post.toMap());
  }

  Future<void> incrementUserPostCount(String userId) async {
    await db.collection('users').doc(userId).update({
      'postsCount': FieldValue.increment(1),
    });
  }
}