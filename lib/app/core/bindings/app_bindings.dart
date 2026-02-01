import 'package:get/get.dart';
import 'package:snapstar/app/data/controllers/follow_controller.dart';

import '../../data/providers/firebase_auth_provider.dart';
import '../../data/repositories/auth_repository.dart';
import '../../modules/splash_view/controllers/splash_controller.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(FirebaseAuthProvider(), permanent: true);
    Get.lazyPut<AuthRepository>(() => AuthRepository(Get.find()), fenix: true);
    Get.put(SplashController(), permanent: true);
    Get.lazyPut<FollowController>(() => FollowController(), fenix: true);
  }
}
