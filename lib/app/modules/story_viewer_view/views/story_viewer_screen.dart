import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snapstar_app/app/core/utils/date_time_extension.dart';

import '../controllers/story_viewer_controller.dart';


class StoryViewerScreen extends GetView<StoryViewerController> {
  const StoryViewerScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Obx(() {

          if (controller.userStories.isEmpty) {
            return const SizedBox();
          }

          final story =
          controller.userStories[controller.currentIndex.value];

          return GestureDetector(
            onTapUp: (details) {
              final width = MediaQuery.of(context).size.width;

              if (details.globalPosition.dx < width / 2) {
                controller.previousStory();
              } else {
                controller.nextStory();
              }
            },
            onLongPress: controller.pause,
            onLongPressUp: controller.resume,
            child: Stack(
              children: [

                /// MEDIA
                Center(
                  child: Image.network(
                    story.mediaUrls.first,
                    // fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),

                /// TOP BARS
                Positioned(
                  top: 10,
                  left: 10,
                  right: 10,
                  child: Row(
                    children: List.generate(
                      controller.userStories.length,
                          (index) {
                        return Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            height: 3,
                            child: LinearProgressIndicator(
                              value: index ==
                                  controller.currentIndex.value
                                  ? controller.progress.value
                                  : index <
                                  controller.currentIndex.value
                                  ? 1
                                  : 0,
                              backgroundColor:
                              Colors.white30,
                              valueColor:
                              const AlwaysStoppedAnimation(
                                  Colors.white),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                /// USER INFO
                Positioned(
                  top: 40,
                  left: 16,
                  right: 16,
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.grey.shade800,
                        backgroundImage:
                        (story.user?.avatarUrl != null &&
                            story.user!.avatarUrl!.isNotEmpty)
                            ? NetworkImage(story.user!.avatarUrl!)
                            : null,
                        child: (story.user?.avatarUrl == null ||
                            story.user!.avatarUrl!.isEmpty)
                            ? const Icon(Icons.person, color: Colors.white)
                            : null,
                      ),

                      const SizedBox(width: 10),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            story.user?.username ?? "",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          Text(
                            (story.createdAt).timeAgo,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Get.back(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}