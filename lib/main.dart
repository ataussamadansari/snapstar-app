import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'app/data/services/app_services.dart';
import 'firebase_options.dart';

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase Initialize yahan hota hai
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Hide nav bar + status bar (immersive sticky)
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  // Initialize Services before runApp
  await Get.putAsync(() => AppServices().init());

  runApp(const MyApp());
}
