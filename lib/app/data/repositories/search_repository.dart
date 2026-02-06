import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post_model.dart';
import '../models/user_model.dart';

class SearchRepository {
  final _usersRef = FirebaseFirestore.instance.collection('users');
  final _postsRef = FirebaseFirestore.instance.collection('posts');

  /// USERS (username)
  Future<List<UserModel>> searchUsers(String query) async {
    if (query.isEmpty) return [];

    final snap = await _usersRef
        .where('username', isGreaterThanOrEqualTo: query)
        .where('username', isLessThanOrEqualTo: '$query\uf8ff')
        .limit(20)
        .get();

    return snap.docs
        .map((doc) => UserModel.fromMap(doc.data()))
        .toList();
  }

  /// POSTS (caption)
  Future<List<PostModel>> searchPosts(String query) async {
    if (query.isEmpty) return [];

    final snap = await _postsRef
        .where('caption', isGreaterThanOrEqualTo: query)
        .where('caption', isLessThanOrEqualTo: '$query\uf8ff')
        .limit(20)
        .get();

    return snap.docs
        .map((doc) => PostModel.fromMap(doc.data()))
        .toList();
  }

  /// HASHTAGS (#flutter)
  Future<List<PostModel>> searchHashtags(String tag) async {
    final snap = await _postsRef
        .where('tags', arrayContains: tag)
        .limit(20)
        .get();

    return snap.docs
        .map((doc) => PostModel.fromMap(doc.data()))
        .toList();
  }

}
