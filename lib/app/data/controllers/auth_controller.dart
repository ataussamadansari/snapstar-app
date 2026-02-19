import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthController extends GetxController {
  final supabase = Supabase.instance.client;

  RxBool isLoading = false.obs;
  Rx<User?> user = Rx<User?>(null);

  @override
  void onInit() {
    user.value = supabase.auth.currentUser;
    supabase.auth.onAuthStateChange.listen((data) {
      user.value = data.session?.user;
    });
    super.onInit();
  }

  Future<void> signup(String email, String password) async {
    isLoading.value = true;
    await supabase.auth.signUp(
      email: email,
      password: password,
    );
    isLoading.value = false;
  }

  Future<void> login(String email, String password) async {
    isLoading.value = true;
    await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    isLoading.value = false;
  }

  Future<void> logout() async {
    await supabase.auth.signOut();
  }
}
