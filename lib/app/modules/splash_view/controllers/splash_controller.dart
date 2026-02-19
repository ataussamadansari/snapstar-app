import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/repositories/user_repository.dart';
import '../../../routes/app_routes.dart';

class SplashController extends GetxController {
  final _supabase = Supabase.instance.client;
  UserRepository get _userRepo => Get.find<UserRepository>();

  @override
  void onReady() {
    super.onReady();
    Future.microtask(_checkAuth);
  }

  Future<void> _checkAuth() async {
    try {
      await Future.delayed(const Duration(seconds: 1));

      final user = _supabase.auth.currentUser;

      if (user == null) {
        Get.offAllNamed(Routes.login);
        return;
      }

      final profile = await _userRepo.fetchProfile(user.id);

      if (profile == null) {
        Get.offAllNamed(Routes.signup);
        return;
      }

      if (profile.username.trim().isEmpty) {
        Get.offAllNamed(Routes.profileSetup);
        return;
      }

      Get.offAllNamed(Routes.main);
    } catch (e) {
      debugPrint("Splash error: $e");
      Get.offAllNamed(Routes.login);
    }
  }


}
