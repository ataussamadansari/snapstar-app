import 'dart:io';

import '../models/post_model.dart';
import '../providers/post_provider.dart';
import '../services/post_service.dart';

class PostRepository {
  final PostProvider provider;
  final PostService service;

  PostRepository(this.provider, this.service);

  Future<void> createPost(PostModel post) async {
    await provider.createPost(post.toCreateJson());
  }

  Future<List<PostModel>> fetchFeedPosts() async {
    final raw = await provider.fetchAllPosts();
    return raw.map((e) => PostModel.fromJson(e)).toList();
  }

  Future<List<PostModel>> fetchUserPosts(
      String userId, {
        MediaType? type,
      }) async {
    final raw = await provider.fetchUserPosts(
      userId,
      mediaType: type?.name,
    );

    return raw.map((e) => PostModel.fromJson(e)).toList();
  }

  Future<List<PostModel>> fetchReels() async {
    final raw = await provider.fetchVideoPosts();
    return raw.map((e) => PostModel.fromJson(e)).toList();
  }

  Future<String> uploadMedia({
    required File file,
    required String userId,
    required MediaType type,
  }) {
    return provider.uploadMedia(
      file: file,
      userId: userId,
      type: type,
    );
  }

  /// 🔥 Realtime Wrapper
  void subscribeToFeed({
    required Function(PostModel) onInsert,
    required Function(PostModel) onUpdate,
    required Function(String id) onDelete,
  }) {
    service.subscribeToPosts(
      onInsert: (json) {
        onInsert(PostModel.fromJson(json));
      },
      onUpdate: (json) {
        onUpdate(PostModel.fromJson(json));
      },
      onDelete: (json) {
        onDelete(json['id']);
      },
    );
  }
}

