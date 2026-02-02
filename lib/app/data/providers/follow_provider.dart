
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/firebase_constants.dart';
import '../models/follow_user_model.dart';

class FollowProvider {
  DocumentReference userRef(String uid) =>
      db.collection('users').doc(uid);

  CollectionReference followersRef(String uid) =>
      userRef(uid).collection('followers');

  CollectionReference followingRef(String uid) =>
      userRef(uid).collection('following');

  CollectionReference followRequestRef(String uid) =>
      userRef(uid).collection('followRequests');

  /// 🔍 Check already following?
  Future<bool> isFollowing(String myUid, String targetUid) async {
    final doc = await followingRef(myUid).doc(targetUid).get();
    return doc.exists;
  }

  // follow_provider.dart
  Future<bool> hasRequestExist(String myUid, String targetUid) async {
    // Hum target user ki followRequests collection mein apni ID check karte hain
    final doc = await followRequestRef(targetUid).doc(myUid).get();
    return doc.exists;
  }

  /// 🔒 Send follow request (PRIVATE)
  Future<void> sendFollowRequest({
    required String targetUid,
    required FollowUserModel requester,
  }) async {
    await followRequestRef(targetUid)
        .doc(requester.uid)
        .set(requester.toMap());
  }

  /// ✅ Direct follow (PUBLIC)
  Future<void> followUser({
    required String myUid,
    required String targetUid,
    required FollowUserModel me,
    required FollowUserModel target,
  }) async {
    final batch = db.batch();

    // my → following
    batch.set(
      followingRef(myUid).doc(targetUid),
      target.toMap(),
    );

    // target → followers
    batch.set(
      followersRef(targetUid).doc(myUid),
      me.toMap(),
    );

    // counts
    batch.update(userRef(myUid), {
      'followingCount': FieldValue.increment(1),
    });

    batch.update(userRef(targetUid), {
      'followerCount': FieldValue.increment(1),
    });

    await batch.commit();
  }

  /// ❌ Unfollow
  Future<void> unfollow({
    required String myUid,
    required String targetUid,
  }) async {
    final batch = db.batch();

    batch.delete(followingRef(myUid).doc(targetUid));
    batch.delete(followersRef(targetUid).doc(myUid));

    batch.update(userRef(myUid), {
      'followingCount': FieldValue.increment(-1),
    });

    batch.update(userRef(targetUid), {
      'followerCount': FieldValue.increment(-1),
    });

    await batch.commit();
  }

  /// ✅ Accept follow request
  Future<void> acceptRequest({
    required String myUid,
    required FollowUserModel requester,
    required FollowUserModel me,
  }) async {
    final batch = db.batch();

    // remove request
    batch.delete(followRequestRef(myUid).doc(requester.uid));

    // add follow
    batch.set(followersRef(myUid).doc(requester.uid), requester.toMap());
    batch.set(followingRef(requester.uid).doc(myUid), me.toMap());

    batch.update(userRef(myUid), {
      'followerCount': FieldValue.increment(1),
    });

    batch.update(userRef(requester.uid), {
      'followingCount': FieldValue.increment(1),
    });

    await batch.commit();
  }

  /// ❌ Reject follow request
  Future<void> rejectRequest({
    required String myUid,
    required String requesterUid,
  }) async {
    await followRequestRef(myUid).doc(requesterUid).delete();
  }

  Future<void> cancelFollowRequest({
    required String myUid,
    required String targetUid,
  }) async {
    await followRequestRef(targetUid).doc(myUid).delete();
  }
}
