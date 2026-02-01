import 'package:snapstar/app/core/utils/user_to_follow_helper.dart';
import '../../core/constants/firebase_constants.dart';
import '../models/follow_user_model.dart';
import '../models/user_model.dart';
import '../providers/follow_provider.dart';

class FollowRepository {
  final FollowProvider _provider = FollowProvider();

  String get myUid => firebaseAuth.currentUser!.uid;


  /// ✅ expose public method
  Future<bool> isFollowing(String myUid, String targetUid) {
    return _provider.isFollowing(myUid, targetUid);
  }

  // follow_repository.dart mein add karein
  Future<bool> hasSentRequest(String myUid, String targetUid) {
    return _provider.hasRequestExist(myUid, targetUid);
  }

  /// 🔥 Follow / Request decision
  Future<void> follow({
    required UserModel me,
    required UserModel target,
  }) async {
    final meSnap = me.toFollowUser();
    final targetSnap = target.toFollowUser();

    if (target.isPrivate) {
      // 🔒 PRIVATE → request
      await _provider.sendFollowRequest(
        targetUid: target.uid,
        requester: meSnap,
      );
    } else {
      // 🌍 PUBLIC → direct follow
      await _provider.followUser(
        myUid: myUid,
        targetUid: target.uid,
        me: meSnap,
        target: targetSnap,
      );
    }
  }

  /// ❌ Unfollow
  Future<void> unfollow(String targetUid) {
    return _provider.unfollow(
      myUid: myUid,
      targetUid: targetUid,
    );
  }

  /// ✅ Accept request
  Future<void> acceptFollowRequest({
    required UserModel me,
    required FollowUserModel requester,
  }) {
    return _provider.acceptRequest(
      myUid: myUid,
      requester: requester,
      me: me.toFollowUser(),
    );
  }

  /// ❌ Reject request
  Future<void> rejectFollowRequest(String requesterUid) {
    return _provider.rejectRequest(
      myUid: myUid,
      requesterUid: requesterUid,
    );
  }
}