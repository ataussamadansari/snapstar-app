import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snapstar/app/data/repositories/auth_repository.dart';
import 'package:snapstar/app/routes/app_routes.dart';

class RegisterController extends GetxController {
  final AuthRepository _repository = Get.find<AuthRepository>();

  final registerFormKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Focus nodes
  final nameFocus = FocusNode();
  final emailFocus = FocusNode();
  final passwordFocus = FocusNode();
  final confirmPasswordFocus = FocusNode();

  RxBool isLoading = false.obs;
  RxBool showPassword = false.obs;
  RxBool showConfirmPassword = false.obs;

  String? validateEmail(String? value) {
    if (!GetUtils.isEmail(value ?? '')) return "Enter a valid email";
    return null;
  }

  String? validatePassword(String? value) {
    if ((value?.length ?? 0) < 6) return "Password must be at least 6 characters";
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value != passwordController.text) return "Passwords do not match";
    return null;
  }

  Future<void> onRegisterNext() async {
    FocusManager.instance.primaryFocus?.unfocus();

    if (!registerFormKey.currentState!.validate()) return;

    try {
      isLoading.value = true;

      final user = await _repository.register(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (user != null) {
        Get.toNamed(
          Routes.profileSetup,
          arguments: {
            'uid': user.uid,
            'email': user.email,
            'name': nameController.text.trim(),
          },
        );
      }
    } catch (e) {
      Get.snackbar("Error", e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    nameFocus.dispose();
    emailFocus.dispose();
    passwordFocus.dispose();
    confirmPasswordFocus.dispose();
    super.onClose();
  }
}
