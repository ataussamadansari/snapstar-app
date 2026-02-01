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

