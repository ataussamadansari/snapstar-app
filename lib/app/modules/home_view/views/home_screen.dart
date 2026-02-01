import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/story_model.dart' hide MediaType;
import '../../../data/models/user_model.dart';
import '../../../globle_widgets/post_card.dart';
import '../../../globle_widgets/suggestion_card.dart';
import '../../story_view/views/story_screen.dart';
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


          SliverPadding(
            padding: EdgeInsets.only(bottom: 80),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  // 1. Suggestions kab dikhani hain?
                  // Agar posts 10 se kam hain toh index 1 par, warna har 10th post par.
                  bool isSuggestionPos = (controller.posts.length < 10)
                      ? (index == 1)
                      : (index != 0 && index % 11 == 0);

                  if (isSuggestionPos && controller.suggestions.isNotEmpty) {
                    return _buildSuggestions(controller);
                  }

                  // 2. Post ka index calculate karein
                  // Kitne suggestion cards ab tak aa chuke hain?
                  int offset = (controller.posts.length < 10)
                      ? (index > 1 ? 1 : 0)
                      : (index / 11).floor();

                  final postIndex = index - offset;

                  // 3. Safety Check
                  if (postIndex >= 0 && postIndex < controller.posts.length) {
                    return PostCard(post: controller.posts[postIndex]);
                  }

                  return null;
                },
                // Child count ko dynamic rakhein
                childCount: controller.posts.length + (controller.suggestions.isNotEmpty ? (controller.posts.length < 10 ? 1 : (controller.posts.length / 10).floor()) : 0),
              ),
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
                child: GestureDetector(
                  onTap: () => controller.pickAndUploadStory(), // 🔥 Click par upload
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 18),
                  ),
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
      child: InkWell(
        onTap: () {
          Get.to(() => StoryScreen(
            stories: controller.allStories,
            initialIndex: controller.allStories.indexOf(story),
          ));
        },
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
      ),
    );
  }

  Widget _buildSuggestions(HomeController controller) {
    return Obx(() {
      if (controller.suggestions.isEmpty) {
        // SliverList ke andar hum partial slivers return nahi kar sakte
        return const SizedBox.shrink();
      }

      // 🔥 FIX: SliverToBoxAdapter ko hata kar normal Column use karein
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Alignment fix
              children: [
                const Text(
                  "Suggested for you",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text("See More"),
                )
              ],
            ),
          ),
          SizedBox(
            height: 150, // Height thodi badha di hai taaki cards cut na hon
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: controller.suggestions.length,
              itemBuilder: (context, index) {
                final user = controller.suggestions[index];
                return SuggestionCard(user: user);
              },
            ),
          ),
        ],
      );
    });
  }

}
