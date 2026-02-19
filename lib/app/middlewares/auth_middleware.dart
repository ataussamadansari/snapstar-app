import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/repositories/user_repository.dart';
import '../routes/app_routes.dart';

class AuthMiddleware extends GetMiddleware {
  final _supabase = Supabase.instance.client;
  UserRepository get _userRepo => Get.find<UserRepository>();

  @override
  int? get priority => 1;

  @override
  Future<GetNavConfig?> redirectDelegate(GetNavConfig route) async {
    final user = _supabase.auth.currentUser;

    /// 1️⃣ NOT LOGGED IN
    if (user == null) {
      return GetNavConfig.fromRoute(Routes.login);
    }

    try {
      /// 2️⃣ FETCH PROFILE
      final profile = await _userRepo.fetchProfile(user.id);

      /// 3️⃣ PROFILE NOT CREATED
      if (profile == null) {
        return GetNavConfig.fromRoute(Routes.signup);
      }

      /// 4️⃣ PROFILE INCOMPLETE
      if (profile.username.trim().isEmpty) {
        final currentPath = route.uri.path;

        if (currentPath != Routes.profileSetup) {
          return GetNavConfig.fromRoute(Routes.profileSetup);
        }
      }
    } catch (e) {
      debugPrint("AuthMiddleware error: $e");
      return GetNavConfig.fromRoute(Routes.login);
    }

    /// 5️⃣ ALLOW NAVIGATION
    return route;
  }
}
