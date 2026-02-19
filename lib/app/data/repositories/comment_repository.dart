import 'package:flutter/cupertino.dart';

import '../models/comment_model.dart';
import '../providers/comment_provider.dart';

class CommentRepository {
  final CommentProvider _provider;

  CommentRepository(this._provider);

  Future<void> addComment(CommentModel comment) async {
    await _provider.createComment(comment.toJson());
  }

  Future<List<CommentModel>> getComments(String postId) async {
    final data = await _provider.fetchComments(postId);

    debugPrint("Comments: $data");

    return data
        .map((json) => CommentModel.fromJson(json))
        .toList();
  }

  Future<void> editComment(String id, String newText) async {
    await _provider.updateComment(id, newText);
  }

  Future<void> removeComment(String id) async {
    await _provider.deleteComment(id);
  }
}
