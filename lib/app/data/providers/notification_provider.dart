import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationProvider {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<String?> getFcmToken() async {
    NotificationSettings settings = await _fcm.requestPermission();

    if(settings.authorizationStatus == AuthorizationStatus.authorized) {
      return await _fcm.getToken();
    }
    return null;
  }
}