import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/post_model.dart';
import '../../follow_view/views/follow_list_screen.dart';
import '../controllers/profile_controller.dart';

class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Text(controller.userModel.value?.username ?? "Profile"),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              showCupertinoDialog(
                context: context,
                builder: (context) => CupertinoAlertDialog(
                  title: const Text("Logout"),
                  content: const Text("Are you sure you want to logout?"),
                  actions: [
                    CupertinoDialogAction(
                      isDestructiveAction: true, // Red color for dangerous actions
                      onPressed: () => Get.back(),
                      child: const Text("No"),
                    ),
                    CupertinoDialogAction(
                      onPressed: () {
                        Get.back(); // Dialog close karein
                        controller.logout(); // Logout process start karein
                      },
                      child: const Text("Yes"),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Obx(() {
        final user = controller.userModel.value;
        if (user == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            // Header: Image + Stats
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  GestureDetector(
                    // onTap: controller.updateProfileImage,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: NetworkImage(user.photoUrl),
                        ),
                        Positioned(
                          bottom: 2,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Obx(
                      () => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStat(user.postsCount.toString(), "Posts"),
                          _buildStat(
                            controller.followersCount.value.toString(),
                            "Followers",
                            onTap: () => Get.to(() => FollowListScreen(
                              title: "Followers",
                              uid: controller.userModel.value!.uid,
                              isFollowers: true,
                            )),
                          ),
                          _buildStat(
                            controller.followingCount.value.toString(),
                            "Following",
                            onTap: () => Get.to(() => FollowListScreen(
                              title: "Following",
                              uid: controller.userModel.value!.uid,
                              isFollowers: false,
                            )),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Edit & Share Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      child: const Text("Edit Profile"),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      child: const Text("Share Profile"),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Filter Tabs
            _buildFilterTabs(context),

            // Posts Grid
            Expanded(child: _buildGrid()),
          ],
        );
      }),
    );
  }

  Widget _buildFilterTabs(BuildContext context) {
    return Obx(
      () => Row(
        children: [
          _filterItem(context, Icons.grid_on, 0),
          _filterItem(context, Icons.image_outlined, 1),
          _filterItem(context, Icons.videocam_outlined, 2),
        ],
      ),
    );
  }

  Widget _filterItem(BuildContext context, IconData icon, int index) {
    bool isSelected = controller.selectedFilter.value == index;
    return Expanded(
      child: InkWell(
        onTap: () => controller.applyFilter(index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            // border: Border(bottom: BorderSide(color: isSelected ? Get.isDarkMode ? Colors.white: Colors.black : Colors.transparent, width: 2)),
            border: Border(
              bottom: BorderSide(
                width: 2,
                color: isSelected ? Colors.blue : Colors.transparent,
              ),
            ),
          ),
          // child: Icon(icon, color: isSelected ? Get.isDarkMode ? Colors.white: Colors.black : Colors.grey),
          child: Icon(icon, color: isSelected ? Theme.of(context).iconTheme.color : Colors.grey),
        ),
      ),
    );
  }

  Widget _buildGrid() {
    return GridView.builder(
      padding: const EdgeInsets.only(bottom: 80, left: 2, right: 2, top: 2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: controller.filteredPosts.length,
      itemBuilder: (context, index) {
        final post = controller.filteredPosts[index];
        final url = post.mediaType == MediaType.video
            ? post.thumbnailUrls.first
            : post.mediaUrls.first;

        return Stack(
          fit: StackFit.expand,
          children: [
            Image.network(url, fit: BoxFit.cover),
            if (post.mediaType == MediaType.video)
              const Positioned(
                right: 4,
                top: 4,
                child: Icon(
                  Icons.play_circle_fill,
                  color: Colors.white,
                  size: 20,
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildStat(String count, String label, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            count,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}
