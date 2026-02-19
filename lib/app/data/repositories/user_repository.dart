import '../models/user_model.dart';
import '../providers/user_provider.dart';

class UserRepository {
  final UserProvider provider;

  UserRepository(this.provider);

  /// CREATE PROFILE
  Future<bool> createProfile(UserModel user) async {
    await provider.createUser(user.toJson());
    return true;
  }

  /// FETCH PROFILE
  Future<UserModel?> fetchProfile(String uid) async {
    final data = await provider.getUser(uid);
    if (data == null) return null;
    return UserModel.fromJson(data);
  }

  /// UPDATE PROFILE
  Future<void> updateProfile(String uid, Map<String, dynamic> data) async {
    await provider.updateUser(uid, data);
  }

  /// USERNAME CHECK
  Future<bool> checkUsername(String username) {
    return provider.isUsernameAvailable(username);
  }
}
