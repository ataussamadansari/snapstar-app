import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String username;
  final String email;
  final String phone;
  final String photoUrl;
  final String bio;

  final int followerCount;
  final int followingCount;
  final int postsCount;

  final bool isPrivate;
  final bool isBlocked;

  final String fcmToken;

  final String role;
  final Timestamp lastSeen;
  final bool isOnline;

  final Timestamp createdAt;
  final Timestamp updatedAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.username,
    required this.email,
    required this.phone,
    required this.photoUrl,
    required this.bio,
    required this.followerCount,
    required this.followingCount,
    required this.postsCount,
    required this.isPrivate,
    required this.isBlocked,
    required this.role,
    required this.fcmToken,
    required this.lastSeen,
    required this.isOnline,
    required this.createdAt,
    required this.updatedAt,

  });

  /// Firestore → UserModel
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
      bio: map['bio'] ?? '',
      followerCount: map['followerCount'] ?? 0,
      followingCount: map['followingCount'] ?? 0,
      postsCount: map['postsCount'] ?? 0,
      isPrivate: map['isPrivate'] ?? false,
      isBlocked: map['isBlocked'] ?? false,
      role: map['role'] ?? 'user',
      fcmToken: map['fcmToken'] ?? '',
      lastSeen: map['lastSeen'] ?? Timestamp.now(),
      isOnline: map['isOnline'] ?? false,
      createdAt: map['createdAt'] ?? Timestamp.now(),
      updatedAt: map['updatedAt'] ?? Timestamp.now(),
    );
  }

  /// UserModel → Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'username': username,
      'email': email,
      'phone': phone,
      'photoUrl': photoUrl,
      'bio': bio,
      'followerCount': followerCount,
      'followingCount': followingCount,
      'postsCount': postsCount,
      'isPrivate': isPrivate,
      'isBlocked': isBlocked,
      'role': role,
      'fcmToken': fcmToken,
      'lastSeen': lastSeen,
      'isOnline': isOnline,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  /// CopyWith (VERY useful for updates)
  UserModel copyWith({
    String? name,
    String? username,
    String? photoUrl,
    String? bio,
    int? followerCount,
    int? followingCount,
    int? postsCount,
    bool? isPrivate,
    bool? isBlocked,
    bool? isOnline,
    Timestamp? lastSeen,
    Timestamp? updatedAt,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      username: username ?? this.username,
      email: email,
      phone: phone,
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
      followerCount: followerCount ?? this.followerCount,
      followingCount: followingCount ?? this.followingCount,
      postsCount: postsCount ?? this.postsCount,
      isPrivate: isPrivate ?? this.isPrivate,
      isBlocked: isBlocked ?? this.isBlocked,
      role: role,
      fcmToken: fcmToken,
      lastSeen: lastSeen ?? this.lastSeen,
      isOnline: isOnline ?? this.isOnline,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
