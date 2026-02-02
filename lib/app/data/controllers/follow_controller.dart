import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../core/constants/firebase_constants.dart';
import '../models/follow_user_model.dart';
import '../models/user_model.dart';
import '../repositories/follow_repository.dart';

enum FollowState { follow, requested, following, followBack, requestedMe }

class FollowController extends GetxController {
  final FollowRepository _repo = FollowRepository();

  String get myUid => firebaseAuth.currentUser?.uid ?? '';

  /// 🔥 userId -> FollowState
  final RxMap<String, FollowState> followStates = <String, FollowState>{}.obs;

  /// 🔥 loading per user (button disable)
  final RxMap<String, bool> loading = <String, bool>{}.obs;

  /// ───────── INIT FOR USER (CALL WHEN USER CARD LOADS) ─────────
  Future<void> initUser(UserModel user) async {
    if (user.uid == myUid) return;
    if (followStates.containsKey(user.uid)) return;

    // 1. Check if I am following him
    final iFollowHim = await _repo.isFollowing(myUid, user.uid);
    if (iFollowHim) {
      followStates[user.uid] = FollowState.following;
      return;
    }

    // 2. 🔥 NEW: Check if HE requested ME (Incoming Request)
    // Iske liye repo mein hasIncomingRequest banana hoga
    final heRequestedMe = await _repo.hasSentRequest(user.uid, myUid); //
    if (heRequestedMe) {
      followStates[user.uid] = FollowState.requestedMe;
      return;
    }

    // 3. Check if I requested him
    final iRequestedHim = await _repo.hasSentRequest(myUid, user.uid);
    if (iRequestedHim) {
      followStates[user.uid] = FollowState.requested;
      return;
    }

    // 4. Follow Back check
    final heFollowsMe = await _repo.isFollowing(user.uid, myUid);
    followStates[user.uid] = heFollowsMe ? FollowState.followBack : FollowState.follow;
  }



  /// ───────── FOLLOW BUTTON TAP ─────────
  /// ───────── FOLLOW BUTTON TAP ─────────
  Future<void> onFollowTap(UserModel targetUser) async {
    final uid = targetUser.uid;
    if (uid == myUid) return;

    loading[uid] = true;
    final currentState = followStates[uid] ?? FollowState.follow;

    try {
      if (currentState == FollowState.follow || currentState == FollowState.followBack) {
        // Follow Logic
        await _repo.follow(me: await _getMe(), target: targetUser);
        followStates[uid] = targetUser.isPrivate
            ? FollowState.requested
            : FollowState.following;

      } else if (currentState == FollowState.following || currentState == FollowState.requested) {
        // 🔥 CANCEL / UNFOLLOW Logic
        // Dono cases mein repository ka unfollow kaam karega
        await _repo.unfollow(uid);

        // Update state: check if we should show 'Follow' or 'Follow Back'
        final heFollowsMe = await _repo.isFollowing(uid, myUid);
        followStates[uid] = heFollowsMe ? FollowState.followBack : FollowState.follow;
      }
    } catch (e) {
      debugPrint("Toggle Error: $e");
    } finally {
      loading[uid] = false;
    }
  }

  
  /*Future<void> onFollowTap(UserModel targetUser) async {
    final uid = targetUser.uid;
    if (uid == myUid) return;

    loading[uid] = true;

    final currentState = followStates[uid] ?? FollowState.follow;

    try {
      if (currentState == FollowState.follow) {
        await _repo.follow(me: await _getMe(), target: targetUser);

        followStates[uid] = targetUser.isPrivate
            ? FollowState.requested
            : FollowState.following;
      } else if (currentState == FollowState.following) {
        await _repo.unfollow(uid);
        followStates[uid] = FollowState.follow;
      } else if (currentState == FollowState.followBack) {
        await _repo.follow(me: await _getMe(), target: targetUser);

        followStates[uid] = FollowState.following;
      }
    } catch (e) {
      debugPrint("$e");
    } finally {
      loading[uid] = false;
    }
  }*/

  /// ───────── ACCEPT REQUEST ─────────
  Future<void> acceptRequest(UserModel requester) async { // Specify the type here
    loading[requester.uid] = true; // Optional: show loading on the card

    try {
      final meModel = await _getMe();

      // 🔥 FIX: Convert requester (UserModel) to FollowUserModel
      // Assuming you have a helper like .toFollowUser() or can use fromMap
      final followUser = FollowUserModel(
        uid: requester.uid,
        username: requester.username,
        name: requester.name,
        photoUrl: requester.photoUrl,
        isPrivate: requester.isPrivate,
        isBlocked: requester.isBlocked,
        followedAt: Timestamp.now(),
      );

      await _repo.acceptFollowRequest(
        me: meModel,
        requester: followUser,
      );

      followStates[requester.uid] = FollowState.followBack;
    } catch (e) {
      debugPrint("Accept Error: $e");
    } finally {
      loading[requester.uid] = false;
    }
  }

  /// ───────── REJECT REQUEST ─────────
  Future<void> rejectRequest(String requesterUid) async {
    await _repo.rejectFollowRequest(requesterUid);
    followStates.remove(requesterUid);
  }

  /// ───────── HELPERS ─────────
  FollowState stateOf(String uid) => followStates[uid] ?? FollowState.follow;

  bool isLoading(String uid) => loading[uid] ?? false;

  /// 🔥 current user snapshot (cache later if needed)
  Future<UserModel> _getMe() async {
    // tumhara existing UserRepository yaha use hoga
    final snap = await db.collection('users').doc(myUid).get();
    return UserModel.fromMap(snap.data()!);
  }
}
