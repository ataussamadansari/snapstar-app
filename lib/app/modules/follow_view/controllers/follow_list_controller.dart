import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:snapstar/app/core/utils/user_to_follow_helper.dart';

import '../../../core/constants/firebase_constants.dart';
import '../../../data/controllers/follow_controller.dart';
import '../../../data/models/follow_user_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/providers/user_provider.dart';
import '../../../data/repositories/follow_repository.dart';

class FollowListController extends GetxController {
  final UserProvider _userProvider = UserProvider();
  final FollowRepository _followRepo = FollowRepository();

  String get myUid => firebaseAuth.currentUser?.uid ?? '';

  final RxMap<String, FollowState> followStates = <String, FollowState>{}.obs;
  final RxMap<String, bool> loading = <String, bool>{}.obs;
  var followUsers = <FollowUserModel>[].obs;
  var isScLoading = true.obs;

  void fetchUsers(String uid, bool isFollowers) async {
    isScLoading.value = true;
    followUsers.clear();
    followStates.clear();

    try {
      List<Map<String, dynamic>> data = isFollowers
          ? await _userProvider.getFollowersData(uid)
          : await _userProvider.getFollowingData(uid);

      if (data.isNotEmpty) {
        followUsers.value = data
            .map((e) => FollowUserModel.fromMap(e))
            .toList();

        // 🔥 Pre-fetch states for all users in the list at once
        for (var user in followUsers) {
          _initUserState(user.uid);
        }
      }
    } finally {
      isScLoading.value = false;
    }
  }

  // Private method to handle logic inside controller
  Future<void> _initUserState(String targetUid) async {
    if (targetUid == myUid) return;

    final state = await _followRepo.getFollowState(
      myUid: myUid,
      targetUid: targetUid,
    );
    followStates[targetUid] = state;
  }

  // Wrapper for button tap to keep UI clean
  /// ───────── TOGGLE FOLLOW LOGIC ─────────
  Future<void> toggleFollow(FollowUserModel followUser) async {
    final uid = followUser.uid;
    if (uid == myUid) return;

    loading[uid] = true;
    final currentState = followStates[uid] ?? FollowState.follow;

    try {
      final targetUser = await _userProvider.getUser(uid);
      if (targetUser == null) return;
      final meModel = await _getMe();

      switch (currentState) {
        case FollowState.follow:
        case FollowState.followBack:
          await _followRepo.follow(me: meModel, target: targetUser);
          followStates[uid] = targetUser.isPrivate
              ? FollowState.requested
              : FollowState.following;
          break;

        case FollowState.following:
          // Direct unfollow
          await _followRepo.unfollow(uid);
          _updateAfterRemoval(uid);
          break;

        case FollowState.requested:
          // 🔥 CANCEL REQUEST LOGIC
          // Is case mein bhi unfollow repo hi call hoga jo request delete karega
          await _followRepo.unfollow(uid);
          _updateAfterRemoval(uid);
          break;

        case FollowState.requestedMe:
          await acceptRequest(targetUser);
          break;
      }
    } catch (e) {
      debugPrint("Toggle Error: $e");
    } finally {
      loading[uid] = false;
    }
  }

  // Helper taaki code repeat na ho
  void _updateAfterRemoval(String uid) async {
    // Check karo ki kya wo abhi bhi humein follow kar raha hai?
    final heFollowsMe = await _followRepo.isFollowing(uid, myUid);
    followStates[uid] = heFollowsMe
        ? FollowState.followBack
        : FollowState.follow;
  }

  /// ───────── ACCEPT REQUEST ─────────
  Future<void> acceptRequest(UserModel requester) async {
    try {
      final meModel = await _getMe();
      await _followRepo.acceptFollowRequest(
        me: meModel,
        requester: requester.toFollowUser(),
      );
      followStates[requester.uid] = FollowState.following;
    } catch (e) {
      debugPrint("Accept Error: $e");
    }
  }

  /// 🔥 Helper: Get Current User
  Future<UserModel> _getMe() async {
    final snap = await db.collection('users').doc(myUid).get();
    return UserModel.fromMap(snap.data()!);
  }
}

/*
import 'package:get/get.dart';
import '../../../core/constants/firebase_constants.dart';
import '../../../data/controllers/follow_controller.dart';
import '../../../data/models/follow_user_model.dart';
import '../../../data/providers/user_provider.dart';
import '../../../data/repositories/follow_repository.dart';

class FollowListController extends GetxController {
  final UserProvider _userProvider = UserProvider();
  final FollowRepository _followRepo = FollowRepository();

  // Ab hum UserModel ki jagah FollowUserModel use karenge
  var followUsers = <FollowUserModel>[].obs;
  var followStates = <String, FollowState>{}.obs;
  var isScLoading = true.obs;

  void fetchUsers(String uid, bool isFollowers) async {
    isScLoading.value = true;
    followUsers.clear();
    followStates.clear();

    try {
      // Direct data fetch kar rahe hain, alag se users collection call karne ki zaroorat nahi
      List<Map<String, dynamic>> data = isFollowers
          ? await _userProvider.getFollowersData(uid)
          : await _userProvider.getFollowingData(uid);

      if (data.isNotEmpty) {
        followUsers.value = data.map((e) => FollowUserModel.fromMap(e)).toList();
      }
      // 🔥 state calculate
      for (final user in followUsers) {
        final state = await _followRepo.getFollowState(
          myUid: firebaseAuth.currentUser!.uid,
          targetUid: user.uid,
        );
        followStates[user.uid] = state;
      }
    } finally {
      isScLoading.value = false;
    }
  }
}*/
