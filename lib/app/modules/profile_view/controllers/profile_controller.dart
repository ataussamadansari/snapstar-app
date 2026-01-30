import 'package:get/get.dart';
import 'package:snapstar/app/data/repositories/user_repository.dart';

import '../../../core/constants/firebase_constants.dart';
import '../../../data/models/post_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/post_repostitory.dart';

class ProfileController extends GetxController {
  final UserRepository _userRepo = UserRepository();
  final PostRepository _postRepo = PostRepository(); // Aapki banayi hui repo

  var userModel = Rxn<UserModel>();
  var userPosts = <PostModel>[].obs;
  var filteredPosts = <PostModel>[].obs;
  var selectedFilter = 0.obs; // 0: All, 1: Images, 2: Videos

  @override
  void onInit() {
    super.onInit();
    fetchProfileData();
  }

  void fetchProfileData() {
    String uid = firebaseAuth.currentUser!.uid;
    // Real-time user updates
    _userRepo.provider.getUserStream(uid).listen((data) {
      userModel.value = data;
    });
    // Fetch posts (Iska function repository mein banana hoga)
    loadUserPosts(uid);
  }

  void loadUserPosts(String uid) async {
    // PostRepository mein getUserPosts function add karein
    var posts = await _postRepo.getUserPosts(uid);
    userPosts.assignAll(posts);
    applyFilter(0);
  }

  void applyFilter(int index) {
    selectedFilter.value = index;
    if (index == 0) filteredPosts.assignAll(userPosts);
    if (index == 1) filteredPosts.assignAll(userPosts.where((p) => p.mediaType == MediaType.image));
    if (index == 2) filteredPosts.assignAll(userPosts.where((p) => p.mediaType == MediaType.video));
  }
}