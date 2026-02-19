import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/comment_model.dart';
import '../repositories/comment_repository.dart';

class CommentController extends GetxController {
  final CommentRepository _repository = Get.find<CommentRepository>();
  final user = Supabase.instance.client.auth.currentUser;

  RxList<CommentModel> comments = <CommentModel>[].obs;

  /// 🔥 NEW
  var commentCounts = <String, int>{}.obs;
  RxBool isLoading = false.obs;


  /// 🔹 Initialize when post loads
  void initializePost(String postId, int dbCommentCount) {
    commentCounts[postId] ??= dbCommentCount;
  }

  /// LOAD COMMENTS
  Future<void> loadComments(String postId) async {
    try {
      isLoading.value = true;
      final result = await _repository.getComments(postId);
      comments.assignAll(result);

      /// 🔥 Update count from loaded comments
      commentCounts[postId] = result.length;
    } catch (e, stack) {
      debugPrint("❌ Load Comment Error: $e");
      debugPrint("📍 StackTrace: $stack");
    } finally {
      isLoading.value = false;
    }
  }

  /// ADD COMMENT (Parent or Child)
  Future<void> addComment({
    required String postId,
    required String text,
    String? parentId,
  }) async {
    try {
      final comment = CommentModel(
        id: '',
        userId: user!.id,
        postId: postId,
        parentId: parentId,
        commentText: text,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _repository.addComment(comment);

      await loadComments(postId); // refresh
    } catch (e) {
      print("Add Comment Error: $e");
    }
  }

  /// UPDATE
  Future<void> updateComment(String id, String newText, String postId) async {
    try {
      await _repository.editComment(id, newText);
      await loadComments(postId);
    } catch (e) {
      print("Update Comment Error: $e");
    }
  }

  /// DELETE
  Future<void> deleteComment(String id, String postId) async {
    try {
      await _repository.removeComment(id);
      await loadComments(postId);
    } catch (e) {
      print("Delete Comment Error: $e");
    }
  }

  /// PARENT COMMENTS ONLY
  List<CommentModel> get parentComments =>
      comments.where((c) => c.parentId == null).toList();

  /// GET REPLIES
  List<CommentModel> replies(String parentId) =>
      comments.where((c) => c.parentId == parentId).toList();

  int commentCount(String postId) =>
      commentCounts[postId] ?? 0;
}
