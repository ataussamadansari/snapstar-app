import 'dart:io';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:snapstar/app/data/repositories/story_repository.dart';

import '../../../core/constants/firebase_constants.dart';
import '../../../data/controllers/follow_controller.dart';
import '../../../data/models/post_model.dart';
import '../../../data/models/story_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/home_repository.dart';

class HomeController extends GetxController {
  final HomeRepository _repo = HomeRepository();
  final StoryRepository _storyRepo = StoryRepository();

  final posts = <PostModel>[].obs;
  final suggestions = <UserModel>[].obs;
  final allStories = <StoryModel>[].obs; // 🔥 Added
  final currentUser = Rxn<UserModel>(); // For "My Story" circle
  final loading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _fetchCurrentUser();
    _bindGlobalFeed();
    _bindStories(); // 🔥 Start listening to stories
    loadSuggestions();
  }

  void _fetchCurrentUser() async {
    currentUser.value = await _repo.getCurrentUser();
  }

  void _bindStories() {
    String myUid = firebaseAuth.currentUser!.uid;
    _storyRepo.getActiveStories(myUid).listen((data) {
      // Group stories by User (taaki ek user ka ek hi circle dikhe)
      // Filhaal hum unique users ki latest stories dikha rahe hain
      final Map<String, StoryModel> uniqueStories = {};
      for (var story in data) {
        if (!uniqueStories.containsKey(story.userId)) {
          uniqueStories[story.userId] = story;
        }
      }
      allStories.assignAll(uniqueStories.values.toList());
    });
  }

  Future<void> pickAndUploadStory() async {
    final ImagePicker picker = ImagePicker();

    // User ko option dena (Gallery/Camera)
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null && currentUser.value != null) {
      loading.value = true;
      try {
        await _storyRepo.uploadNewStory(
          file: File(pickedFile.path),
          currentUser: currentUser.value!,
          isVideo: false, // Image picker hai isliye false
        );
        Get.snackbar("Success", "Story uploaded successfully!",
            snackPosition: SnackPosition.BOTTOM);
      } catch (e) {
        Get.snackbar("Error", "Failed to upload story");
      } finally {
        loading.value = false;
      }
    }
  }

  Future<void> refreshHome() async {
    loading.value = true;
    await Future.delayed(const Duration(milliseconds: 500));
    loading.value = false;
  }


  void _bindGlobalFeed() {
    _repo.getGlobalFeed().listen((data) {
      posts.assignAll(data);
      loading.value = false;
    });
  }

  Future<void> loadSuggestions() async {
    final users = await _repo.getSuggestions();
    suggestions.assignAll(users);

    // 🔥 Har suggested user ki follow state turant fetch karein
    final followCtrl = Get.find<FollowController>();
    for (var user in users) {
      // Ye method Firestore se isFollowing aur followRequests dono check karega
      followCtrl.initUser(user);
    }
  }

  /*Future<void> loadSuggestions() async {
    suggestions.value = await _repo.getSuggestions();
  }*/
}

