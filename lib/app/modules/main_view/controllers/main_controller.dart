import 'package:get/get.dart';
import 'package:snapstar/app/core/constants/firebase_constants.dart';
import 'package:snapstar/app/data/repositories/user_repository.dart';

import '../../../data/models/user_model.dart';

class MainController extends GetxController {
  final UserRepository userRepository = UserRepository();

  // Use Rxn to handle null states safely
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
      // Fetching user data reactively
      final user = await userRepository.getUser(uid);
      currentUser.value = user;
    }
  }

  void changeTab(int index) {
    selectedIndex.value = index;
  }
}
