import 'package:cloud_firestore/cloud_firestore.dart';

enum MediaType { image, video, mixed }

class StoryModel {
  final String storyId;
  final String userId;
  final String username;
  final String userImage;
  final String mediaUrl;
  final bool isVideo;
  final DateTime createdAt;

  StoryModel({
    required this.storyId,
    required this.userId,
    required this.username,
    required this.userImage,
    required this.mediaUrl,
    this.isVideo = false,
    required this.createdAt,
  });

  // Firestore se data lene ke liye
  factory StoryModel.fromMap(Map<String, dynamic> map) {
    return StoryModel(
      storyId: map['storyId'] ?? '',
      userId: map['userId'] ?? '',
      username: map['username'] ?? 'User',
      userImage: map['userImage'] ?? '',
      mediaUrl: map['mediaUrl'] ?? '',
      isVideo: map['isVideo'] ?? false,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  // Firestore mein data save karne ke liye
  Map<String, dynamic> toMap() {
    return {
      'storyId': storyId,
      'userId': userId,
      'username': username,
      'userImage': userImage,
      'mediaUrl': mediaUrl,
      'isVideo': isVideo,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}