import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/firebase_constants.dart';

class FirebaseAuthProvider {
  Stream<User?> get authState => firebaseAuth.authStateChanges();

  Future<UserCredential> login(String email, String password) {
    return firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> register(String email, String password) {
    return firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> logout() => firebaseAuth.signOut();

  User? get currentUser => firebaseAuth.currentUser;
}
