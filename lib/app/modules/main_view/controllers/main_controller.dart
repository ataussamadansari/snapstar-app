import 'package:get/get.dart';
import 'package:snapstar/app/core/constants/firebase_constants.dart';
import 'package:snapstar/app/data/repositories/user_repository.dart';

import '../../../data/models/user_model.dart';
import '../../reels_view/controllers/reels_controller.dart';

class MainController extends GetxController {
  final UserRepository userRepository = UserRepository();
  final ReelsController reelsController = Get.find();

  final currentUser = Rxn<UserModel>();
  final selectedIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUser();
  }

  void fetchUser() async {
    final uid = firebaseAuth.currentUser?.uid;
    if (uid != null) {
      currentUser.value = await userRepository.getUser(uid);
    }
  }

  /// 🔥 TAB CHANGE BRAIN
  void changeTab(int index) {
    selectedIndex.value = index;

    if (index == 3) {
      reelsController.resumeReels(); // entering reels
    } else {
      reelsController.pauseReels(); // leaving reels
    }
  }
}
