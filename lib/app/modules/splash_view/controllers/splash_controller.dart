import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../data/repositories/auth_repository.dart';
import '../../../routes/app_routes.dart';

class SplashController extends GetxController {
  final AuthRepository _repository = Get.find<AuthRepository>();

  @override
  void onReady() {
    super.onReady();
    Future.microtask(_checkAuth); // ✅ THIS IS REQUIRED
  }

  Future<void> _checkAuth() async {
    await Future.delayed(Duration(seconds: 3));
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      Get.offAllNamed(Routes.login);
      return;
    }

    final isCompleted =
    await _repository.isProfileCompleted(user.uid);

    if (isCompleted) {
      Get.offAllNamed(Routes.main);
    } else {
      Get.offAllNamed(
        Routes.profileSetup,
        arguments: {
          'uid': user.uid,
          'email': user.email ?? '',
          'name': user.displayName ?? 'user',
        },
      );
    }
  }
}

