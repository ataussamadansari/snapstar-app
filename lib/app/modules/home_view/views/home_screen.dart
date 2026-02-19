import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../global_widgets/post_card.dart';
import '../../../global_widgets/user_suggestion_card.dart';
import '../controllers/home_controller.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text("SnapStar", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.refreshAll(),
        child: Obx(() {
          if (controller.isLoadingPosts.value && controller.posts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // Total count calculate karein (Posts + Suggested Card)
          int postCount = controller.posts.length;
          bool showSuggestions = controller.users.isNotEmpty;

          // Agar suggestions dikhani hain toh list size 1 badha dein
          int totalItems = showSuggestions ? postCount + 1 : postCount;

          return ListView.builder(
            itemCount: totalItems,
            cacheExtent: 1000,
            addAutomaticKeepAlives: true,
            itemBuilder: (context, index) {
              // 🟢 SUGGESTED USERS POSITION LOGIC
              int suggestionIndex;
              if (postCount < 10) {
                suggestionIndex = 1; // 1st post ke baad (index 1 par)
              } else {
                suggestionIndex = 10; // Har 10 post ke baad (filhal ek baar dikhane ke liye)
              }

              // Agar suggestions ki bari hai
              if (showSuggestions && index == suggestionIndex) {
                return _buildSuggestedSection();
              }

              // Post ka index adjust karein agar suggestion beech mein aa gayi hai
              int actualPostIndex = (showSuggestions && index > suggestionIndex)
                  ? index - 1
                  : index;

              // Safe check taaki crash na ho
              if (actualPostIndex < controller.posts.length) {
                return PostCard(
                    post: controller.posts[actualPostIndex]
                );
              }

              return const SizedBox.shrink();
            },
          );
        }),
      ),
    );
  }

  // Horizontal Suggested Users Widget
  Widget _buildSuggestedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text("Suggested for you",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            itemCount: controller.users.length,
            itemBuilder: (context, index) {
              return UserSuggestionCard(
                user: controller.users[index],
                onProfileTap: () => Get.toNamed('/profile', arguments: controller.users[index].id),
              );
            },
          ),
        ),
      ],
    );
  }
}

