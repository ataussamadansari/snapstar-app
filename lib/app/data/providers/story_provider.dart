import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

import '../../core/constants/firebase_constants.dart';
import '../models/story_model.dart';

class StoryProvider {

  /// 🔥 File Upload to Storage
  Future<String> uploadStoryFile(File file, String uid) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference ref = storage.ref().child('stories/$uid/$fileName');

    UploadTask uploadTask = ref.putFile(file);
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  /// 📝 Create Story Document
  Future<void> createStory(StoryModel story) async {
    await db.collection('stories').doc(story.storyId).set(story.toMap());
  }

  /// 📸 Save Story to Firestore
  Future<void> saveStory(StoryModel story) async {
    await db.collection('stories').doc(story.storyId).set(story.toMap());
  }

  /// 🔍 Fetch Live Stories (Last 24 Hours)
  Stream<List<Map<String, dynamic>>> getStories(List<String> followingIds) {
    // 24 hours ago timestamp
    DateTime twentyFourHoursAgo = DateTime.now().subtract(const Duration(hours: 24));

    return db
        .collection('stories')
        .where('userId', whereIn: followingIds)
        .where('createdAt', isGreaterThan: twentyFourHoursAgo) // 🔥 24 hrs logic
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// 🗑 Delete Story (Optional: Manual cleanup)
  Future<void> deleteStory(String storyId) async {
    await db.collection('stories').doc(storyId).delete();
  }
}