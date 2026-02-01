import 'package:snapstar/app/core/constants/firebase_constants.dart';
import 'package:snapstar/app/data/models/user_model.dart';
import 'package:snapstar/app/data/models/user_snapshot.dart';
import 'package:snapstar/app/data/providers/user_provider.dart';

class UserRepository {
  final UserProvider provider = UserProvider();

  Future<UserModel?> getUser(String uid) {
    return provider.getUser(uid);
  }

  Future<UserModel?> getCurrentUserDetails() async {
    final user = firebaseAuth.currentUser;
    if (user == null) return null;
    return provider.getUser(user.uid);
  }

  Future<UserSnapshot?> getUserSnapShot(String uid) async {
    final user = await getUser(uid);
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
    return getUserSnapShot(user.uid);
  }

}

