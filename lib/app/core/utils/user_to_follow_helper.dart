import 'package:cloud_firestore/cloud_firestore.dart';

import '../../data/models/follow_user_model.dart';
import '../../data/models/user_model.dart';

extension UserToFollowMapper on UserModel {
  FollowUserModel toFollowUser() {
    return FollowUserModel(
      uid: uid,
      username: username,
      name: name,
      photoUrl: photoUrl,
      isPrivate: isPrivate,
      isBlocked: isBlocked,
      followedAt: Timestamp.now(),
    );
  }
}


extension FollowUserToUserMapper on FollowUserModel {
  UserModel toUserModel() {
    return UserModel(
      uid: uid,
      name: name,
      username: username,
      email: '',
      phone: '',
      photoUrl: photoUrl,
      bio: '',
      followerCount: 0,
      followingCount: 0,
      postsCount: 0,
      isPrivate: isPrivate,
      isBlocked: isBlocked,
      role: 'user',
      fcmToken: '',
      lastSeen: Timestamp.now(),
      isOnline: false,
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
    );
  }
}