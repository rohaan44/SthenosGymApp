import 'package:app/service/fcm_services/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Top-level background message handler required by FCM.
/// Must be annotated with @pragma('vm:entry-point') to prevent tree-shaking.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("Handling background FCM message: ${message.messageId}");
  debugPrint("Background Title: ${message.notification?.title}");
  debugPrint("Background Body: ${message.notification?.body}");
}

class FCMService {
  FCMService._();

  static final instance = FCMService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    // 1. Register top-level background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 2. Request FCM permissions
    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    // 3. Listen for foreground and opened messages
    FirebaseMessaging.onMessage.listen(_onForeground);
    FirebaseMessaging.onMessageOpenedApp.listen(_onOpened);

    // 4. Retrieve & store FCM token
    final token = await getToken();
    debugPrint("FCM TOKEN => $token");

    if (token != null) {
      await NotificationService.instance.saveToken(token);
    }

    // 5. Listen for token refreshes
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      await NotificationService.instance.saveToken(newToken);
    });
  }

  Future<String?> getToken() async {
    try {
      debugPrint("Getting FCM Token...");
      final token = await _messaging.getToken(
        vapidKey: NotificationService.vapidKey,
      );
      debugPrint("FCM TOKEN RETRIEVED => $token");
      return token;
    } catch (e, s) {
      debugPrint("FCM TOKEN ERROR => $e");
      debugPrint(s.toString());
      return null;
    }
  }

  void _onForeground(RemoteMessage message) {
    debugPrint("========== FCM FOREGROUND ==========");
    debugPrint("Title : ${message.notification?.title}");
    debugPrint("Body  : ${message.notification?.body}");
    debugPrint("====================================");
  }

  void _onOpened(RemoteMessage message) {
    debugPrint("Notification Clicked");
    final data = message.data;
    debugPrint("Payload data: $data");
  }
}
