import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../../core/constants/firebase_constants.dart';
import '../models/comment_model.dart';
import '../repositories/comment_repository.dart';

class CommentController extends GetxController {
  final CommentRepository _repo = CommentRepository();

  final currentUserId = firebaseAuth.currentUser!.uid;
  final comments = <CommentModel>[].obs;
  final isLoading = false.obs;

  /// 🔁 REPLY
  final replyingToCommentId = RxnString();
  final replyingToUsername = RxnString();

  /// ✏️ EDIT (USING SAME INPUT)
  final editingCommentId = RxnString();

  /// 🔁 COLLAPSE STATE (commentId -> expanded)
  final RxMap<String, bool> expandedReplies = <String, bool>{}.obs;

  DocumentSnapshot? lastDoc;
  bool hasMore = true;
  bool isFetchingMore = false;

  late String postId;

  void init(String id) {
    postId = id;
    loadInitial();
    // _repo.getComments(postId).listen(comments.assignAll);
  }

  Future<void> loadInitial() async {
    comments.clear();
    lastDoc = null;
    hasMore = true;
    await loadMore();
  }

  Future<void> loadMore() async {
    if (!hasMore || isFetchingMore) return;

    isFetchingMore = true;

    final snap = await _repo.getCommentsPage(
      postId: postId,
      lastDoc: lastDoc,
    );

    if (snap.docs.isNotEmpty) {
      lastDoc = snap.docs.last;

      final newComments = snap.docs
          .map((d) => CommentModel.fromMap(d.data() as Map<String, dynamic>))
          .toList();

      comments.addAll(newComments);
    }

    if (snap.docs.length < 15) {
      hasMore = false;
    }

    isFetchingMore = false;
  }


  /// ───────── START EDIT ─────────
  void startEdit(CommentModel c, String currentText) {
    editingCommentId.value = c.commentId;
    replyingToCommentId.value = null;
    replyingToUsername.value = null;
  }

  void cancelEdit() {
    editingCommentId.value = null;
  }

  /// ───────── START REPLY ─────────
  void startReply(CommentModel c) {
    replyingToCommentId.value = c.commentId;
    replyingToUsername.value = c.user.username;
    editingCommentId.value = null;
  }

  void cancelReply() {
    replyingToCommentId.value = null;
    replyingToUsername.value = null;
  }

  /// ───────── SUBMIT (ADD / EDIT / REPLY) ─────────
  Future<void> submit(String text) async {
    if (text.trim().isEmpty) return;

    isLoading.value = true;

    /// ✏️ EDIT
    if (editingCommentId.value != null) {
      await _repo.updateComment(
        postId: postId,
        commentId: editingCommentId.value!,
        text: text.trim(),
      );
      editingCommentId.value = null;
    }

    /// 💬 REPLY
    else if (replyingToCommentId.value != null) {
      await _repo.addComment(
        postId: postId,
        text: text.trim(),
        parentId: replyingToCommentId.value,
      );
      cancelReply();
    }

    /// ➕ NEW COMMENT
    else {
      await _repo.addComment(
        postId: postId,
        text: text.trim(),
      );
    }

    isLoading.value = false;
  }

  /// ───────── DELETE ─────────
  bool canDelete(CommentModel c, String postOwnerId) {
    return c.user.uid == currentUserId ||
        postOwnerId == currentUserId;
  }

  Future<void> delete(CommentModel c) async {
    await _repo.deleteCommentTree(
      postId: postId,
      commentId: c.commentId,
    );
  }

  /// toggle replies
  void toggleReplies(String commentId) {
    expandedReplies[commentId] =
    !(expandedReplies[commentId] ?? false);
  }

  /// check expanded?
  bool isExpanded(String commentId) {
    return expandedReplies[commentId] ?? false;
  }

  /// ───────── FILTERS ─────────
  List<CommentModel> get mainComments =>
      comments.where((c) => c.parentId == null).toList();

  List<CommentModel> repliesOf(String id) =>
      comments.where((c) => c.parentId == id).toList();
}
