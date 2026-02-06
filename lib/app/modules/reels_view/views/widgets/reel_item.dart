import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import '../../../../data/models/post_model.dart';
import '../../../../data/controllers/post_interaction_controller.dart';
import '../../../../core/utils/number_formatter.dart';
import '../../../../globle_widgets/comment_sheet.dart';

class ReelItem extends StatefulWidget {
  final PostModel post;
  final bool isActive;

  const ReelItem({
    super.key,
    required this.post,
    required this.isActive,
  });

  @override
  State<ReelItem> createState() => _ReelItemState();
}

class _ReelItemState extends State<ReelItem> {
  VideoPlayerController? _controller;
  bool _isMuted = true;
  bool _isInitialized = false;
  bool _isInitializing = false;

  late final PostInteractionController _interactionController;

  @override
  void initState() {
    super.initState();

    _interactionController = Get.put(
      PostInteractionController(),
      tag: widget.post.postId,
    )..init(widget.post);

    if (widget.isActive) _initVideo();
  }

  @override
  void didUpdateWidget(covariant ReelItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isActive && !_isInitialized) {
      _initVideo();
    } else if (!widget.isActive && _isInitialized) {
      _disposeVideo();
    }
  }

  Future<void> _initVideo() async {
    if (_isInitializing) return;
    _isInitializing = true;

    _controller = VideoPlayerController.network(
      widget.post.mediaUrls.first,
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );

    await _controller!.initialize();

    _controller!
      ..setLooping(true)
      ..setVolume(_isMuted ? 0 : 1)
      ..play();

    _isInitialized = true;
    _isInitializing = false;

    if (mounted) setState(() {});
  }

  void _disposeVideo() {
    _controller?.pause();
    _controller?.dispose();
    _controller = null;
    _isInitialized = false;
  }

  @override
  void dispose() {
    _disposeVideo();
    Get.delete<PostInteractionController>(tag: widget.post.postId);
    super.dispose();
  }

  void _togglePlayPause() {
    if (_controller == null) return;
    setState(() {
      _controller!.value.isPlaying
          ? _controller!.pause()
          : _controller!.play();
    });
  }

  void _toggleMute() {
    if (_controller == null) return;
    setState(() {
      _isMuted = !_isMuted;
      _controller!.setVolume(_isMuted ? 0 : 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        /// 🎬 VIDEO / LOADER
        GestureDetector(
          onTap: _togglePlayPause,
          child: _controller != null && _controller!.value.isInitialized
              ? FittedBox(
            fit: BoxFit.cover,
            child: Container(
              padding: EdgeInsets.only(bottom: 65),
              width: _controller!.value.size.width,
              height: _controller!.value.size.height,
              child: VideoPlayer(_controller!),
            ),
          )
              : Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                widget.post.thumbnailUrls.first,
                fit: BoxFit.cover,
              ),
              const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ],
          ),
        ),

        /// 🔊 MUTE
        Positioned(
          right: 16,
          top: 60,
          child: IconButton(
            icon: Icon(
              _isMuted ? Icons.volume_off : Icons.volume_up,
              color: Colors.white,
            ),
            onPressed: _toggleMute,
          ),
        ),

        /// ❤️ / 💬 ACTIONS
        Positioned(
          right: 12,
          bottom: 80,
          child: Obx(
                () => Column(
              children: [
                IconButton(
                  icon: Icon(
                    _interactionController.isLiked.value
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: _interactionController.isLiked.value
                        ? Colors.red
                        : Colors.white,
                  ),
                  onPressed: _interactionController.toggleLike,
                ),
                Text(
                  NumberFormatter.format(
                      _interactionController.likeCount.value),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 16),
                IconButton(
                  icon: const Icon(Icons.mode_comment_outlined,
                      color: Colors.white),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) => CommentSheet(
                        postId: widget.post.postId,
                        postOwnerId: widget.post.userId,
                      ),
                    );
                  },
                ),
                Text(
                  NumberFormatter.format(
                      _interactionController.commentCount.value),
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
