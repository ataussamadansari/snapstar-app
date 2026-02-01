import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/story_model.dart';
import '../../../globle_widgets/animated_bar.dart';

class StoryScreen extends StatefulWidget {
  final List<StoryModel> stories;
  final int initialIndex;

  const StoryScreen({super.key, required this.stories, this.initialIndex = 0});

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _animController = AnimationController(vsync: this);

    _loadStory(story: widget.stories[_currentIndex]);

    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animController.stop();
        _animController.reset();
        setState(() {
          if (_currentIndex + 1 < widget.stories.length) {
            _currentIndex++;
            _pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          } else {
            Get.back(); // Saari stories khatam, wapas jao
          }
        });
      }
    });
  }

  void _loadStory({required StoryModel story, bool animateToPage = true}) {
    _animController.stop();
    _animController.reset();
    _animController.duration = const Duration(seconds: 5); // 5 sec per story
    _animController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final story = widget.stories[_currentIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: (details) {
          final double screenWidth = MediaQuery.of(context).size.width;
          final double dx = details.globalPosition.dx;

          if (dx < screenWidth / 3) {
            // ⬅️ Left Tap: Previous Story
            if (_currentIndex - 1 >= 0) {
              setState(() {
                _currentIndex--;
              });
              _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut
              );
              _loadStory(story: widget.stories[_currentIndex]); // Reset animation for prev story
            }
          } else if (dx > 2 * screenWidth / 3) {
            // ➡️ Right Tap: Next Story
            // Animation ko manual "complete" state par bhej do
            _animController.forward(from: 1.0);
          }
        },
        child: Stack(
          children: [
            /// 📸 Media View
            PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.stories.length,
              itemBuilder: (context, index) {
                return Center(
                  child: Image.network(
                    widget.stories[index].mediaUrl,
                    fit: BoxFit.contain,
                    width: double.infinity,
                  ),
                );
              },
            ),

            /// 📊 Top Progress Bars
            Positioned(
              top: 50,
              left: 10,
              right: 10,
              child: Row(
                children: widget.stories.asMap().entries.map((e) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: AnimatedBar(
                        animController: _animController,
                        position: e.key,
                        currentIndex: _currentIndex,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            /// 👤 User Info Header
            Positioned(
              top: 70,
              left: 15,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundImage: NetworkImage(story.userImage),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    story.username,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            /// ❌ Close Button
            Positioned(
              top: 65,
              right: 15,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Get.back(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}