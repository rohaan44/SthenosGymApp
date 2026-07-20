import 'package:app/service/fcm_services/notification_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class FCMService {
  FCMService._();

  static final instance = FCMService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  Future<void> initialize() async {
    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    FirebaseMessaging.onMessage.listen(_onForeground);

    FirebaseMessaging.onMessageOpenedApp.listen(_onOpened);

    final token = await getToken();

    debugPrint("FCM TOKEN => $token");

    if (token != null) {
      await NotificationService.instance.saveToken(token);
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      await NotificationService.instance.saveToken(newToken);
    });
  }

  Future<String?> getToken() async {
    try {
      debugPrint("Getting Token...");

      final token = await _messaging.getToken(
        vapidKey:
            "BPGj4bk3Wrp_wyVBvmqSXZUZuoqwpLq9h2oUypORck-cvojIVDjLJ99ep4cAOWUh-XEHXenFFJqYrDBXbepurh0",
      );

      debugPrint("TOKEN => $token");

      return token;
    } catch (e, s) {
      debugPrint("FCM ERROR => $e");
      debugPrint(s.toString());
      return null;
    }
  }

  void _onForeground(RemoteMessage message) {
    debugPrint("========== FCM ==========");
    debugPrint("Title : ${message.notification?.title}");
    debugPrint("Body  : ${message.notification?.body}");
    debugPrint("=========================");
  }

  void _onOpened(RemoteMessage message) {
    debugPrint("Notification Clicked");

    final data = message.data;

    debugPrint(data.toString());

    // Future
    // Navigate according to notification type
  }
}
