import 'package:snapstar/app/data/models/user_model.dart';

import '../../core/constants/firebase_constants.dart';

class UserProvider {
  Future<UserModel?> getUser(String uid) async {
    final doc = await db.collection('users').doc(uid).get();
    return doc.exists ? UserModel.fromMap(doc.data()!) : null;
  }

  Stream<UserModel> getUserStream(String uid) {
    return db.collection('users')
        .doc(uid)
        .snapshots()
        .map((d) => UserModel.fromMap(d.data()!));
  }

  Future<List<String>> getIncomingRequestIds(String uid) async {
    final snap = await db
        .collection('users')
        .doc(uid)
        .collection('followRequests') //
        .get();
    return snap.docs.map((d) => d.id).toList();
  }

  Future<List<String>> getFollowingIds(String uid) async {
    final snap = await db
        .collection('users')
        .doc(uid)
        .collection('following')
        .get();
    return snap.docs.map((d) => d.id).toList();
  }

  Future<List<String>> getFollowerIds(String uid) async {
    final snap = await db
        .collection('users')
        .doc(uid)
        .collection('followers')
        .get();
    return snap.docs.map((d) => d.id).toList();
  }

  Future<List<UserModel>> getUsersByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    final snap = await db
        .collection('users')
        .where('uid', whereIn: ids.take(10).toList())
        .get();
    return snap.docs.map((d) => UserModel.fromMap(d.data())).toList();
  }

  Future<List<UserModel>> getRandomUsers({
    required String myUid,
    int limit = 10,
  }) async {
    final snap = await db
        .collection('users')
        .orderBy('createdAt', descending: true)
        .limit(limit + 1)
        .get();

    return snap.docs
        .map((d) => UserModel.fromMap(d.data()))
        .where((u) => u.uid != myUid)
        .toList();
  }

  Future<List<Map<String, dynamic>>> getFollowersData(String uid) async {
    final snap = await db
        .collection('users')
        .doc(uid)
        .collection('followers')
        .get();
    return snap.docs.map((d) => d.data()).toList();
  }

  Future<List<Map<String, dynamic>>> getFollowingData(String uid) async {
    final snap = await db
        .collection('users')
        .doc(uid)
        .collection('following')
        .get();
    return snap.docs.map((d) => d.data()).toList();
  }
}

