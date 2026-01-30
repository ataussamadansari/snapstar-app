import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:snapstar/app/core/constants/firebase_constants.dart';
import 'package:snapstar/app/data/models/user_model.dart';

import '../providers/firebase_auth_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final FirebaseAuthProvider provider;
  AuthRepository(this.provider);


  Future<User?> login(String email, String password) async {
    final result = await provider.login(email, password);
    return result.user;
  }


  Future<User?> register(String email, String password) async {
    final result = await provider.register(email, password);
    return result.user;
  }

  Future<void> saveUserProfile(UserModel user) async {
    await db.collection('users').doc(user.uid).set(user.toMap());
  }

  Future<bool> isProfileCompleted(String uid) async {
    final doc = await db.collection('users').doc(uid).get();
    return doc.exists;
  }

  Future<void> updateFCMToken(String uid, String token) async {
    await db.collection('users').doc(uid).update({
      'fcmToken': token,
      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> logout() async {
    await provider.logout();
  }
}
