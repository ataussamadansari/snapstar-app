import 'dart:io';

import '../models/post_model.dart';
import '../providers/post_provider.dart';

class PostRepository {
  final PostProvider provider;

  PostRepository(this.provider);

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
}

