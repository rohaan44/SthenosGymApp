import 'dart:async';
import 'package:app/models/models.dart';
import 'package:app/service/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MainDashboardProvider extends ChangeNotifier {
  MainDashboardProvider() {
    initNotificationsListener();
  }

  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;

  void setSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  int _visibleCount = 10;
  int get visibleCount => _visibleCount;

  void setvisibleCount(int index) {
    _visibleCount = index;
    notifyListeners();
  }

  void setCount() {
    _visibleCount += 10;
    notifyListeners();
  }

  final List<Map<String, dynamic>> notifications = [];

  Set<String> _seenNotificationKeys = {};
  Set<String> get seenNotificationKeys => _seenNotificationKeys;

  int get unreadNotificationsCount {
    if (notifications.isEmpty) return 0;
    return notifications.where((n) {
      final id = n['id'] as String?;
      return id == null || !_seenNotificationKeys.contains(id);
    }).length;
  }

  StreamSubscription<List<Member>>? _membersSubscription;
  StreamSubscription<List<Payment>>? _paymentsSubscription;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _adminSubscription;
  StreamSubscription<User?>? _authSubscription;

  List<Member> _members = [];
  List<Payment> _payments = [];

  void initNotificationsListener() {
    _membersSubscription?.cancel();
    _paymentsSubscription?.cancel();
    _adminSubscription?.cancel();
    _authSubscription?.cancel();

    _membersSubscription = FirestoreService.instance.membersStream().listen((membersList) {
      _members = membersList;
      _rebuildNotifications();
    });

    _paymentsSubscription = FirestoreService.instance.paymentsStream().listen((paymentsList) {
      _payments = paymentsList;
      _rebuildNotifications();
    });

    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      _adminSubscription?.cancel();
      if (user != null) {
        _listenToAdminDoc(user.uid);
      } else {
        _seenNotificationKeys = {};
        notifyListeners();
      }
    });

    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUid != null) {
      _listenToAdminDoc(currentUid);
    }
  }

  void _listenToAdminDoc(String uid) {
    _adminSubscription?.cancel();
    _adminSubscription = FirebaseFirestore.instance
        .collection('admins')
        .doc(uid)
        .snapshots()
        .listen((doc) {
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        final List<dynamic>? seenList = data['seenNotificationKeys'] as List<dynamic>?;
        if (seenList != null) {
          _seenNotificationKeys = Set<String>.from(seenList.map((e) => e.toString()));
          notifyListeners();
        }
      }
    }, onError: (e) {
      debugPrint("Error listening to admin doc: $e");
    });
  }

  Future<void> markNotificationsAsSeen() async {
    final currentIds = notifications
        .map((n) => n['id'] as String?)
        .where((id) => id != null && id.isNotEmpty)
        .cast<String>()
        .toSet();

    if (currentIds.isEmpty) return;

    _seenNotificationKeys.addAll(currentIds);
    notifyListeners();

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        await FirebaseFirestore.instance.collection('admins').doc(uid).set({
          'seenNotificationKeys': _seenNotificationKeys.toList(),
          'lastNotificationSeenAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint("Error marking notifications as seen: $e");
    }
  }

  void _rebuildNotifications() {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    final List<Map<String, dynamic>> newNotifications = [];

    for (final m in _members) {
      if (m.status != 'Active') continue;
      if (m.expiryDate.isEmpty) continue;

      DateTime? expiry;
      try {
        expiry = DateTime.parse(m.expiryDate);
      } catch (_) {
        continue;
      }

      final expiryDate = DateTime(expiry.year, expiry.month, expiry.day);
      final diffInDays = expiryDate.difference(todayDate).inDays;

      // Find payments for this member
      final memberPayments = _payments.where((p) => p.memberId == m.docId).toList();

      if (diffInDays == 0) {
        newNotifications.add({
          "id": "${m.docId}_expired_today",
          "color": Colors.red,
          "icon": Icons.warning,
          "title": "Membership expired today",
          "subtitle": "${m.name} (Gym ID: ${m.gymId})",
          "time": "Expiry: ${m.expiryDate}",
          "phone": m.phone,
          "name": m.name,
          "gymId": m.gymId,
          "expiryDate": m.expiryDate,
        });
      } else if (diffInDays == 3) {
        newNotifications.add({
          "id": "${m.docId}_expires_in_3_days",
          "color": Colors.amber,
          "icon": Icons.schedule,
          "title": "Membership expires in 3 days",
          "subtitle": "${m.name} (Gym ID: ${m.gymId})",
          "time": "In 3 days • Expiry: ${m.expiryDate}",
          "phone": m.phone,
          "name": m.name,
          "gymId": m.gymId,
          "expiryDate": m.expiryDate,
        });
      } else if (diffInDays == 1 || diffInDays == 2) {
        newNotifications.add({
          "id": "${m.docId}_due_in_${diffInDays}_days",
          "color": Colors.amber.shade300,
          "icon": Icons.schedule,
          "title": "Fee due soon",
          "subtitle": "${m.name} (Gym ID: ${m.gymId})",
          "time": "In $diffInDays day${diffInDays > 1 ? 's' : ''} • Expiry: ${m.expiryDate}",
          "phone": m.phone,
          "name": m.name,
          "gymId": m.gymId,
          "expiryDate": m.expiryDate,
        });
      } else if (diffInDays < 0) {
        final isOverdue = FirestoreService.isOverdue(m, memberPayments);
        if (isOverdue) {
          final overdueDays = todayDate.difference(expiryDate).inDays;
          if (overdueDays == 1) {
            newNotifications.add({
              "id": "${m.docId}_expired_yesterday",
              "color": Colors.red,
              "icon": Icons.warning,
              "title": "Fees Expired",
              "subtitle": "${m.name} (Gym ID: ${m.gymId})",
              "time": "Yesterday • Expiry: ${m.expiryDate}",
              "phone": m.phone,
              "name": m.name,
              "gymId": m.gymId,
              "expiryDate": m.expiryDate,
            });
          } else {
            final daysLate = overdueDays - 1;
            if (daysLate >= 90) {
              newNotifications.add({
                "id": "${m.docId}_overdue_90plus",
                "color": Colors.grey,
                "icon": Icons.person_off,
                "title": "Admission Expired (3+ Mos Overdue)",
                "subtitle": "${m.name} (Gym ID: ${m.gymId})",
                "time": "Overdue: $daysLate days ago • Expiry: ${m.expiryDate}",
                "phone": m.phone,
                "name": m.name,
                "gymId": m.gymId,
                "expiryDate": m.expiryDate,
              });
            } else if (daysLate >= 60) {
              newNotifications.add({
                "id": "${m.docId}_overdue_60plus",
                "color": Colors.redAccent,
                "icon": Icons.payment,
                "title": "2 Months Fee Pending",
                "subtitle": "${m.name} (Gym ID: ${m.gymId})",
                "time": "Overdue: $daysLate days ago • Expiry: ${m.expiryDate}",
                "phone": m.phone,
                "name": m.name,
                "gymId": m.gymId,
                "expiryDate": m.expiryDate,
              });
            } else if (daysLate >= 30) {
              newNotifications.add({
                "id": "${m.docId}_overdue_30plus",
                "color": Colors.orange,
                "icon": Icons.payment,
                "title": "1 Month Fee Pending",
                "subtitle": "${m.name} (Gym ID: ${m.gymId})",
                "time": "Overdue: $daysLate days ago • Expiry: ${m.expiryDate}",
                "phone": m.phone,
                "name": m.name,
                "gymId": m.gymId,
                "expiryDate": m.expiryDate,
              });
            } else {
              newNotifications.add({
                "id": "${m.docId}_overdue_$daysLate",
                "color": Colors.orangeAccent,
                "icon": Icons.payment,
                "title": "Fee Payment Overdue",
                "subtitle": "${m.name} (Gym ID: ${m.gymId})",
                "time": "Overdue: $daysLate days ago • Expiry: ${m.expiryDate}",
                "phone": m.phone,
                "name": m.name,
                "gymId": m.gymId,
                "expiryDate": m.expiryDate,
              });
            }
          }
        }
      }
    }

    notifications.clear();
    notifications.addAll(newNotifications);
    notifyListeners();
  }

  @override
  void dispose() {
    _membersSubscription?.cancel();
    _paymentsSubscription?.cancel();
    _adminSubscription?.cancel();
    _authSubscription?.cancel();
    super.dispose();
  }
}
