import 'package:flutter/material.dart';
import '../models/models.dart';

class ClassesProvider extends ChangeNotifier {
  final List<GymClass> _classes = List.from(seedClasses);

  String _search = '';
  String _filterCategory = 'all';

  List<GymClass> get classes => _classes;
  String get search => _search;
  String get filterCategory => _filterCategory;

  void setSearch(String value) {
    _search = value;
    notifyListeners();
  }

  void setFilterCategory(String value) {
    _filterCategory = value;
    notifyListeners();
  }

  List<String> get categories =>
      ['all', ...{..._classes.map((c) => c.category)}];

  List<GymClass> get filtered => _classes.where((c) {
        final matchSearch = c.name.toLowerCase().contains(_search.toLowerCase()) ||
            c.trainer.toLowerCase().contains(_search.toLowerCase());
        final matchCat = _filterCategory == 'all' || c.category == _filterCategory;
        return matchSearch && matchCat;
      }).toList();

  void addClass(GymClass gymClass) {
    _classes.add(gymClass);
    notifyListeners();
  }
}
