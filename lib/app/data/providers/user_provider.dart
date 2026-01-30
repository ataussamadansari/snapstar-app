import 'package:snapstar/app/data/models/user_model.dart';

import '../../core/constants/firebase_constants.dart';

class UserProvider{
  Future<UserModel?> getUserData(String uid) async {
    final doc = await db.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data()!);
    }
    return null;
  }

  // Real-time updates ke liye (Profile screen wagera mein kaam aayega)
  Stream<UserModel> getUserStream(String uid) {
    return db.collection('users').doc(uid).snapshots().map((doc) {
      return UserModel.fromMap(doc.data()!);
    });
  }
}