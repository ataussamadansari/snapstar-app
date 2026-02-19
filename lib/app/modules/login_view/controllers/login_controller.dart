import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snapstar_app/app/core/utils/helpers.dart';
import 'package:snapstar_app/app/routes/app_routes.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/repositories/user_repository.dart';

class LoginController extends GetxController {
  final _supabase = Supabase.instance.client;
  UserRepository get _userRepo => Get.find<UserRepository>();

  final formKey = GlobalKey<FormState>();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  RxBool isLoading = false.obs;
  RxBool hidePassword = true.obs;

  void togglePassword() => hidePassword.toggle();

  Future<void> login() async {
    final form = formKey.currentState;
    if (form == null) return;
    if (!form.validate()) return;

    try {
      isLoading.value = true;

      /// 1️⃣ AUTH LOGIN
      final res = await _supabase.auth.signInWithPassword(
        email: emailCtrl.text.trim(),
        password: passCtrl.text.trim(),
      );

      final user = res.user;
      if (user == null) {
        throw Exception("Login failed");
      }

      /// 2️⃣ FETCH PROFILE
      final profile = await _userRepo.fetchProfile(user.id);

      /// 3️⃣ REDIRECT LOGIC (NO SPLASH)
      if (profile == null) {
        Get.offAllNamed(Routes.signup);
        return;
      }

      if (profile.username.trim().isEmpty) {
        Get.offAllNamed(Routes.profileSetup);
        return;
      }

      /// 4️⃣ PROFILE COMPLETE
      Get.offAllNamed(Routes.main);

    } on AuthApiException catch (e) {
      AppHelpers.showSnackBar(
        title: "Login Failed",
        message: e.message,
      );
    } catch (e) {
      AppHelpers.showSnackBar(
        title: "Error",
        message: e.toString(),
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    super.onClose();
  }
}

