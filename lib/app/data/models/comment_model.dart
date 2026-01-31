import 'package:cloud_firestore/cloud_firestore.dart';

import 'user_snapshot.dart';

class CommentModel {
  final String commentId;
  final String postId;
  final UserSnapshot user;
  final String text;
  final String? parentId;
  final DateTime createdAt;

  CommentModel({
    required this.commentId,
    required this.postId,
    required this.user,
    required this.text,
    this.parentId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'commentId': commentId,
    'postId': postId,
    'user': user.toMap(),
    'text': text,
    'parentId': parentId,
    'createdAt': createdAt,
  };

  factory CommentModel.fromMap(Map<String, dynamic> map) {
    return CommentModel(
      commentId: map['commentId'],
      postId: map['postId'],
      user: UserSnapshot.fromMap(map['user']),
      text: map['text'],
      parentId: map['parentId'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

}