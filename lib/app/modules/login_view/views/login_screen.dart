import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_routes.dart';
import '../controllers/login_controller.dart';

class LoginScreen extends GetView<LoginController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Form(
                      key: controller.loginFormKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 40),

                          const Text(
                            "Welcome Back!",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text("Login to your account to continue"),

                          const SizedBox(height: 40),

                          // Email
                          TextFormField(
                            controller: controller.emailController,
                            focusNode: controller.emailFocus,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.emailAddress,
                            onFieldSubmitted: (_) => FocusScope.of(context)
                                .requestFocus(controller.passwordFocus),
                            decoration: const InputDecoration(
                              labelText: "Email",
                              prefixIcon: Icon(Icons.email_outlined),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) =>
                            GetUtils.isEmail(value ?? '')
                                ? null
                                : "Please enter a valid email",
                          ),

                          const SizedBox(height: 20),

                          // Password
                          Obx(() => TextFormField(
                            controller: controller.passwordController,
                            focusNode: controller.passwordFocus,
                            textInputAction: TextInputAction.done,
                            obscureText:
                            !controller.isPasswordVisible.value,
                            onFieldSubmitted: (_) =>
                                controller.onLogin(),
                            decoration: InputDecoration(
                              labelText: "Password",
                              prefixIcon:
                              const Icon(Icons.lock_outline),
                              border: const OutlineInputBorder(),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  controller.isPasswordVisible.value
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () =>
                                    controller.isPasswordVisible.toggle(),
                              ),
                            ),
                            validator: (value) =>
                            (value?.length ?? 0) < 6
                                ? "Password must be at least 6 characters"
                                : null,
                          )),

                          const SizedBox(height: 10),

                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                // TODO: Forgot password flow
                              },
                              child: const Text("Forgot Password?"),
                            ),
                          ),

                          const SizedBox(height: 30),

                          // Login Button
                          Obx(() => SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: controller.isLoading.value
                                  ? null
                                  : controller.onLogin,
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(12),
                                ),
                              ),
                              child: controller.isLoading.value
                                  ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                                  : const Text(
                                "Login",
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          )),

                          const SizedBox(height: 20),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Don't have an account?"),
                              TextButton(
                                onPressed: () =>
                                    Get.toNamed(Routes.register),
                                child: const Text(
                                  "Sign Up",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold),
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
      ),
    );
  }
}
