import 'package:snapstar/app/core/constants/firebase_constants.dart';
import 'package:snapstar/app/data/models/user_model.dart';
import 'package:snapstar/app/data/providers/user_provider.dart';


class UserRepository {
  final UserProvider provider = UserProvider();

  // Current user ki complete details get karna
  Future<UserModel?> getCurrentUserDetails() async {
    final user = firebaseAuth.currentUser;
    if (user != null) {
      return await provider.getUserData(user.uid);
    }
    return null;
  }

  Future<UserModel?> getUserDetailsById(String userId) async {
    try {
      final doc = await db.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }
    } catch (e) {
      print("Error fetching user: $e");
    }
    return null;
  }
}
