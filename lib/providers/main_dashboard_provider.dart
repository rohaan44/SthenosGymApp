import 'dart:async';
import 'package:app/models/models.dart';
import 'package:app/service/firestore_service.dart';
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

  final List notifications = [];

  StreamSubscription<List<Member>>? _membersSubscription;
  StreamSubscription<List<Payment>>? _paymentsSubscription;

  List<Member> _members = [];
  List<Payment> _payments = [];

  void initNotificationsListener() {
    _membersSubscription?.cancel();
    _paymentsSubscription?.cancel();

    _membersSubscription = FirestoreService.instance.membersStream().listen((membersList) {
      _members = membersList;
      _rebuildNotifications();
    });

    _paymentsSubscription = FirestoreService.instance.paymentsStream().listen((paymentsList) {
      _payments = paymentsList;
      _rebuildNotifications();
    });
  }

  void _rebuildNotifications() {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    final List newNotifications = [];

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
          "color": Colors.red,
          "icon": Icons.warning,
          "title": "Membership expired today",
          "subtitle": m.name,
          "time": "Today",
          "phone": m.phone,
        });
      } else if (diffInDays == 3) {
        newNotifications.add({
          "color": Colors.amber,
          "icon": Icons.schedule,
          "title": "Membership expires in 3 days",
          "subtitle": m.name,
          "time": "In 3 days",
          "phone": m.phone,
        });
      } else if (diffInDays == 1 || diffInDays == 2) {
        newNotifications.add({
          "color": Colors.amber.shade300,
          "icon": Icons.schedule,
          "title": "Fee due soon",
          "subtitle": m.name,
          "time": "In $diffInDays day${diffInDays > 1 ? 's' : ''}",
          "phone": m.phone,
        });
      } else if (diffInDays < 0) {
        final isOverdue = FirestoreService.isOverdue(m, memberPayments);
        if (isOverdue) {
          final overdueDays = todayDate.difference(expiryDate).inDays;
          if (overdueDays == 1) {
            newNotifications.add({
              "color": Colors.red,
              "icon": Icons.warning,
              "title": "Fees Expired",
              "subtitle": m.name,
              "time": "Yesterday",
              "phone": m.phone,
            });
          } else {
            final daysLate = overdueDays - 1;
            if (daysLate >= 90) {
              newNotifications.add({
                "color": Colors.grey,
                "icon": Icons.person_off,
                "title": "Admission Expired (3+ Mos Overdue)",
                "subtitle": m.name,
                "time": "Overdue: $daysLate day${daysLate > 1 ? 's' : ''} ago",
                "phone": m.phone,
              });
            } else if (daysLate >= 60) {
              newNotifications.add({
                "color": Colors.redAccent,
                "icon": Icons.payment,
                "title": "2 Months Fee Pending",
                "subtitle": m.name,
                "time": "Overdue: $daysLate day${daysLate > 1 ? 's' : ''} ago",
                "phone": m.phone,
              });
            } else if (daysLate >= 30) {
              newNotifications.add({
                "color": Colors.orange,
                "icon": Icons.payment,
                "title": "1 Month Fee Pending",
                "subtitle": m.name,
                "time": "Overdue: $daysLate day${daysLate > 1 ? 's' : ''} ago",
                "phone": m.phone,
              });
            } else {
              newNotifications.add({
                "color": Colors.orangeAccent,
                "icon": Icons.payment,
                "title": "Fee Payment Overdue",
                "subtitle": m.name,
                "time": "Overdue: $daysLate day${daysLate > 1 ? 's' : ''} ago",
                "phone": m.phone,
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
    super.dispose();
  }
}

