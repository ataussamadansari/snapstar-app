import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snapstar/app/data/models/post_model.dart';

import '../core/utils/number_formatter.dart';
import '../data/controllers/post_interaction_controller.dart';
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

  late final PostInteractionController _interactionController;

  @override
  void initState() {
    super.initState();

    /// 🔥 ONE CONTROLLER PER POST
    _interactionController = Get.put(
      PostInteractionController(),
      tag: widget.post.postId,
    );

    /// 🔥 INIT LIKE STATE
    _interactionController.init(widget.post);
  }

  @override
  void dispose() {
    _pageController.dispose();
    Get.delete<PostInteractionController>(tag: widget.post.postId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.post.user;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// 🟣 HEADER
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
              const Icon(Icons.more_vert, size: 20),
            ],
          ),
        ),

        /// 🟣 MEDIA
        AspectRatio(
          aspectRatio: 1,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.post.mediaUrls.length,
            onPageChanged: (i) {
              setState(() {
                _currentIndex = i;
              });
            },
            itemBuilder: (context, index) {
              final isVideo = widget.post.mediaType == MediaType.video;

              return Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    isVideo
                        ? widget.post.thumbnailUrls[index]
                        : widget.post.mediaUrls[index],
                    fit: BoxFit.cover,
                  ),
                  if (isVideo)
                    Center(
                      child: Icon(
                        Icons.play_circle_fill,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),

                  /// Multi-Image Indicator
                  if (widget.post.mediaUrls.length > 1)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "${_currentIndex + 1}/${widget.post.mediaUrls.length}",
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

        /// 🟣 ACTIONS
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Obx(
            () => Row(
              children: [
                /// ❤️ LIKE
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        _interactionController.isLiked.value
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: _interactionController.isLiked.value
                            ? Colors.red
                            : Theme.of(context).iconTheme.color,
                      ),
                      onPressed: _interactionController.toggleLike,
                    ),
                    Text(
                      NumberFormatter.format(
                        _interactionController.likeCount.value,
                      ),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 12),

                /// 💬 COMMENT
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.mode_comment_outlined),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.surface,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                          ),
                          builder: (_) => CommentSheet(
                            postId: widget.post.postId,
                            postOwnerId: widget.post.userId,
                          ),
                        );
                      },
                    ),
                    Text(
                      NumberFormatter.format(
                        _interactionController.commentCount.value,
                      ),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 12),

                /// ✈ SHARE
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.send_outlined),
                      onPressed: () {
                        // later: share logic
                      },
                    ),
                    Text(
                      widget.post.shareCount.toString(),
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                /// 🔖 SAVE / BOOKMARK
                IconButton(
                  icon: const Icon(Icons.bookmark_border),
                  onPressed: () {
                    // later: save logic
                  },
                ),
              ],
            ),
          ),
        ),

        /// 🟣 CONTENT
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  children: [
                    TextSpan(
                      text: "${user.username} ",
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    TextSpan(text: widget.post.caption),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatDate(widget.post.createdAt),
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}
