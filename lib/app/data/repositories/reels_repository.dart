import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post_model.dart';
import '../providers/reels_provider.dart';

class ReelsRepository {
  final ReelsProvider _provider = ReelsProvider();

  Future<({List<PostModel> reels, DocumentSnapshot? lastDoc})>
  fetchReels({
    DocumentSnapshot? lastDoc,
  }) async {
    final snap = await _provider.fetchReelsPage(lastDoc: lastDoc);

    final reels = snap.docs
        .map((d) => PostModel.fromMap(d.data() as Map<String, dynamic>))
        .toList();

    return (
    reels: reels,
    lastDoc: snap.docs.isNotEmpty ? snap.docs.last : lastDoc
    );
  }
}
