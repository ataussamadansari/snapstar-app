import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snapstar/app/modules/main_view/controllers/main_controller.dart';
import '../controllers/post_controller.dart';

class PostScreen extends GetView<PostController> {
  const PostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Get.find<MainController>().selectedIndex.value = 0,
        ),
        title: const Text(
          "New Post",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Obx(
            () => controller.isLoading.value
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(12.0),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : TextButton(
                    onPressed: controller.uploadPost,
                    child: const Text(
                      "Share",
                      style: TextStyle(
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Profile Header (Simple)
            Obx(() {
              final user = controller.currentUser.value;

              // UserModel mein 'photoUrl' hai
              final String imagePath = user?.photoUrl ?? "";

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.grey[200],
                  backgroundImage: imagePath.isNotEmpty
                      ? NetworkImage(imagePath)
                      : null,
                  child: imagePath.isEmpty
                      ? const Icon(Icons.person, color: Colors.grey)
                      : null,
                ),
                title: Text(
                  user?.name ?? "Loading...",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  user?.username != null ? "@${user!.username}" : "",
                ),
              );
            }),

            // Caption Field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: controller.captionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: "Life has been good to me, I can't take it with...",
                  border: InputBorder.none,
                ),
              ),
            ),

            SizedBox(height: 10,),
            Obx(
              () => controller.selectedMedia.isEmpty
                  ? const SizedBox.shrink()
                  : SizedBox(
                      height: 150,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: controller.selectedMedia.length,
                        // PostScreen inside ListView.builder
                        itemBuilder: (context, index) {
                          final media = controller.selectedMedia[index]; // SelectedMedia model

                          return Stack(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(right: 12),
                                width: 120,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.black12, // Placeholder color
                                    image: DecorationImage(
                                      image: (media.isVideo && media.thumbnail != null)
                                          ? FileImage(media.thumbnail!) as ImageProvider // Video ka thumbnail
                                          : FileImage(media.file), // Normal image
                                      fit: BoxFit.cover,
                                    ),
                                ),
                                // Video ke liye play icon dikha dein
                                child: media.isVideo
                                    ? const Center(
                                  child: Icon(Icons.play_circle_fill, color: Colors.white, size: 40),
                                )
                                    : null,
                              ),
                              Positioned(
                                right: 15,
                                top: 5,
                                child: GestureDetector(
                                  onTap: () => controller.removeMedia(index),
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
            ),

            const Divider(height: 32),

            // Action List (Audience, Mention, Location)
            // _buildActionItem(Icons.people_outline, "Audience", "Everyone"),
            // _buildActionItem(Icons.alternate_email, "Mention", ""),
            // _buildActionItem(Icons.location_on_outlined, "Add Location", "", isTextField: true,),

            const SizedBox(height: 20),

            // Floating Pick Media Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: OutlinedButton.icon(
                onPressed: controller.pickMedia,
                icon: const Icon(Icons.add_photo_alternate_outlined),
                label: const Text("Add More Media (Max 10)"),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem(
    IconData icon,
    String title,
    String trailing, {
    bool isTextField = false,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[700]),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(trailing, style: const TextStyle(color: Colors.grey)),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}
