import 'package:snapstar/app/core/utils/selected_media.dart';
import '../models/post_model.dart';
import '../providers/post_provider.dart';

class PostRepository {
  final PostProvider provider = PostProvider();

  Future<void> createPost({
    required String userId,
    required String caption,
    required List<SelectedMedia> mediaFiles,
  }) async {
    List<String> urls = [];
    List<String> thumbnails = []; // You'd populate this for videos

    // Upload files loop
    for (var i = 0; i < mediaFiles.length; i++) {
      String path = 'posts/$userId/${DateTime.now().millisecondsSinceEpoch}_$i';
      String url = await provider.uploadFile(mediaFiles[i], path);
      urls.add(url);

      // Thumbnail Upload (if video)
      if (mediaFiles[i].isVideo && mediaFiles[i].thumbnail != null) {
        SelectedMedia thumbObj = SelectedMedia(
            file: mediaFiles[i].thumbnail!,
            isVideo: false
        );
        String thumbUrl = await provider.uploadFile(thumbObj, 'posts/$userId/thumb_${DateTime.timestamp()}_$i');
        thumbnails.add(thumbUrl);
      }
    }

    final postId = DateTime.now().millisecondsSinceEpoch.toString();

    // ✅ FIXED LINE: 'f.path' ki jagah 'f.isVideo' use karein
    final isAnyVideo = mediaFiles.any((f) => f.isVideo);

    final post = PostModel(
      postId: postId,
      userId: userId,
      caption: caption,
      mediaType: isAnyVideo ? MediaType.video : MediaType.image,
      mediaUrls: urls,
      thumbnailUrls: thumbnails,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await provider.savePost(post);
    await provider.incrementUserPostCount(userId);
  }

  Future<List<PostModel>> getUserPosts(String uid) async {
    try {
      final List<Map<String, dynamic>> data = await provider.getUserPostsRaw(uid);
      return data.map((map) => PostModel.fromMap(map)).toList();
    } catch (e) {
      return [];
    }
  }
}