import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/register_controller.dart';

class RegisterScreen extends GetView<RegisterController> {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(title: const Text("Create Account")),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Form(
                    key: controller.registerFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: controller.nameController,
                          focusNode: controller.nameFocus,
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) =>
                              FocusScope.of(context).requestFocus(controller.emailFocus),
                          decoration: const InputDecoration(
                            labelText: "Full Name",
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) =>
                          value!.isEmpty ? "Enter your name" : null,
                        ),

                        const SizedBox(height: 15),

                        TextFormField(
                          controller: controller.emailController,
                          focusNode: controller.emailFocus,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.emailAddress,
                          onFieldSubmitted: (_) =>
                              FocusScope.of(context).requestFocus(controller.passwordFocus),
                          decoration: const InputDecoration(
                            labelText: "Email",
                            border: OutlineInputBorder(),
                          ),
                          validator: controller.validateEmail,
                        ),

                        const SizedBox(height: 15),

                        Obx(() => TextFormField(
                          controller: controller.passwordController,
                          focusNode: controller.passwordFocus,
                          textInputAction: TextInputAction.next,
                          obscureText: !controller.showPassword.value,
                          onFieldSubmitted: (_) => FocusScope.of(context)
                              .requestFocus(controller.confirmPasswordFocus),
                          decoration: InputDecoration(
                            labelText: "Password",
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(
                                controller.showPassword.value
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: controller.showPassword.toggle,
                            ),
                          ),
                          validator: controller.validatePassword,
                        )),

                        const SizedBox(height: 15),

                        Obx(() => TextFormField(
                          controller: controller.confirmPasswordController,
                          focusNode: controller.confirmPasswordFocus,
                          textInputAction: TextInputAction.done,
                          obscureText: !controller.showConfirmPassword.value,
                          onFieldSubmitted: (_) => controller.onRegisterNext(),
                          decoration: InputDecoration(
                            labelText: "Confirm Password",
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(
                                controller.showConfirmPassword.value
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: controller.showConfirmPassword.toggle,
                            ),
                          ),
                          validator: controller.validateConfirmPassword,
                        )),

                        const SizedBox(height: 30),

                        Obx(() => SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: controller.isLoading.value
                                ? null
                                : controller.onRegisterNext,
                            child: controller.isLoading.value
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text("Next"),
                          ),
                        )),

                        SizedBox(height: 20),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Already have an account?"),
                            TextButton(
                              onPressed: () => Get.back(),
                              child: const Text(
                                "Login",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
