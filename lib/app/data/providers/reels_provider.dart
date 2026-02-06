import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/firebase_constants.dart';

class ReelsProvider {
  final _postsRef = db.collection('posts');

  Future<QuerySnapshot> fetchReelsPage({
    DocumentSnapshot? lastDoc,
    int limit = 5,
  }) {
    Query query = _postsRef
        .where('mediaType', isEqualTo: 'video')
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (lastDoc != null) {
      query = query.startAfterDocument(lastDoc);
    }

    return query.get();
  }
}
