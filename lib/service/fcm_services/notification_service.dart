import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:universal_html/html.dart' as html;
import '../../models/models.dart';
import '../../utils/payment_status_calculator.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// Web VAPID key provided by the user
  static const String vapidKey =
      'BPGj4bk3Wrp_wyVBvmqSXZUZuoqwpLq9h2oUypORck-cvojIVDjLJ99ep4cAOWUh-XEHXenFFJqYrDBXbepurh0';

  /// Initializes FCM, requests permissions, retrieves token, and saves to Firestore.
  Future<void> initializeFCM() async {
    try {
      // 1. Request Notification Permissions via FCM
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      debugPrint('FCM Authorization Status: ${settings.authorizationStatus}');

      // 2. Request Web Browser Notification permission if on Web
      if (kIsWeb) {
        try {
          if (html.Notification.permission != 'granted') {
            await html.Notification.requestPermission();
          }
        } catch (e) {
          debugPrint('Web Notification Request Error: $e');
        }
      }

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        // 3. Retrieve FCM Token (using VAPID key on Web)
        String? token;
        if (kIsWeb) {
          token = await _messaging.getToken(vapidKey: vapidKey);
        } else {
          token = await _messaging.getToken();
        }

        if (token != null) {
          debugPrint('✅ Retrieved FCM Token: $token');
          await saveToken(token);
        }

        // 4. Listen for Token Refreshes
        _messaging.onTokenRefresh.listen((newToken) {
          debugPrint('🔄 FCM Token Refreshed: $newToken');
          saveToken(newToken);
        });
      }
    } catch (e) {
      debugPrint('❌ FCM Initialization Error: $e');
    }
  }

  /// Save Admin FCM Token to both `admins` and `admin_tokens` collections
  Future<void> saveToken(String token) async {
    try {
      final uid = _auth.currentUser?.uid;

      if (uid == null) {
        debugPrint('❌ FCM: User not logged in, token not saved.');
        return;
      }

      final data = {
        'uid': uid,
        'tokens': FieldValue.arrayUnion([token]),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Save to both collections for backend & client compatibility
      await _firestore
          .collection('admins')
          .doc(uid)
          .set(data, SetOptions(merge: true));
      await _firestore
          .collection('admin_tokens')
          .doc(uid)
          .set(data, SetOptions(merge: true));

      debugPrint('✅ FCM Token Saved to Firestore for Admin: $uid');
    } catch (e) {
      debugPrint('❌ Save FCM Token Error: $e');
    }
  }

  /// Remove Admin FCM Token on logout
  Future<void> removeToken(String token) async {
    try {
      final uid = _auth.currentUser?.uid;

      if (uid == null) return;

      final data = {
        'tokens': FieldValue.arrayRemove([token]),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection('admins')
          .doc(uid)
          .set(data, SetOptions(merge: true));
      await _firestore
          .collection('admin_tokens')
          .doc(uid)
          .set(data, SetOptions(merge: true));

      debugPrint('🗑️ FCM Token Removed for Admin: $uid');
    } catch (e) {
      debugPrint('❌ Remove FCM Token Error: $e');
    }
  }

  /// Evaluates payment status and prevents duplicate notifications using `notifiedStatus`.
  Future<void> checkAndNotifyPaymentStatus(Payment payment) async {
    if (payment.docId.isEmpty) return;

    final computedStatus = calculatePaymentStatus(payment.date, payment.plan);

    if (computedStatus == 'Pending' || computedStatus == 'Overdue') {
      // Prevent duplicate notification if already notified for this status in this cycle
      if (payment.notifiedStatus == computedStatus) return;

      final title = computedStatus == 'Pending'
          ? '⚠️ Payment Pending: ${payment.member}'
          : '🔴 Payment Overdue: ${payment.member}';

      final body = computedStatus == 'Pending'
          ? "${payment.member}'s payment of Rs. ${payment.amount} is due soon. Plan: ${payment.plan}"
          : "${payment.member}'s payment of Rs. ${payment.amount} is overdue. Plan: ${payment.plan}";

      // 1. Immediately update notifiedStatus in Firestore to prevent duplicate triggers
      try {
        await _firestore.collection('payments').doc(payment.docId).update({
          'notifiedStatus': computedStatus,
        });
        debugPrint(
          '🔔 Payment doc ${payment.docId} updated notifiedStatus = "$computedStatus"',
        );

        // 2. Dispatch System / Web Notification
        _showNotification(title, body);
      } catch (e) {
        debugPrint('❌ Error updating notifiedStatus for ${payment.docId}: $e');
      }
    } else if (computedStatus == 'Paid') {
      // If payment is Paid and previously had a notifiedStatus, reset it for the next cycle
      if (payment.notifiedStatus != null) {
        try {
          await _firestore.collection('payments').doc(payment.docId).update({
            'notifiedStatus': FieldValue.delete(),
          });
          debugPrint(
            '🔄 Payment doc ${payment.docId} reset notifiedStatus for new cycle.',
          );
        } catch (e) {
          debugPrint('❌ Error resetting notifiedStatus for ${payment.docId}: $e');
        }
      }
    }
  }

  /// Displays system / browser notification on device
  void _showNotification(String title, String body) {
    debugPrint('📢 DISPATCHING NOTIFICATION: $title | $body');

    if (kIsWeb) {
      try {
        if (html.Notification.permission == 'granted') {
          html.Notification(title, body: body, icon: '/icons/Icon-192.png');
        } else {
          html.Notification.requestPermission().then((permission) {
            if (permission == 'granted') {
              html.Notification(title, body: body, icon: '/icons/Icon-192.png');
            }
          });
        }
      } catch (e) {
        debugPrint('Web Notification Error: $e');
      }
    }
  }
}
