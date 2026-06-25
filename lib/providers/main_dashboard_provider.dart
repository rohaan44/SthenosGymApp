// ─────────────────────────────────────────────────────────────────────────────
// Main scaffold with 3-tier responsive navigation
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';

class MainDashboardProvider extends ChangeNotifier {
  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;

  void setSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }
}
