import 'package:get/get.dart';

import '../../data/providers/firebase_auth_provider.dart';
import '../../data/repositories/auth_repository.dart';
import '../../modules/splash_view/controllers/splash_controller.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(FirebaseAuthProvider(), permanent: true);
    Get.put(AuthRepository(Get.find()), permanent: true);
    Get.put(SplashController(), permanent: true);
    // Get.put(PostController(), permanent: true);
  }
}
