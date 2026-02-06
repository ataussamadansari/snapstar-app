import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get_thumbnail_video/index.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:snapstar/app/core/constants/firebase_constants.dart';
import 'package:snapstar/app/core/utils/selected_media.dart';
import 'package:snapstar/app/data/models/user_model.dart';
import 'package:snapstar/app/data/repositories/post_repository.dart';
import 'package:snapstar/app/data/repositories/user_repository.dart';

import '../../main_view/controllers/main_controller.dart';

class PostController extends GetxController {
  final PostRepository _repository = PostRepository();
  final UserRepository _userRepository = UserRepository();

  var currentUser = Rxn<UserModel?>();

  final RxList<SelectedMedia> selectedMedia = <SelectedMedia>[].obs;

  // final RxList<File> selectedMedia = <File>[].obs;
  final captionController = TextEditingController();
  final locationController = TextEditingController();
  final isLoading = false.obs;

  @override
  void onReady() {
    super.onReady();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      // Check karein ki user authenticated hai ya nahi
      final user = await _userRepository.getCurrentUserDetails();
      if (user != null) {
        currentUser.value = user;
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  void removeMedia(int index) {
    selectedMedia.removeAt(index);
  }

  Future<void> pickMedia() async {
    final picker = ImagePicker();
    final List<XFile> picked = await picker.pickMultipleMedia();

    if (picked.isNotEmpty) {
      for (var xFile in picked) {
        if (selectedMedia.length >= 10) break;

        // Extension check
        bool isVid =
            xFile.path.toLowerCase().endsWith('.mp4') ||
            xFile.path.toLowerCase().endsWith('.mov');

        File? thumbFile;
        if (isVid) {
          final uint8list = await VideoThumbnail.thumbnailData(
            video: xFile.path,
            imageFormat: ImageFormat.JPEG,
            maxHeight: 200,
            quality: 50,
          );

          if(uint8list != null) {
            final tempDir = await getTemporaryDirectory();
            thumbFile = await File('${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg').create();
            await thumbFile.writeAsBytes(uint8list);
          }
        }
        selectedMedia.add(
          SelectedMedia(
              file: File(xFile.path),
              isVideo: isVid,
              thumbnail: thumbFile),
        );
      }
    }
  }

  // 1. Fields reset karne ka function
  void clearFields() {
    selectedMedia.clear();
    captionController.clear();
    locationController.clear();
    isLoading.value = false;
  }

  Future<void> uploadPost() async {
    if (selectedMedia.isEmpty) {
      Get.snackbar("Error", "Please select some media first");
      return;
    }

    isLoading.value = true;
    try {
      // Assuming you have access to current user ID via an AuthController
      final String uid = firebaseAuth.currentUser!.uid;
      await _repository.createPost(
        userId: uid,
        caption: captionController.text,
        mediaFiles: selectedMedia,
      );
      // 2. Data saaf karein
      clearFields();

      // 3. Agar PostScreen MainScreen ke andar as a Tab hai:
      final mainController = Get.find<MainController>();
      mainController.selectedIndex.value = 0; // Home Tab par switch karein

      Get.snackbar("Success", "Post uploaded!");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
