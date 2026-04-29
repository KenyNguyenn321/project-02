import 'package:firebase_messaging/firebase_messaging.dart';

// handles Firebase Cloud Messaging setup
class NotificationService {
  // Firebase Messaging instance
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // request notification permission
  Future<NotificationSettings> requestPermission() async {
    return await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  // get device FCM token for testing evidence
  Future<String?> getToken() async {
    return await _messaging.getToken();
  }

  // initialize basic notification setup
  Future<void> initialize() async {
    // request user permission
    await requestPermission();

    // retrieve token for Firebase messaging evidence
    await getToken();
  }
}