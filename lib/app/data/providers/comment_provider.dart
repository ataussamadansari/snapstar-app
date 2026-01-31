import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/firebase_constants.dart';
import '../models/comment_model.dart';

class CommentProvider {
  CollectionReference _commentRef(String postId) =>
      db.collection('posts').doc(postId).collection('comments');

  Future<void> addComment(CommentModel comment) async {
    final batch = db.batch();

    final commentDoc = _commentRef(comment.postId).doc(comment.commentId);

    batch.set(commentDoc, comment.toMap());

    batch.update(db.collection('posts').doc(comment.postId), {
      'commentCount': FieldValue.increment(1),
    });

    await batch.commit();
  }

  Stream<List<CommentModel>> getComments(String postId) {
    return _commentRef(postId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map(
                (d) => CommentModel.fromMap(d.data() as Map<String, dynamic>),
              )
              .toList(),
        );
  }

  Future<QuerySnapshot> getCommentsPage({
    required String postId,
    DocumentSnapshot? lastDoc,
    int limit = 15,
  }) {
    Query q = _commentRef(
      postId,
    ).orderBy('createdAt', descending: true).limit(limit);

    if (lastDoc != null) {
      q = q.startAfterDocument(lastDoc);
    }

    return q.get();
  }

  Future<void> updateComment({
    required String postId,
    required String commentId,
    required String text,
  }) {
    return db
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(commentId)
        .update({'text': text, 'editedAt': FieldValue.serverTimestamp()});
  }

  Future<void> deleteCommentTree({
    required String postId,
    required String commentId,
  }) async {
    final batch = db.batch();
    final commentsRef = db
        .collection('posts')
        .doc(postId)
        .collection('comments');

    // 1️⃣ Delete main comment
    final mainRef = commentsRef.doc(commentId);
    batch.delete(mainRef);

    // 2️⃣ Find replies
    final repliesSnap = await commentsRef
        .where('parentId', isEqualTo: commentId)
        .get();

    for (final doc in repliesSnap.docs) {
      batch.delete(doc.reference);
    }

    // 3️⃣ Update count
    final totalDeleted = 1 + repliesSnap.docs.length;

    batch.update(db.collection('posts').doc(postId), {
      'commentCount': FieldValue.increment(-totalDeleted),
    });

    await batch.commit();
  }
}
