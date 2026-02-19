import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../data/controllers/like_controller.dart';
import '../data/controllers/comment_controller.dart';
import '../data/models/post_model.dart';
import '../core/utils/date_time_extension.dart';
import '../core/utils/number_formatter.dart';
import 'auto_play_video.dart';
import 'comment_bottom_sheet.dart';

class PostCard extends StatefulWidget {
  final PostModel post;

  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final LikeController _likeController = Get.find();
  final CommentController _commentController = Get.find();

  bool _showBigHeart = false;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      _likeController.initializePost(
        widget.post.id,
        widget.post.likeCount,
      );

      _commentController.initializePost(
        widget.post.id,
        widget.post.commentCount,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.5;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: SizedBox(
          height: height,
          child: Stack(
            children: [

              /// MEDIA
              Positioned.fill(child: _buildMedia()),

              /// GRADIENT OVERLAY
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black38,
                        Colors.transparent,
                        Colors.black54,
                      ],
                    ),
                  ),
                ),
              ),

              /// RIGHT ACTIONS
              Positioned(
                right: 0,
                bottom: height/4,
                child: _buildRightActions(),
              ),

              /// BOTTOM GLASS USER INFO
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _buildGlassCaption(),
              ),

              /// DOUBLE TAP HEART
              if (_showBigHeart)
                Center(
                  child: TweenAnimationBuilder(
                    duration: const Duration(milliseconds: 500),
                    tween: Tween<double>(begin: 0, end: 1.2),
                    onEnd: () => setState(() => _showBigHeart = false),
                    builder: (_, double value, __) {
                      return Opacity(
                        opacity: value > 1 ? 2 - value : value,
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
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= MEDIA =================

  Widget _buildMedia() {
    if (widget.post.mediaUrls.isEmpty) return const SizedBox();

    if (widget.post.mediaType == MediaType.video) {
      return GestureDetector(
        onDoubleTap: _handleLike,
        child: AutoPlayVideo(
          videoUrl: widget.post.mediaUrls.first,
        ),
      );
    }

    return GestureDetector(
      onDoubleTap: _handleLike,
      child: CachedNetworkImage(
        imageUrl: widget.post.mediaUrls.first,
        fit: BoxFit.cover,
      ),
    );
  }

  void _handleLike() {
    if (!_likeController.isLiked(widget.post.id)) {
      _likeController.toggleLike(widget.post.id);
    }
    setState(() => _showBigHeart = true);
  }

  // ================= RIGHT ACTIONS =================

  Widget _buildRightActions() {
    return Container(
      padding: EdgeInsets.all(8.0),
     decoration: BoxDecoration(
       color: Colors.white.withValues(alpha: 0.06),
         border: Border.fromBorderSide(BorderSide(color: Colors.white.withValues(alpha: 0.1))),
       borderRadius: BorderRadius.only(topLeft: Radius.circular(12.0), bottomLeft: Radius.circular(12.0))
     ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          /// LIKE
          Obx(() => _glassAction(
            icon: _likeController.isLiked(widget.post.id)
                ? Icons.favorite
                : Icons.favorite_border,
            count: NumberFormatter.format(
              _likeController.likeCount(widget.post.id),
            ),
            color: _likeController.isLiked(widget.post.id)
                ? Colors.red
                : Colors.white,
            onTap: () => _likeController.toggleLike(widget.post.id),
          )),

          const SizedBox(height: 18),

          /// COMMENT
          Obx(() => _glassAction(
            icon: Icons.chat_bubble_outline,
            count: NumberFormatter.format(
              _commentController.commentCount(widget.post.id),
            ),
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) =>
                    CommentBottomSheet(postId: widget.post.id),
              );
            },
          )),

          const SizedBox(height: 18),

          /// SHARE
          _glassAction(
            icon: Icons.send_outlined,
            count: NumberFormatter.format(widget.post.shareCount),
          ),
        ],
      ),
    );
  }

  Widget _glassAction({
    required IconData icon,
    required String count,
    Color color = Colors.white,
    VoidCallback? onTap,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 4),
        Text(
          count,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // ================= GLASS CAPTION =================

  Widget _buildGlassCaption() {
    final user = widget.post.user;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Row(
            children: [

              /// AVATAR
              CircleAvatar(
                radius: 20,
                backgroundImage: (user?.avatarUrl != null &&
                    user!.avatarUrl!.isNotEmpty)
                    ? NetworkImage(user.avatarUrl!)
                    : null,
                child: (user?.avatarUrl == null ||
                    user!.avatarUrl!.isEmpty)
                    ? const Icon(Icons.person, size: 32)
                    : null,
              ),

              const SizedBox(width: 12),

              /// TEXT
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.name.capitalizeFirst ?? "",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "@${user?.username} •${widget.post.createdAt.timeAgo}",
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11
                      ),
                    ),
                    if (widget.post.caption.trim().isNotEmpty)
                      RichText(
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                          children: _buildCaptionSpans(widget.post.caption),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<TextSpan> _buildCaptionSpans(String caption) {
    final words = caption.split(" ");

    return words.map((word) {
      if (word.startsWith("#")) {
        return TextSpan(
          text: "$word ",
          style: const TextStyle(
            color: Colors.lightBlueAccent,
            fontWeight: FontWeight.w600,
          ),
        );
      } else if (word.startsWith("@")) {
        return TextSpan(
          text: "$word ",
          style: const TextStyle(
            color: Colors.purpleAccent,
            fontWeight: FontWeight.w600,
          ),
        );
      } else {
        return TextSpan(text: "$word ");
      }
    }).toList();
  }

}
