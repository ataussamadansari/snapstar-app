import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/repositories/auth_repository.dart';
import '../../../routes/app_routes.dart';

class LoginController extends GetxController {
  final AuthRepository _repository = Get.find<AuthRepository>();

  final loginFormKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final emailFocus = FocusNode();
  final passwordFocus = FocusNode();

  RxBool isLoading = false.obs;
  RxBool isPasswordVisible = false.obs;

  Future<void> onLogin() async {
    // 1. Keyboard dismiss karein
    FocusManager.instance.primaryFocus?.unfocus();

    // 2. Validation check
    if (!loginFormKey.currentState!.validate()) return;

    try {
      isLoading.value = true;

      // 3. Firebase Login
      final user = await _repository.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (user != null) {
        // 4. Keyboard band hone ka thoda wait (Smooth transition ke liye)
        await Future.delayed(const Duration(milliseconds: 200));

        // 5. Firestore check
        final isCompleted = await _repository.isProfileCompleted(user.uid);

        if (isCompleted) {
          Get.offAllNamed(Routes.main);
        } else {
          // Profile incomplete hai, data bhej kar setup par le jayein
          Get.offAllNamed(Routes.profileSetup, arguments: {
            'uid': user.uid,
            'email': user.email ?? emailController.text.trim(),
            'name': user.displayName ?? 'user',
          });
        }
      }
    } catch (e) {
      Get.snackbar(
        "Login Error",
        e.toString().split(']').last, // Firebase error code hide karke message dikhayein
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    emailFocus.dispose();
    passwordFocus.dispose();
    super.onClose();
  }
}
