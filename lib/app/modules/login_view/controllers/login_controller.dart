import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/repositories/auth_repository.dart';
import '../../../routes/app_routes.dart';

class LoginController extends GetxController {
  final AuthRepository _repository = Get.find<AuthRepository>();

  final loginFormKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Focus nodes
  final emailFocus = FocusNode();
  final passwordFocus = FocusNode();

  RxBool isLoading = false.obs;
  RxBool isPasswordVisible = false.obs;

  Future<void> onLogin() async {
    FocusManager.instance.primaryFocus?.unfocus();

    if (!loginFormKey.currentState!.validate()) return;

    try {
      isLoading.value = true;

      final user = await _repository.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (user != null) {
        Get.offAllNamed(Routes.main);
      }
    } catch (e) {
      Get.snackbar(
        "Login Failed",
        e.toString(),
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
