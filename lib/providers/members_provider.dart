import 'package:flutter/material.dart';
import '../models/models.dart';

class MembersProvider extends ChangeNotifier {
  final List<Member> _members = List.from(seedMembers);

  String _search = '';
  String _filterStatus = 'all';

  List<Member> get members => _members;
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

  List<Member> get filtered => _members.where((m) {
        final matchSearch = m.name.toLowerCase().contains(_search.toLowerCase()) ||
            m.email.toLowerCase().contains(_search.toLowerCase());
        final matchStatus =
            _filterStatus == 'all' || m.status.toLowerCase() == _filterStatus.toLowerCase();
        return matchSearch && matchStatus;
      }).toList();

  void addMember(Member member) {
    _members.add(member);
    notifyListeners();
  }

  void deleteMember(int id) {
    _members.removeWhere((m) => m.id == id);
    notifyListeners();
  }
}
