import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/follow_controller.dart';

class FollowListScreen extends StatelessWidget {
  final String title;
  final String uid;
  final bool isFollowers;

  const FollowListScreen({
    super.key,
    required this.title,
    required this.uid,
    required this.isFollowers
  });

  @override
  Widget build(BuildContext context) {
    // Controller ko initialize karke data fetch start karein
    final controller = Get.put(FollowListController());
    controller.fetchUsers(uid, isFollowers);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        elevation: 0,
      ),
      body: Obx(() {
        // Loading state handle karein
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // Empty state handle karein
        if (controller.followUsers.isEmpty) {
          return Center(
            child: Text(
              "No ${title.toLowerCase()} found",
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
          );
        }

        return ListView.builder(
          itemCount: controller.followUsers.length,
          itemBuilder: (context, index) {
            // Ab hum FollowUserModel ka data use kar rahe hain
            final user = controller.followUsers[index];

            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              leading: CircleAvatar(
                radius: 24,
                backgroundImage: NetworkImage(user.photoUrl), //
              ),
              title: Text(
                user.name, //
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                "@${user.username}", //
                style: TextStyle(color: Colors.grey.shade600),
              ),
              /*trailing: ElevatedButton(
                onPressed: () {
                  // TODO: Navigate to this user's profile
                  // Get.toNamed(Routes.otherProfile, arguments: user.uid);
                },
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text("View"),
              ),*/
            );
          },
        );
      }),
    );
  }
}