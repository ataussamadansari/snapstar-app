import 'package:snapstar/app/data/providers/firebase_auth_provider.dart';

import '../../core/constants/firebase_constants.dart';
import '../models/post_model.dart';
import '../models/user_model.dart';
import '../providers/follow_provider.dart';
import '../providers/post_provider.dart';
import '../providers/user_provider.dart';

class ProfileRepository {
  final UserProvider userProvider = UserProvider();
  final PostProvider postProvider = PostProvider();
  final FollowProvider followProvider = FollowProvider();
  final FirebaseAuthProvider authProvider = FirebaseAuthProvider();

  /// 🔥 User ki basic details live stream
  Stream<UserModel> getProfileStream(String uid) {
    return userProvider.getUserStream(uid);
  }

  /// 🔥 User ke posts live stream
  Stream<List<PostModel>> getUserPostsStream(String uid) {
    return postProvider.getUserPosts(uid).map(
          (list) => list.map(PostModel.fromMap).toList(),
    );
  }

  /// 🔥 Followers count live stream
  Stream<int> getFollowersCount(String uid) {
    return db
        .collection('users')
        .doc(uid)
        .collection('followers')
        .snapshots()
        .map((snap) => snap.docs.length);
  }

  /// 🔥 Following count live stream
  Stream<int> getFollowingCount(String uid) {
    return db
        .collection('users')
        .doc(uid)
        .collection('following')
        .snapshots()
        .map((snap) => snap.docs.length);
  }

  /// Logout logic using AuthProvider
  Future<void> logout() async {
    try {
      await authProvider.logout();
    } catch (e) {
      throw Exception("Logout failed: $e");
    }
  }
}