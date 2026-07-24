// ─────────────────────────────────────────────────────────────────────────────
// Main scaffold with 3-tier responsive navigation
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';

class MainDashboardProvider extends ChangeNotifier {
  // final GlobalKey notificationKey = GlobalKey();
  // OverlayEntry? notificationOverlay;

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

  setCount() {
    _visibleCount += 10;
    notifyListeners();
  }

  final List notifications = [
    {
      "color": Colors.amber,
      "icon": Icons.schedule,
      "title": "Membership expires in 3 days",
      "subtitle": "Ahmed Ali",
      "time": "Today",
    },
    {
      "color": Colors.red,
      "icon": Icons.warning,
      "title": "Membership expired today",
      "subtitle": "Ali Khan",
      "time": "Today",
    },
    {
      "color": Colors.orange,
      "icon": Icons.payment,
      "title": "1 Month Fee Pending",
      "subtitle": "Salman",
      "time": "Yesterday",
    },
    {
      "color": Colors.grey,
      "icon": Icons.person_off,
      "title": "Admission Expired",
      "subtitle": "Huzaifa",
      "time": "15 Jul",
    },

    /// Testing (20 items)
    ...List.generate(
      8,
      (index) => {
        "color": Colors.amber,
        "icon": Icons.schedule,
        "title": "Membership expires in 3 days",
        "subtitle": "Member ${index + 5}",
        "time": "Today",
      },
    ),
  ];

  @override
  void dispose() {
    super.dispose();
  }
}
