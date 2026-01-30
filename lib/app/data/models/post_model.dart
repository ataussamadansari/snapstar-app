import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:snapstar/app/data/models/user_model.dart';

enum MediaType { image, video, mixed }

class PostModel {
  final String postId;
  final String userId;
  final String caption;
  final MediaType mediaType ;
  final List<String> mediaUrls;
  final List<String> thumbnailUrls;
  final int likeCount;
  final int commentCount;
  final int shareCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final String? location;
  final List<String>? tags;
  UserModel? user;

  PostModel({
    required this.postId,
    required this.userId,
    required this.caption,
    required this.mediaType,
    required this.mediaUrls,
    required this.thumbnailUrls,
    this.likeCount = 0,
    this.commentCount = 0,
    this.shareCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
    this.location,
    this.tags,
    this.user,
  });

  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'userId': userId,
      'caption': caption,
      'mediaType': mediaType.name,
      'mediaUrls': mediaUrls,
      'thumbnailUrls': thumbnailUrls,
      'likeCount': likeCount,
      'commentCount': commentCount,
      'shareCount': shareCount,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'isDeleted': isDeleted,
      'location': location,
      'tags': tags
    };
  }

  factory PostModel.fromMap(Map<String, dynamic> map) {
    return PostModel(
      postId: map['postId'] ?? '',
      userId: map['userId'] ?? '',
      caption: map['caption'] ?? '',
      mediaType: MediaType.values.firstWhere((e) => e.name == map['mediaType']),
      mediaUrls: List<String>.from(map['mediaUrls']),
      thumbnailUrls: List<String>.from(map['thumbnailUrls']),
      likeCount: map['likeCount'] ?? 0,
      commentCount: map['commentCount'] ?? 0,
      shareCount: map['shareCount'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      isDeleted: map['isDeleted'] ?? false,
      location: map['location'],
      tags: map['tags'] != null ? List<String>.from(map['tags']) : [],
    );
  }
}