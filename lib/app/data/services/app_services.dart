import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../repositories/auth_repository.dart';

class AppServices extends GetxService {
  Future<AppServices> init() async {
    _setupFCMPlaceholder();
    return this;
  }

  void _setupFCMPlaceholder() {
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        // Repository ko find karke token update karein
        Get.find<AuthRepository>().updateFCMToken(uid, newToken);
      }
    });
  }
}