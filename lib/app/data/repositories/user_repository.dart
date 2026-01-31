import 'package:snapstar/app/core/constants/firebase_constants.dart';
import 'package:snapstar/app/data/models/user_model.dart';
import 'package:snapstar/app/data/models/user_snapshot.dart';
import 'package:snapstar/app/data/providers/user_provider.dart';

class UserRepository {
  final UserProvider provider = UserProvider();

  /// Current logged-in user
  Future<UserModel?> getCurrentUserDetails() async {
    final user = firebaseAuth.currentUser;
    if (user == null) return null;
    return await provider.getUserData(user.uid);
  }

  /// Any user by id
  Future<UserModel?> getUserDetailsById(String userId) async {
    try {
      return await provider.getUserData(userId);
    } catch (e) {
      return null;
    }
  }

  /// 🔥 FINAL & CORRECT SNAPSHOT METHOD
  Future<UserSnapshot?> getUserSnapShot(String uid) async {
    final user = await getUserDetailsById(uid);
    if (user == null) return null;

    return UserSnapshot(
      uid: user.uid,
      username: user.username,
      name: user.name,
      photoUrl: user.photoUrl,
    );
  }

  Future<UserSnapshot?> getCurrentUserSnapshot() async {
    final user = firebaseAuth.currentUser;
    if (user == null) return null;

    final userModel = await provider.getUserData(user.uid);
    if (userModel == null) return null;

    return UserSnapshot(
      uid: userModel.uid,
      username: userModel.username,
      name: userModel.name,
      photoUrl: userModel.photoUrl,
    );
  }

}
