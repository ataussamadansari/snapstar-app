import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snapstar/app/data/providers/notification_provider.dart';
import 'package:snapstar/app/data/repositories/auth_repository.dart';

import '../../../core/constants/firebase_constants.dart';
import '../../../data/models/user_model.dart';
import '../../../routes/app_routes.dart';

class ProfileSetupController extends GetxController {
  final AuthRepository _repository = Get.find<AuthRepository>();

  final formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final bioController = TextEditingController();
  final phoneController = TextEditingController();

  RxBool isLoading = false.obs;

  // Register screen se aaya hua data
  final String uid = Get.arguments['uid'];
  final String name = Get.arguments['name'];
  final String email = Get.arguments['email'];

  // Username validation logic (Checking Firestore)
  Future<bool> isUsernameTaken(String username) async {
    final query = await db
        .collection('users')
        .where('username', isEqualTo: username.toLowerCase())
        .get();
    return query.docs.isNotEmpty;
  }

  Future<void> onCompleteProfile() async {
    if (formKey.currentState!.validate()) {
      try {
        isLoading.value = true;
        // 1. Check if username is unique
        bool taken = await isUsernameTaken(usernameController.text.trim());
        if (taken) {
          Get.snackbar("Error", "Username is already taken. Try another.");
          return;
        }

        // FCM Token
        String? token = await NotificationProvider().getFcmToken();

        // 2. Create UserModel object
        UserModel newUser = UserModel(
          uid: uid,
          name: name,
          username: usernameController.text.trim().toLowerCase(),
          email: email,
          phone: phoneController.text.trim(),
          photoUrl: '', // Default empty
          bio: bioController.text.trim(),
          followerCount: 0,
          followingCount: 0,
          postsCount: 0,
          isPrivate: false,
          isBlocked: false,
          role: 'user',
          fcmToken: token ?? '', // Will be updated with notification setup
          lastSeen: Timestamp.now(),
          isOnline: true,
          createdAt: Timestamp.now(),
          updatedAt: Timestamp.now(),
        );

        // 3. Save to Firestore via Repository
        await _repository.saveUserProfile(newUser);

        // 4. Success -> Go to Home
        Get.offAllNamed(Routes.main);
      } catch (e) {
        Get.snackbar("Error", e.toString());
      } finally {
        isLoading.value = false;
      }
    }
  }
}