import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../core/utils/video_cache_manager.dart';

class AutoPlayVideo extends StatefulWidget {
  final String videoUrl;
  final String videoId;
  final bool isMuted;

  const AutoPlayVideo({
    super.key,
    required this.videoUrl,
    required this.videoId,
    required this.isMuted,
  });

  @override
  State<AutoPlayVideo> createState() => _AutoPlayVideoState();
}

class _AutoPlayVideoState extends State<AutoPlayVideo>
    with AutomaticKeepAliveClientMixin {

  VideoPlayerController? _controller;
  bool _isInitialized = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final fileInfo =
    await VideoCacheManager.instance.getFileFromCache(widget.videoUrl);

    if (fileInfo != null) {
      _controller = VideoPlayerController.file(fileInfo.file);
    } else {
      _controller =
          VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
      VideoCacheManager.instance.downloadFile(widget.videoUrl);
    }

    await _controller!.initialize();
    _controller!.setVolume(widget.isMuted ? 0 : 1);

    setState(() => _isInitialized = true);
  }

  @override
  void didUpdateWidget(covariant AutoPlayVideo oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller?.setVolume(widget.isMuted ? 0 : 1);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return VisibilityDetector(
      key: Key(widget.videoId),
      onVisibilityChanged: (info) {
        if (!_isInitialized) return;

        if (info.visibleFraction > 0.8) {
          _controller?.play();
        } else if (info.visibleFraction < 0.2) {
          _controller?.pause();
        }
      },
      child: _isInitialized
          ? Center(
            child: AspectRatio(
                    aspectRatio: _controller!.value.aspectRatio,
                    child: VideoPlayer(_controller!),
                  ),
          )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}


/*class AutoPlayVideo extends StatefulWidget {
  final String videoUrl;
  const AutoPlayVideo({super.key, required this.videoUrl});

  @override
  State<AutoPlayVideo> createState() => _AutoPlayVideoState();
}

class _AutoPlayVideoState extends State<AutoPlayVideo> with AutomaticKeepAliveClientMixin {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _showReplayBtn = false;
  static bool _globalMuted = true;

  @override
  bool get wantKeepAlive => true; // State ko destroy nahi hone dega

  @override
  void initState() {
    super.initState();
    _initializeWithCache();
  }

  // 🟢 Step 1: Cache se file uthao ya download karo
  Future<void> _initializeWithCache() async {
    try {
      final fileInfo = await VideoCacheManager.instance.getFileFromCache(widget.videoUrl);

      if (fileInfo != null) {
        // Cache mein file mil gayi (Instant Play)
        _controller = VideoPlayerController.file(fileInfo.file);
      } else {
        // Cache mein nahi hai, Network se chalao aur sath mein download karo
        _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
        VideoCacheManager.instance.downloadFile(widget.videoUrl); // Background download
      }

      await _controller!.initialize();
      _controller!.setVolume(_globalMuted ? 0 : 1);
      _controller!.setLooping(false); // Khatam hone par replay btn dikhana hai

      if (mounted) {
        setState(() => _isInitialized = true);
        _controller!.addListener(_videoListener);
      }
    } catch (e) {
      debugPrint("Streaming Error: $e");
    }
  }

  void _videoListener() {
    if (!mounted || _controller == null) return;
    if (_controller!.value.position >= _controller!.value.duration && _isInitialized) {
      if (!_showReplayBtn) setState(() => _showReplayBtn = true);
    }
  }

  @override
  void dispose() {
    _controller?.removeListener(_videoListener);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Mixin ke liye zaruri hai

    return VisibilityDetector(
      key: Key(widget.videoUrl),
      onVisibilityChanged: (info) {
        if (!mounted || !_isInitialized || _controller == null) return;

        if (info.visibleFraction > 0.8) {
          if (!_controller!.value.isPlaying) {
            _controller!.play();
            if (_showReplayBtn) setState(() => _showReplayBtn = false);
          }
        } else if (info.visibleFraction < 0.2) {
          if (_controller!.value.isPlaying) {
            _controller!.pause();
          }
        }
      },
      child: GestureDetector(
        onTap: () {
          setState(() {
            _globalMuted = !_globalMuted;
            _controller?.setVolume(_globalMuted ? 0 : 1);
          });
        },
        child: Container(
          height: 400,
          width: double.infinity,
          color: Colors.black,
          child: _isInitialized && _controller != null
              ? Stack(
            alignment: Alignment.center,
            children: [
              AspectRatio(
                aspectRatio: _controller!.value.aspectRatio,
                child: VideoPlayer(_controller!),
              ),
              // Mute Icon
              Positioned(
                top: 15, right: 15,
                child: CircleAvatar(
                  backgroundColor: Colors.black45,
                  radius: 15,
                  child: Icon(_globalMuted ? Icons.volume_off : Icons.volume_up,
                      color: Colors.white, size: 16),
                ),
              ),
              // Replay Button
              if (_showReplayBtn)
                CircleAvatar(
                  backgroundColor: Colors.black54,
                  radius: 30,
                  child: IconButton(
                    icon: const Icon(Icons.replay, color: Colors.white, size: 30),
                    onPressed: () {
                      _controller!.seekTo(Duration.zero);
                      _controller!.play();
                      setState(() => _showReplayBtn = false);
                    },
                  ),
                ),
            ],
          )
              : const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
      ),
    );
  }
}*/

/*
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

// auto_play_video.dart

class AutoPlayVideo extends StatefulWidget {
  final String videoUrl;
  const AutoPlayVideo({super.key, required this.videoUrl});

  @override
  State<AutoPlayVideo> createState() => _AutoPlayVideoState();
}

// 🟢 Step 1: Add AutomaticKeepAliveClientMixin
class _AutoPlayVideoState extends State<AutoPlayVideo> with AutomaticKeepAliveClientMixin {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _showReplayBtn = false;
  static bool _globalMuted = true; // 🟢 Saare videos ka mute status sync rakhega

  @override
  bool get wantKeepAlive => true; // 🟢 Step 2: Keep the state alive

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  Future<void> _initializeController() async {
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    try {
      // 🟢 Instagram style streaming speed ke liye
      await _controller.initialize();
      _controller.setVolume(_globalMuted ? 0 : 1);

      if (mounted) {
        setState(() => _isInitialized = true);
        _controller.addListener(_videoListener);
      }
    } catch (e) {
      debugPrint("Video Init Error: $e");
    }
  }

  void _videoListener() {
    if (!mounted) return;
    if (_controller.value.position >= _controller.value.duration && _isInitialized) {
      if (!_showReplayBtn) setState(() => _showReplayBtn = true);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_videoListener);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // 🟢 Step 3: Required for Mixin

    if (!_isInitialized) {
      return Container(
        height: 400,
        color: Colors.black12,
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    return VisibilityDetector(
      key: Key(widget.videoUrl),
      onVisibilityChanged: (info) {
        if (!mounted || !_isInitialized) return;

        // 🟢 Logic: Agar 80% dikh rahi hai toh play
        if (info.visibleFraction > 0.8) {
          if (!_controller.value.isPlaying) {
            _controller.play();
            setState(() => _showReplayBtn = false);
          }
        }
        // 🟢 Logic: Agar 20% se kam dikhe toh sirf Pause (Dispose nahi)
        // Isse wapas aane par loading nahi hogi, turant resume hoga
        else if (info.visibleFraction < 0.2) {
          if (_controller.value.isPlaying) {
            _controller.pause();
          }
        }
      },
      child: GestureDetector(
        onTap: () {
          setState(() {
            _globalMuted = !_globalMuted;
            _controller.setVolume(_globalMuted ? 0 : 1);
          });
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            ),
            // Mute/Unmute Indicator
            Positioned(
              bottom: 15,
              right: 15,
              child: CircleAvatar(
                backgroundColor: Colors.black45,
                radius: 15,
                child: Icon(_globalMuted ? Icons.volume_off : Icons.volume_up,
                    color: Colors.white, size: 18),
              ),
            ),
            // Replay Overlay
            if (_showReplayBtn)
              Container(
                color: Colors.black26,
                child: IconButton(
                  icon: const Icon(Icons.replay, color: Colors.white, size: 40),
                  onPressed: () {
                    _controller.seekTo(Duration.zero);
                    _controller.play();
                    setState(() => _showReplayBtn = false);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
*/
