import 'package:snapstar/app/core/constants/firebase_constants.dart';

class HomeProvider {
  Stream<List<Map<String, dynamic>>> getGlobalFeed() {
    return db.collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => doc.data()).toList());
  }

  Stream<List<Map<String, dynamic>>> getActiveStories() {
    DateTime twentyFourHoursAgo = DateTime.now().subtract(const Duration(hours: 24));
    return db.collection('stories')
        .where('createdAt', isGreaterThan: twentyFourHoursAgo)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => doc.data()).toList());
  }
}