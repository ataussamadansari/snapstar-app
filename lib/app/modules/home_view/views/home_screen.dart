import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/story_model.dart' hide MediaType;
import '../../../data/models/user_model.dart';
import '../../../globle_widgets/post_card.dart';
import '../controllers/home_controller.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => CustomScrollView(
        slivers: [
          SliverAppBar(
            elevation: 0,
            scrolledUnderElevation: 0,
            title: const Row(
              children: [
                Icon(Icons.star, color: Colors.indigo),
                SizedBox(width: 4),
                Text("SnapStar", style: TextStyle(fontFamily: "Serif", fontWeight: FontWeight.bold)),
              ],
            ),
            floating: true,
            snap: true,
            // expandedHeight: 180,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(110),
              child: SizedBox(
                height: 110, // Fixed height provides constraints to ListView
                child: Obx(() => ListView.builder(
                  scrollDirection: Axis.horizontal,
                  // Scroll issues se bachne ke liye physics add karein
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  itemCount: controller.allStories.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _buildMyStoryCircle(controller.currentUser.value);
                    }
                    final story = controller.allStories[index - 1];
                    return _buildStoryCircle(story);
                  },
                )),
              ),
            ),
          ),

          /// 🔥 dynamic posts list
          SliverPadding(
            padding: const EdgeInsets.only(bottom: 80),
            sliver: controller.allPosts.isEmpty
                ? const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
                : SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                return PostCard(post: controller.allPosts[index]);
              }, childCount: controller.allPosts.length),
            ),
          ),
        ],
      )),
    );
  }

  Widget _buildMyStoryCircle(UserModel? user) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 38,
                backgroundColor: Colors.grey.shade300,
                backgroundImage: user?.photoUrl != null
                    ? NetworkImage(user!.photoUrl)
                    : null,
                child: user?.photoUrl == null
                    ? const Icon(Icons.person, color: Colors.white, size: 40)
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text("Your Story", style: TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildStoryCircle(StoryModel story) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          CircleAvatar(
            radius: 38,
            backgroundColor: Colors.indigo,
            child: CircleAvatar(
              radius: 35,
              backgroundImage: NetworkImage(story.userImage),
            ),
          ),
          const SizedBox(height: 4),
          Text(story.username, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }
}
