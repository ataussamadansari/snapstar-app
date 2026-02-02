import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/controllers/follow_controller.dart';
import '../../../globle_widgets/follow_button.dart';
import '../controllers/follow_list_controller.dart';

class FollowListScreen extends StatelessWidget {
  final String title;
  final String uid;
  final bool isFollowers;

  const FollowListScreen({
    super.key,
    required this.title,
    required this.uid,
    required this.isFollowers,
  });

  @override
  Widget build(BuildContext context) {
    // Controller initialize and fetch data immediately
    final controller = Get.put(FollowListController());
    controller.fetchUsers(uid, isFollowers);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Obx(() {
        if (controller.isScLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView.builder(
          itemCount: controller.followUsers.length,
          itemBuilder: (context, index) {
            final user = controller.followUsers[index];

            return Obx(() {
              final state = controller.followStates[user.uid] ?? FollowState.follow;
              final isLoading = controller.loading[user.uid] ?? false;

              return ListTile(
                leading: CircleAvatar(backgroundImage: NetworkImage(user.photoUrl)),
                title: Text(user.name),
                subtitle: Text("@${user.username}"),
                trailing: FollowButton(
                  state: state,
                  isLoading: isLoading,
                  onTap: () => controller.toggleFollow(user),
                ),
              );
            });
          },
        );
      }),
    );
  }
}

/*
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snapstar/app/core/constants/firebase_constants.dart';
import 'package:snapstar/app/data/models/user_model.dart';

import '../../../data/controllers/follow_controller.dart';
import '../../../data/repositories/follow_repository.dart';
import '../controllers/follow_list_controller.dart';

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
    final followController = Get.find<FollowController>();

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

            return Obx(() {
              final state = controller.followStates[user.uid]
                  ?? FollowState.follow;

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 4),
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
              );
            }
            );
          },
        );
      }),
    );
  }

  Widget buildFollowButton({
    required FollowState state,
    required VoidCallback onFollow,
    required VoidCallback onUnfollow,
  }) {
    switch (state) {
      case FollowState.following:
        return OutlinedButton(
          onPressed: onUnfollow,
          child: const Text("Following"),
        );

      case FollowState.requested:
        return OutlinedButton(
          onPressed: null,
          child: const Text("Requested"),
        );

      case FollowState.follow:
        return ElevatedButton(
          onPressed: onFollow,
          child: const Text("Follow"),
        );

      default:
        return const SizedBox.shrink();
    }
  }

}*/
