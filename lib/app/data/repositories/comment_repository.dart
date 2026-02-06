import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/comment_model.dart';
import '../providers/comment_provider.dart';
import 'user_repository.dart';

class CommentRepository {
  final CommentProvider _provider = CommentProvider();
  final UserRepository _userRepo = UserRepository();

  Future<void> addComment({
    required String postId,
    required String text,
    String? parentId,
  }) async {
    final userSnapshot = await _userRepo.getCurrentUserSnapshot();
    if(userSnapshot == null) return;

    final comment = CommentModel(
      commentId: DateTime.now().millisecondsSinceEpoch.toString(),
      postId: postId,
      user: userSnapshot,
      text: text,
      parentId: parentId,
      createdAt: DateTime.now(),
    );

    await _provider.addComment(comment);
  }

  Stream<List<CommentModel>> getComments(String postId) {
    return _provider.getComments(postId);
  }

  Future<QuerySnapshot> getCommentsPage({
    required String postId,
    DocumentSnapshot? lastDoc,
  }) {
    return _provider.getCommentsPage(
      postId: postId,
      lastDoc: lastDoc,
    );
  }

  Future<void> updateComment({
    required String postId,
    required String commentId,
    required String text,
  }) {
    return _provider.updateComment(
      postId: postId,
      commentId: commentId,
      text: text,
    );
  }

  Future<void> deleteCommentTree({
    required String postId,
    required String commentId,
  }) {
    return _provider.deleteCommentTree(
      postId: postId,
      commentId: commentId,
    );
  }

}
