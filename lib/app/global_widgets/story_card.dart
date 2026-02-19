import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../data/controllers/story_controller.dart';
import '../modules/home_view/controllers/home_controller.dart';

class StoryCard extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final bool isYourStory;
  final bool hasUnseen;
  final VoidCallback? onTap;

  const StoryCard({
    super.key,
    required this.name,
    this.imageUrl,
    this.isYourStory = false,
    this.hasUnseen = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;

    return GestureDetector(
      onTap: () {
        if (isYourStory) {
          _showStoryOptions(context);
        } else {
          onTap?.call();
        }
      },
      child: SizedBox(
        width: 85,
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: hasUnseen
                        ? const LinearGradient(
                            colors: [Colors.pink, Colors.orange],
                          )
                        : null,
                  ),
                  child: CircleAvatar(
                    radius: 35,
                    backgroundColor: isDark
                        ? Colors.grey.shade800
                        : Colors.grey.shade200,
                    backgroundImage: imageUrl != null
                        ? NetworkImage(imageUrl!)
                        : null,
                    child: imageUrl == null
                        ? Icon(
                            Icons.person,
                            color: isDark ? Colors.white70 : Colors.black54,
                          )
                        : null,
                  ),
                ),

                /// ➕ PLUS ICON
                if (isYourStory)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark ? Colors.white : Colors.black,
                        border: Border.all(
                          color: isDark ? Colors.black : Colors.white,
                          width: 2,
                        ),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.add,
                        size: 16,
                        color: isDark ? Colors.black : Colors.white,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 6),

            Text(
              isYourStory ? "Your Story" : name,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: textColor),
            ),
          ],
        ),
      ),
    );
  }

  // ================= BOTTOM SHEET =================

  void _showStoryOptions(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ImagePicker _picker = ImagePicker();

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Create Story",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),

              const SizedBox(height: 20),

              _optionTile(
                context,
                icon: Icons.camera_alt,
                title: "Camera",
                onTap: () async {
                  Navigator.pop(context);

                  final XFile? file = await _picker.pickImage(
                    source: ImageSource.camera,
                  );

                  if (file != null) {
                    _handleStoryFile(context, file, isVideo: false);
                  }
                },
              ),

              _optionTile(
                context,
                icon: Icons.photo,
                title: "Images",
                onTap: () async {
                  Navigator.pop(context);

                  final XFile? file = await _picker.pickImage(
                    source: ImageSource.gallery,
                  );

                  if (file != null) {
                    _handleStoryFile(context, file, isVideo: false);
                  }
                },
              ),

              _optionTile(
                context,
                icon: Icons.videocam,
                title: "Videos",
                onTap: () async {
                  Navigator.pop(context);

                  final XFile? file = await _picker.pickVideo(
                    source: ImageSource.gallery,
                  );

                  if (file != null) {
                    _handleStoryFile(context, file, isVideo: true);
                  }
                },
              ),

              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  void _handleStoryFile(
      BuildContext context,
      XFile file, {
        required bool isVideo,
      }) async {

    final storyController = Get.find<StoryController>();
    final homeController = Get.find<HomeController>();

    await storyController.postStory(
      file: File(file.path),
      isVideo: isVideo,
      users: homeController.users,
    );
  }


  Widget _optionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        child: Icon(icon, color: isDark ? Colors.white : Colors.black),
      ),
      title: Text(
        title,
        style: TextStyle(color: isDark ? Colors.white : Colors.black),
      ),
      onTap: onTap,
    );
  }
}
