import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart'; // SettableMetadata ke liye zaroori hai
import 'package:snapstar/app/core/constants/firebase_constants.dart';
import 'package:snapstar/app/core/utils/selected_media.dart';
import 'package:snapstar/app/data/models/post_model.dart';

class PostProvider {
  Stream<List<Map<String, dynamic>>> getGlobalPosts() {
    return db
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => d.data()).toList());
  }

  Stream<List<Map<String, dynamic>>> getUserPosts(String uid) {
    return db
        .collection('posts')
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => d.data()).toList());
  }

  Future<void> savePost(PostModel post) async {
    await db.collection('posts').doc(post.postId).set(post.toMap());
  }

  Future<void> incrementUserPostCount(String userId) async {
    await db.collection('users').doc(userId).update({
      'postsCount': FieldValue.increment(1),
    });
  }

  Future<String> uploadFile(SelectedMedia media, String path) async {
    final ref = storage.ref().child(path);
    final metadata = SettableMetadata(
      contentType: media.isVideo ? 'video/mp4' : 'image/jpeg',
    );
    final task = await ref.putFile(media.file, metadata);
    return task.ref.getDownloadURL();
  }
}

