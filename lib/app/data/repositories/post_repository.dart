import '../../core/utils/selected_media.dart';
import '../models/post_model.dart';
import '../models/user_snapshot.dart';
import '../providers/post_provider.dart';
import 'user_repository.dart';

class PostRepository {
  final PostProvider provider = PostProvider();
  final UserRepository userRepository = UserRepository();

  Future<void> createPost({
    required String userId,
    required String caption,
    required List<SelectedMedia> mediaFiles,
  }) async {

    /// 1️⃣ USER SNAPSHOT (ONCE)
    final UserSnapshot? userSnapshot =
    await userRepository.getUserSnapShot(userId);

    if (userSnapshot == null) {
      throw Exception("User not found");
    }

    List<String> urls = [];
    List<String> thumbnails = [];

    /// 2️⃣ MEDIA UPLOAD
    for (var i = 0; i < mediaFiles.length; i++) {
      final path = 'posts/$userId/${DateTime.now().millisecondsSinceEpoch}_$i';
      final url = await provider.uploadFile(mediaFiles[i], path);
      urls.add(url);

      if (mediaFiles[i].isVideo && mediaFiles[i].thumbnail != null) {
        final thumb = SelectedMedia(
          file: mediaFiles[i].thumbnail!,
          isVideo: false,
        );

        final thumbUrl = await provider.uploadFile(
          thumb,
          'posts/$userId/thumb_${DateTime.now().millisecondsSinceEpoch}_$i',
        );
        thumbnails.add(thumbUrl);
      }
    }

    /// 3️⃣ POST OBJECT (WITH SNAPSHOT)
    final postId = DateTime.now().millisecondsSinceEpoch.toString();
    final isAnyVideo = mediaFiles.any((m) => m.isVideo);

    final post = PostModel(
      postId: postId,
      userId: userId,
      user: userSnapshot, // 🔥 MOST IMPORTANT
      caption: caption,
      mediaType: isAnyVideo ? MediaType.video : MediaType.image,
      mediaUrls: urls,
      thumbnailUrls: thumbnails,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    /// 4️⃣ SAVE
    await provider.savePost(post);
    await provider.incrementUserPostCount(userId);
  }

  Stream<List<PostModel>> getUserPosts(String uid) {
    return provider.getUserPosts(uid).map(
          (list) => list.map(PostModel.fromMap).toList(),
    );
  }
}