import 'package:get/get.dart';
import 'package:snapstar/app/modules/login_view/bindings/login_binding.dart';
import 'package:snapstar/app/modules/login_view/views/login_screen.dart';
import 'package:snapstar/app/modules/profile_setup_view/bindings/profile_setup_binding.dart';
import 'package:snapstar/app/modules/profile_setup_view/views/profile_setup_screen.dart';
import 'package:snapstar/app/modules/register_view/bindings/register_binding.dart';
import 'package:snapstar/app/modules/register_view/views/register_screen.dart';
import 'package:snapstar/app/modules/splash_view/bindings/splash_binding.dart';
import 'package:snapstar/app/modules/splash_view/views/splash_screen.dart';
import 'app_routes.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: Routes.splash,
      page: () => SplashScreen(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: Routes.register,
      page: () => RegisterScreen(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: Routes.login,
      page: () => LoginScreen(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: Routes.profileSetup,
      page: () => ProfileSetupScreen(),
      binding: ProfileSetupBinding(),
    ),

  ];
}
