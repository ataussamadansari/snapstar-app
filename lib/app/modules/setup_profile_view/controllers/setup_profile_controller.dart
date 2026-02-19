import 'dart:io';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:snapstar_app/app/core/utils/helpers.dart';
import 'package:snapstar_app/app/routes/app_routes.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/repositories/user_repository.dart';

class SetupProfileController extends GetxController {
  final _supabase = Supabase.instance.client;

  UserRepository get _userRepo => Get.find<UserRepository>();

  final ImagePicker _picker = ImagePicker();

  final formKey = GlobalKey<FormState>();

  final usernameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final bioCtrl = TextEditingController();

  Rx<File?> profileImage = Rx<File?>(null);
  RxBool isLoading = false.obs;

  Future<void> pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      profileImage.value = File(pickedFile.path);
    }
  }

  Future<void> submit() async {
    final form = formKey.currentState;
    if (form == null) return;
    if (!form.validate()) return;

    try {
      isLoading.value = true;
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception("User not authenticated");
      }

      final username = usernameCtrl.text.trim();

      /// 1️⃣ CHECK USERNAME UNIQUE
      final isAvailable = await _userRepo.checkUsername(username);
      if (!isAvailable) {
        AppHelpers.showSnackBar(
          title: "Username taken",
          message: "Please choose another username",
        );
        return;
      }

      /// 2️⃣ UPLOAD PROFILE IMAGE (OPTIONAL)
      String? photoUrl;
      if (profileImage.value != null) {
        final file = profileImage.value!;
        final fileExt = file.path.split('.').last;
        final filePath = 'profiles/${user.id}.$fileExt';

        await _supabase.storage
            .from('avatars')
            .upload(
              filePath,
              file,
              fileOptions: const FileOptions(upsert: true),
            );

        photoUrl = _supabase.storage.from('avatars').getPublicUrl(filePath);
      }

      /// 3️⃣ UPDATE USER PROFILE
      await _userRepo.updateProfile(user.id, {
        'username': username,
        'phone': phoneCtrl.text.trim().isEmpty ? null : phoneCtrl.text.trim(),
        'bio': bioCtrl.text.trim().isEmpty ? null : bioCtrl.text.trim(),
        'avatar_url': photoUrl,
        'updated_at': DateTime.now().toIso8601String(),
      });

      /// 4️⃣ NAVIGATE TO HOME
      Get.offAllNamed(Routes.main);
    } on PostgrestException catch (e) {
      AppHelpers.showSnackBar(title: "Database Error", message: e.message);
    } catch (e) {
      AppHelpers.showSnackBar(title: "Error", message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    usernameCtrl.dispose();
    phoneCtrl.dispose();
    bioCtrl.dispose();
    super.onClose();
  }
}
