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

