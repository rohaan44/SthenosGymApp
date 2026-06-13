import 'package:flutter/material.dart';
import '../models/models.dart';

class TrainersProvider extends ChangeNotifier {
  final List<Trainer> _trainers = List.from(seedTrainers);

  String _search = '';

  List<Trainer> get trainers => _trainers;
  String get search => _search;

  void setSearch(String value) {
    _search = value;
    notifyListeners();
  }

  List<Trainer> get filtered => _trainers
      .where(
        (t) =>
            t.name.toLowerCase().contains(_search.toLowerCase()) ||
            t.specialization.toLowerCase().contains(_search.toLowerCase()),
      )
      .toList();

  void addTrainer(Trainer trainer) {
    _trainers.add(trainer);
    notifyListeners();
  }

  void deleteTrainer(int id) {
    _trainers.removeWhere((t) => t.id == id);
    notifyListeners();
  }
}
