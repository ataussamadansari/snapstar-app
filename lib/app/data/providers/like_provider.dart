import 'package:supabase_flutter/supabase_flutter.dart';

class LikeProvider {
  final _supabase = Supabase.instance.client;

  Future<void> addLike(String postId, String userId) async {
    await _supabase.from('likes').insert({
      'post_id': postId,
      'user_id': userId,
    });
  }

  Future<void> removeLike(String postId, String userId) async {
    await _supabase.from('likes').delete().match({
      'post_id': postId,
      'user_id': userId,
    });
  }

  Future<bool> isPostLiked(String postId, String userId) async {
    final res = await _supabase
        .from('likes')
        .select('id')
        .eq('post_id', postId)
        .eq('user_id', userId)
        .maybeSingle();
    return res != null;
  }

  // 🔹 Raw list of users who liked
  Future<List<Map<String, dynamic>>> fetchLikes(String postId) async {
    final res = await _supabase
        .from('likes')
        .select('*, users(*)')
        .eq('post_id', postId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(res);
  }
}