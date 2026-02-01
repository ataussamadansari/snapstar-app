import 'package:cloud_firestore/cloud_firestore.dart';

class FollowUserModel {
  final String uid;
  final String username;
  final String name;
  final String photoUrl;

  final bool isPrivate;
  final bool isBlocked;

  final Timestamp followedAt;

  FollowUserModel({
    required this.uid,
    required this.username,
    required this.name,
    required this.photoUrl,
    required this.isPrivate,
    required this.isBlocked,
    required this.followedAt,
  });

  /// Firestore → Model
  factory FollowUserModel.fromMap(Map<String, dynamic> map) {
    return FollowUserModel(
      uid: map['uid'] ?? '',
      username: map['username'] ?? '',
      name: map['name'] ?? '',
      photoUrl: map['photoUrl'] ??
          'https://firebasestorage.googleapis.com/v0/b/adroit-hall-451612-t1.firebasestorage.app/o/download.jfif?alt=media',
      isPrivate: map['isPrivate'] ?? false,
      isBlocked: map['isBlocked'] ?? false,
      followedAt: map['followedAt'] ?? Timestamp.now(),
    );
  }

  /// Model → Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'name': name,
      'photoUrl': photoUrl,
      'isPrivate': isPrivate,
      'isBlocked': isBlocked,
      'followedAt': followedAt,
    };
  }
}
