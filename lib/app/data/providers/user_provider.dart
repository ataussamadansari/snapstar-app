import 'package:supabase_flutter/supabase_flutter.dart';

class UserProvider {
  final _supabase = Supabase.instance.client;

  /// 🔹 Get suggested users (exclude self)
  Future<List<Map<String, dynamic>>> getSuggestedUsers({
    required String myId,
    required int limit,
    required int offset,
  }) async {
    final res = await _supabase
        .from('users')
        .select('id, username, name, avatar_url')
        .neq('id', myId)
        .range(offset, offset + limit - 1);

    return List<Map<String, dynamic>>.from(res);
  }

  /// CREATE USER PROFILE
  Future<void> createUser(Map<String, dynamic> data) async {
    await _supabase.from('users').insert(data);
  }

  /// GET USER PROFILE
  Future<Map<String, dynamic>?> getUser(String uid) async {
    return await _supabase
        .from('users')
        .select()
        .eq('id', uid)
        .maybeSingle();
  }

  /// UPDATE USER PROFILE
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _supabase.from('users').update(data).eq('id', uid);
  }

  /// CHECK USERNAME UNIQUE
  Future<bool> isUsernameAvailable(String username) async {
    final res = await _supabase
        .from('users')
        .select('id')
        .eq('username', username)
        .maybeSingle();

    return res == null;
  }
}
