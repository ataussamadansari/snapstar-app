import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:snapstar/app/data/models/post_model.dart';
import 'package:snapstar/app/data/models/user_model.dart';
import 'package:snapstar/app/data/repositories/user_repository.dart';

class PostCard extends StatefulWidget {
  final PostModel post;

  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final PageController _pageController = PageController();
  final UserRepository _userRepo = UserRepository();

  UserModel? postUser;
  bool isUserLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPostUserData();
  }

  void _loadPostUserData() async {
    try {
      final user = await _userRepo.getUserDetailsById(widget.post.userId);
      if (mounted) {
        setState(() {
          postUser = user;
          isUserLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isUserLoading = false);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Header (Ab real data dikhayega)
        ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.grey.shade200,
            backgroundImage: postUser?.photoUrl != null
                ? NetworkImage(postUser!.photoUrl!)
                : null,
            child: postUser?.photoUrl == null
                ? const Icon(Icons.person, color: Colors.white)
                : null,
          ),
          title: Text(
            isUserLoading ? "Loading..." : (postUser?.username ?? "User"),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: widget.post.location != null
              ? Text(widget.post.location!, style: const TextStyle(fontSize: 12))
              : null,
          trailing: const Icon(Icons.more_vert),
        ),
        /// 2. Media Carousel (Images/Videos)
        _buildMediaSection(),

        /// 3. Actions & Indicators
        _buildActionRow(),

        /// 4. Likes & Caption
        _buildContentSection(),

        SizedBox(height: 12)
      ],
    );
  }

  Widget _buildMediaSection() {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1, // Square for consistent feed look
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                itemCount: widget.post.mediaUrls.length,
                itemBuilder: (context, index) {
                  bool isVideo = widget.post.mediaType == MediaType.video ||
                      (widget.post.mediaType == MediaType.mixed && index < widget.post.thumbnailUrls.length);

                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        isVideo ? widget.post.thumbnailUrls[index] : widget.post.mediaUrls[index],
                        fit: BoxFit.cover,
                      ),
                      if (isVideo)
                        const Center(
                          child: CircleAvatar(
                            backgroundColor: Colors.black45,
                            child: Icon(Icons.play_arrow, color: Colors.white, size: 30),
                          ),
                        ),
                    ],
                  );
                },
              ),
              // Indicator for multiple images (Top Right)
              if (widget.post.mediaUrls.length > 1)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "${widget.post.mediaUrls.length} files",
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.favorite_border, size: 28)),
              IconButton(onPressed: () {}, icon: const Icon(Icons.comment_outlined, size: 26)),
              IconButton(onPressed: () {}, icon: const Icon(Icons.send_outlined, size: 26)),
              const Spacer(),
              // Carousel Dots
              if (widget.post.mediaUrls.length > 1)
                SmoothPageIndicator(
                  controller: _pageController,
                  count: widget.post.mediaUrls.length,
                  effect: const ScrollingDotsEffect(
                    activeDotColor: Colors.deepPurple,
                    dotHeight: 6,
                    dotWidth: 6,
                  ),
                ),
              const Spacer(flex: 2),
              IconButton(onPressed: () {}, icon: const Icon(Icons.bookmark_border, size: 28)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContentSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("${widget.post.likeCount} likes", style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.black),
              children: [
                TextSpan(text: "user_${widget.post.userId.substring(0,4)} ", style: const TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: widget.post.caption),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "${widget.post.createdAt.day}/${widget.post.createdAt.month}/${widget.post.createdAt.year}",
            style: const TextStyle(color: Colors.grey, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
