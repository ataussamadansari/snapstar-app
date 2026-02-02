import 'package:snapstar/app/core/utils/user_to_follow_helper.dart';
import '../../core/constants/firebase_constants.dart';
import '../controllers/follow_controller.dart';
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
  // follow_repository.dart
  Future<void> unfollow(String targetUid) async {
    // 1. Pehle normal unfollow try karein (Following/Followers nodes)
    await _provider.unfollow(myUid: myUid, targetUid: targetUid);

    // 2. Saath hi follow request bhi delete kar dein agar pending ho (Cancel Request)
    await _provider.cancelFollowRequest(myUid: myUid, targetUid: targetUid);
  }
  /*Future<void> unfollow(String targetUid) {
    return _provider.unfollow(
      myUid: myUid,
      targetUid: targetUid,
    );
  }*/

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

  Future<FollowState> getFollowState({
    required String myUid,
    required String targetUid,
  }) async {
    // 1. Kya main usse follow kar raha hoon?
    final iFollowHim = await _provider.isFollowing(myUid, targetUid);
    if (iFollowHim) return FollowState.following;

    // 2. Kya meri request pending hai uske paas?
    final iRequestedHim = await _provider.hasRequestExist(myUid, targetUid);
    if (iRequestedHim) return FollowState.requested;

    // 3. Kya USNE mujhe request bheji hui hai? (Review Request state)
    final heRequestedMe = await _provider.hasRequestExist(targetUid, myUid);
    if (heRequestedMe) return FollowState.requestedMe;

    // 4. Kya wo mujhe follow karta hai? (Follow Back state)
    final heFollowsMe = await _provider.isFollowing(targetUid, myUid);
    if (heFollowsMe) return FollowState.followBack;

    // 5. Default: Koi rishta nahi hai abhi
    return FollowState.follow;
  }

/*
  Future<FollowState> getFollowState({
    required String myUid,
    required String targetUid,
  }) async {
    // 1. already following?
    final isFollowing = await _provider.isFollowing(myUid, targetUid);
    if (isFollowing) return FollowState.following;

    // 2. request pending?
    final hasRequest = await _provider.hasRequestExist(myUid, targetUid);
    if (hasRequest) return FollowState.requested;


    // 3. default
    return FollowState.follow;
  }
*/

}