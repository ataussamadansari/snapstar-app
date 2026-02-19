import 'package:supabase_flutter/supabase_flutter.dart';

class CommentProvider {
  final SupabaseClient _client = Supabase.instance.client;

  /// CREATE COMMENT
  Future<void> createComment(Map<String, dynamic> data) async {
    await _client.from('comments').insert(data);
  }

  /// GET COMMENTS (with user join)
  Future<List<Map<String, dynamic>>> fetchComments(String postId) async {
    final response = await _client
        .from('comments')
        .select('*, users(*)')
        .eq('post_id', postId)
        .order('created_at', ascending: true);

    return List<Map<String, dynamic>>.from(response);
  }

  /// UPDATE COMMENT
  Future<void> updateComment(String id, String newText) async {
    await _client
        .from('comments')
        .update({
      'comment_text': newText,
      'updated_at': DateTime.now().toIso8601String(),
    })
        .eq('id', id);
  }

  /// DELETE COMMENT
  Future<void> deleteComment(String id) async {
    await _client.from('comments').delete().eq('id', id);
  }
}
