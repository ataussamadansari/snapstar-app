import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snapstar_app/app/core/utils/helpers.dart';
import 'package:snapstar_app/app/routes/app_routes.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/models/user_model.dart';
import '../../../data/repositories/user_repository.dart';

class SignupController extends GetxController {
  final _supabase = Supabase.instance.client;
  UserRepository get _userRepo => Get.find<UserRepository>();

  final formKey = GlobalKey<FormState>();

  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final cPassCtrl = TextEditingController();

  RxBool hidePassword = true.obs;
  RxBool hideCPassword = true.obs;

  void togglePassword() => hidePassword.toggle();

  void toggleCPassword() => hideCPassword.toggle();

  RxBool isLoading = false.obs;

  void submit() {
    final form = formKey.currentState;
    if (form == null) return;
    if (!form.validate()) return;
    signup();
  }

  Future<void> signup() async {
    try {
      isLoading.value = true;

      final res = await _supabase.auth.signUp(
        email: emailCtrl.text.trim(),
        password: passCtrl.text.trim(),
      );

      final user = res.user;
      if (user == null) return;

      final newUser = UserModel(
        id: user.id,
        name: nameCtrl.text.trim(),
        email: emailCtrl.text.trim(),
        username: '',
        phone: null,
        avatarUrl: null,
        bio: null,
        subscriberCount: 0,
        subscribingCount: 0,
        postsCount: 0,
        role: 'user',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final result = await _userRepo.createProfile(newUser);
      if (result) {
        Get.offAllNamed(Routes.profileSetup);
      }
    } on AuthApiException catch (e) {
      AppHelpers.showSnackBar(title: "SignUp Error", message: e.message);
      debugPrint("SignUp Failed: $e");
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    passCtrl.dispose();
    cPassCtrl.dispose();
    super.onClose();
  }
}
