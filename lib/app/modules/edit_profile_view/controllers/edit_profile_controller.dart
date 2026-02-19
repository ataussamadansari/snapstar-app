import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:snapstar_app/app/core/utils/helpers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/user_repository.dart';
import '../../profile_view/controllers/profile_controller.dart';

class EditProfileController extends GetxController {
  final UserRepository _userRepo = Get.find<UserRepository>();
  final _supabase = Supabase.instance.client;
  final formKey = GlobalKey<FormState>();
  late TextEditingController nameCtrl;
  late TextEditingController bioCtrl;
  late TextEditingController phoneCtrl;

  Rxn<UserModel> userProfile = Rxn<UserModel>();
  Rx<File?> selectedImage = Rx<File?>(null);
  RxBool isLoading = false.obs;

  // New Reactive Features
  RxInt bioLength = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadInitialData();
  }
  void _loadInitialData() async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      final profile = await _userRepo.fetchProfile(user.id);
      userProfile.value = profile;

      nameCtrl = TextEditingController(text: profile?.name ?? "");
      bioCtrl = TextEditingController(text: profile?.bio ?? "");
      phoneCtrl = TextEditingController(text: profile?.phone ?? "");

      bioLength.value = bioCtrl.text.length;

      bioCtrl.addListener(() => bioLength.value = bioCtrl.text.length);
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 60);
    if (pickedFile != null) {
      selectedImage.value = File(pickedFile.path);
    }
  }

  Future<void> updateProfile() async {
    if (!formKey.currentState!.validate()) return;

    try {
      isLoading.value = true;
      final userId = _supabase.auth.currentUser!.id;
      String? photoUrl = userProfile.value?.avatarUrl;

      // 1. Image Upload
      if (selectedImage.value != null) {
        final fileExt = selectedImage.value!.path.split('.').last;
        final filePath = 'profiles/$userId-${DateTime.now().millisecondsSinceEpoch}.$fileExt';

        await _supabase.storage.from('avatars').upload(
          filePath,
          selectedImage.value!,
          fileOptions: const FileOptions(upsert: true),
        );
        photoUrl = _supabase.storage.from('avatars').getPublicUrl(filePath);
      }

      // 2. Database Update
      final updateData = {
        'name': nameCtrl.text.trim(),
        'bio': bioCtrl.text.trim(),
        'phone': phoneCtrl.text.trim(),
        'avatar_url': photoUrl,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _userRepo.updateProfile(userId, updateData);

      // Real-time UI refresh signal
      if (Get.isRegistered<ProfileController>()) {
        Get.find<ProfileController>().fetchMyProfile();
      }

      Get.back(result: true);
      AppHelpers.showSnackBar(
        title: "Success",
        message: "Profile updated successfully",
        isError: false,
      );
    } on PostgrestException catch (e) {
      AppHelpers.showSnackBar(
        title: "DB Error",
        message: e.message,
        isError: true,
      );
    } catch (e) {
      debugPrint("🔴 EditProfile: Error during update: $e");
      AppHelpers.showSnackBar(
        title: "Error",
        message: e.toString(),
        isError: true,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    debugPrint("🚪 EditProfile: Closing controller and disposing resources.");
    nameCtrl.dispose();
    bioCtrl.dispose();
    super.onClose();
  }
}
