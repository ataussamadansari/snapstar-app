import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import '../core/utils/number_formatter.dart';
import '../data/controllers/post_interaction_controller.dart';
import '../data/models/post_model.dart';
import 'comment_sheet.dart';

class PostCard extends StatefulWidget {
  final PostModel post;

  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  VideoPlayerController? _videoController;
  late final PostInteractionController _interactionController;

  @override
  void initState() {
    super.initState();

    /// one controller per post
    _interactionController = Get.put(
      PostInteractionController(),
      tag: widget.post.postId,
    )..init(widget.post);

    if (widget.post.mediaType == MediaType.video) {
      _initVideo(0);
    }
  }

  Future<void> _initVideo(int index) async {
    _videoController?.dispose();

    _videoController = VideoPlayerController.networkUrl(
      Uri.parse(widget.post.mediaUrls[index]),
    );

    await _videoController!.initialize();
    _videoController!
      ..setLooping(true)
      ..play();

    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _pageController.dispose();
    Get.delete<PostInteractionController>(tag: widget.post.postId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final user = post.user;
    final isVideoPost = post.mediaType == MediaType.video;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// HEADER
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage(user.photoUrl),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  user.username,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              const Icon(Icons.more_vert),
            ],
          ),
        ),

        /// MEDIA
        AspectRatio(
          aspectRatio: 1,
          child: PageView.builder(
            controller: _pageController,
            itemCount: post.mediaUrls.length,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
              if (isVideoPost) _initVideo(index);
            },
            itemBuilder: (context, index) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  if (isVideoPost &&
                      _videoController != null &&
                      _videoController!.value.isInitialized &&
                      index == _currentIndex)
                    VideoPlayer(_videoController!)
                  else
                    Image.network(
                      isVideoPost
                          ? post.thumbnailUrls[index]
                          : post.mediaUrls[index],
                      fit: BoxFit.cover,
                    ),

                  if (post.mediaUrls.length > 1)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "${_currentIndex + 1}/${post.mediaUrls.length}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),

        /// ACTIONS
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Obx(
                () => Row(
              children: [
                _ActionItem(
                  icon: _interactionController.isLiked.value
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: _interactionController.isLiked.value
                      ? Colors.red
                      : null,
                  count: _interactionController.likeCount.value,
                  onTap: _interactionController.toggleLike,
                ),
                _ActionItem(
                  icon: Icons.mode_comment_outlined,
                  count: _interactionController.commentCount.value,
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor:
                      Theme.of(context).colorScheme.surface,
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      builder: (_) => CommentSheet(
                        postId: post.postId,
                        postOwnerId: post.userId,
                      ),
                    );
                  },
                ),
                _ActionItem(
                  icon: Icons.send_outlined,
                  count: post.shareCount,
                  onTap: () {},
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.bookmark_border),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),

        /// CAPTION
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: RichText(
            text: TextSpan(
              style:
              TextStyle(color: Theme.of(context).colorScheme.onSurface),
              children: [
                TextSpan(
                  text: "${user.username} ",
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                TextSpan(text: post.caption),
              ],
            ),
          ),
        ),

        /// DATE
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          child: Text(
            _formatDate(post.createdAt),
            style: TextStyle(
              fontSize: 11,
              color:
              Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ),

        const SizedBox(height: 12),
      ],
    );
  }

  String _formatDate(DateTime date) =>
      "${date.day}/${date.month}/${date.year}";
}

/// 🔥 REUSABLE ACTION WIDGET (NO DUPLICATION)
class _ActionItem extends StatelessWidget {
  final IconData icon;
  final int count;
  final VoidCallback onTap;
  final Color? color;

  const _ActionItem({
    required this.icon,
    required this.count,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: Icon(icon, color: color),
          onPressed: onTap,
        ),
        Text(
          NumberFormatter.format(count),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color:
            Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
