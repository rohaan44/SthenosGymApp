import 'package:flutter/material.dart';
import '../models/models.dart';

class AttendanceProvider extends ChangeNotifier {
  final List<AttendanceRecord> _attendance = List.from(seedAttendance);

  String _search = '';
  String _filterStatus = 'all';

  List<AttendanceRecord> get attendance => _attendance;
  String get search => _search;
  String get filterStatus => _filterStatus;

  void setSearch(String value) {
    _search = value;
    notifyListeners();
  }

  void setFilterStatus(String value) {
    _filterStatus = value;
    notifyListeners();
  }

  List<AttendanceRecord> get filtered =>
      _attendance.where((r) {
        final matchSearch =
            r.member.toLowerCase().contains(_search.toLowerCase()) ||
            r.className.toLowerCase().contains(_search.toLowerCase());
        final matchStatus =
            _filterStatus == 'all' ||
            r.status.toLowerCase() == _filterStatus.toLowerCase();
        return matchSearch && matchStatus;
      }).toList();
}
