import 'package:flutter/material.dart';
import 'package:get/get.dart'; // 🟢 GetX add kiya
import 'package:cached_network_image/cached_network_image.dart';
import 'package:snapstar_app/app/core/utils/number_formatter.dart';
import 'package:snapstar_app/app/data/controllers/comment_controller.dart';
import '../data/controllers/like_controller.dart';
import '../data/models/post_model.dart';
import '../core/utils/date_time_extension.dart';
import 'auto_play_video.dart';
import 'comment_bottom_sheet.dart';

class PostCard extends StatefulWidget {
  final PostModel post;

  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool _showBigHeart = false;
  final LikeController _likeController = Get.find<LikeController>();
  final CommentController _commentController = Get.find<CommentController>();

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      _likeController.initializePost(
        widget.post.id, // ✅ updated
        widget.post.likeCount,
      );
      
      _commentController.initializePost(
        widget.post.id,
        widget.post.commentCount, // DB value
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryTextColor = theme.textTheme.bodyLarge?.color;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        /// 🔹 MEDIA SECTION
        GestureDetector(
          onDoubleTap: () {
            if (!_likeController.isLiked(widget.post.id)) {
              _likeController.toggleLike(widget.post.id);
            }
            setState(() => _showBigHeart = true);
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              _buildMedia(),

              if (_showBigHeart)
                TweenAnimationBuilder(
                  duration: const Duration(milliseconds: 500),
                  tween: Tween<double>(begin: 0, end: 1.2),
                  onEnd: () => setState(() => _showBigHeart = false),
                  builder: (context, double value, child) {
                    return Opacity(
                      opacity: value > 1.0 ? 2.0 - value : value,
                      child: Transform.scale(
                        scale: value,
                        child: const Icon(
                          Icons.favorite,
                          color: Colors.white,
                          size: 100,
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),

        /// 🔹 ACTIONS
        Row(
          children: [
            Obx(() => IconButton(
              onPressed: () =>
                  _likeController.toggleLike(widget.post.id),
              icon: Icon(
                _likeController.isLiked(widget.post.id)
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: _likeController.isLiked(widget.post.id)
                    ? Colors.red
                    : primaryTextColor,
              ),
            )),
            Obx(() => Text(
              NumberFormatter.format(_likeController.likeCount(widget.post.id)),
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16
              ),
            )),

            IconButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => CommentBottomSheet(
                    postId: widget.post.id,
                  ),
                );
              },
              icon: Icon(Icons.chat_bubble_outline,
                  color: primaryTextColor),
            ),
            Obx(() => Text(
              NumberFormatter.format(_commentController.commentCount(widget.post.id)),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16
              ),
            )),

            IconButton(
              onPressed: () {},
              icon: Icon(Icons.send_outlined,
                  color: primaryTextColor),
            ),

            const Spacer(),

            IconButton(
              onPressed: () {},
              icon: Icon(Icons.bookmark_border,
                  color: primaryTextColor),
            ),
          ],
        ),

        /// 🔹 LIKE COUNT + CAPTION
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: "@${widget.post.user!.username} ",
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: widget.post.caption,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 4),

              Text(
                widget.post.createdAt.timeAgo,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 15),
      ],
    );
  }

  /// 🔹 MEDIA BUILDER
  Widget _buildMedia() {
    if (widget.post.mediaUrls.isEmpty) {
      return const SizedBox();
    }

    if (widget.post.mediaType == MediaType.video) {
      return SizedBox(
        height: 400,
        width: double.infinity,
        child: AutoPlayVideo(
          videoUrl: widget.post.mediaUrls.first,
        ),
      );
    }

    // IMAGE (single image only now)
    return CachedNetworkImage(
      imageUrl: widget.post.mediaUrls.first,
      fit: BoxFit.cover,
      width: double.infinity,
      height: 400,
      placeholder: (context, url) =>
      const Center(child: CircularProgressIndicator()),
      errorWidget: (context, url, error) =>
      const Icon(Icons.broken_image),
    );
  }
}

