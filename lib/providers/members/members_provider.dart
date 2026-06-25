import 'package:flutter/material.dart';
import '../../service/firestore_service.dart';

/// Holds only UI state for the Members screen (search text + filter).
/// All Firestore data arrives via [FirestoreService.membersStream] —
/// no local cache, no .get() calls.
class MembersProvider extends ChangeNotifier {
  String _search = '';
  String _filterStatus = 'all';

  String get search => _search;
  String get filterStatus => _filterStatus;

  /// Live stream of members from Firestore, ordered by joinDate descending.
  /// Bind a StreamBuilder directly to this in the Members screen.
  Stream<dynamic> get membersStream =>
      FirestoreService.instance.membersStream();

  Map<String, dynamic> memberData = {};

  void setMemberData(Map<String, dynamic> data) {
    memberData = data;
    notifyListeners();
  }

  void setSearch(String value) {
    _search = value;
    notifyListeners();
  }

  void setFilterStatus(String value) {
    _filterStatus = value;
    notifyListeners();
  }
}
