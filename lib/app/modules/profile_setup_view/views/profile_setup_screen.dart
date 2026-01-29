import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/profile_setup_controller.dart';

class ProfileSetupScreen extends GetView<ProfileSetupController> {
  const ProfileSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Stack(
        children: [
          Scaffold(
            appBar: AppBar(title: const Text("Setup Profile"), automaticallyImplyLeading: false),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: controller.formKey,
                child: Column(
                  children: [
                    const Text("Almost there! Let's personalize your profile.",
                        style: TextStyle(fontSize: 16, color: Colors.grey)),
                    const SizedBox(height: 30),

                    // Username Field
                    TextFormField(
                      controller: controller.usernameController,
                      decoration: const InputDecoration(
                        labelText: "Username",
                        prefixText: "@ ",
                        border: OutlineInputBorder(),
                        helperText: "Must be unique (e.g., devize_tech)",
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return "Username is required";
                        if (value.length < 3) return "Too short";
                        if (value.contains(' ')) return "No spaces allowed";
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Phone Field (Optional)
                    TextFormField(
                      controller: controller.phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: "Phone Number",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Bio Field
                    TextFormField(
                      controller: controller.bioController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: "Bio",
                        border: OutlineInputBorder(),
                        hintText: "Tell us about yourself...",
                      ),
                    ),
                    const SizedBox(height: 40),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: controller.onCompleteProfile,
                        child: const Text("Finish & Get Started"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Full Screen Loader
          Obx(() => controller.isLoading.value
              ? Container(
            color: Colors.black54,
            child: const Center(child: CircularProgressIndicator()),
          )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }
}
