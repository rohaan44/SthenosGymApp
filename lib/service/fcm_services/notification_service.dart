import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Save Admin FCM Token
  Future<void> saveToken(String token) async {
    try {
      final uid = _auth.currentUser?.uid;

      if (uid == null) {
        print("❌ User not logged in.");
        return;
      }

      await _firestore.collection("admins").doc(uid).set({
        "uid": uid,
        "tokens": FieldValue.arrayUnion([token]),
        "updatedAt": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print("✅ FCM Token Saved");
    } catch (e) {
      print("❌ Save Token Error: $e");
    }
  }

  /// Remove Admin FCM Token
  Future<void> removeToken(String token) async {
    try {
      final uid = _auth.currentUser?.uid;

      if (uid == null) {
        print("❌ User not logged in.");
        return;
      }

      await _firestore.collection("admins").doc(uid).set({
        "tokens": FieldValue.arrayRemove([token]),
        "updatedAt": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print("🗑️ FCM Token Removed");
    } catch (e) {
      print("❌ Remove Token Error: $e");
    }
  }
}
