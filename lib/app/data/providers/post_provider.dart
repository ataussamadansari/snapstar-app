import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/post_model.dart';

class PostProvider {
  final _supabase = Supabase.instance.client;

  Future<void> createPost(Map<String, dynamic> data) async {
    await _supabase.from('posts').insert(data);
  }

  Future<List<Map<String, dynamic>>> fetchAllPosts() async {
    final res = await _supabase
        .from('posts')
        .select('*, users(*)')
        .eq('is_deleted', false)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(res);
  }

  Future<List<Map<String, dynamic>>> fetchUserPosts(
      String userId, {
        String? mediaType,
      }) async {
    var query = _supabase
        .from('posts')
        .select('*, users(*)')
        .eq('user_id', userId)
        .eq('is_deleted', false);

    if (mediaType != null) {
      query = query.eq('media_type', mediaType);
    }

    final res = await query.order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(res);
  }


  Future<List<Map<String, dynamic>>> fetchVideoPosts() async {
    final res = await _supabase
        .from('posts')
        .select('*, users(*)')
        .eq('media_type', 'video')
        .eq('is_deleted', false)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(res);
  }

  Future<String> uploadMedia({
    required File file,
    required String userId,
    required MediaType type,
  }) async {
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}.${file.path.split('.').last}';

    final path = '$userId/${type.name}/$fileName';

    await _supabase.storage.from('posts').upload(path, file);

    return _supabase.storage.from('posts').getPublicUrl(path);
  }
}

