import 'package:flutter/material.dart';
import '../models/models.dart';

class GymProvider extends ChangeNotifier {
  final List<Member> _members = List.from(seedMembers);
  final List<GymClass> _classes = List.from(seedClasses);
  final List<Trainer> _trainers = List.from(seedTrainers);
  final List<AttendanceRecord> _attendance = List.from(seedAttendance);
  final List<Payment> _payments = List.from(seedPayments);

  List<Member> get members => _members;
  List<GymClass> get classes => _classes;
  List<Trainer> get trainers => _trainers;
  List<AttendanceRecord> get attendance => _attendance;
  List<Payment> get payments => _payments;

  // Add more mutation methods here as needed
  void addPayment(Payment payment) {
    _payments.insert(0, payment);
    notifyListeners();
  }

  void addMember(Member member) {
    _members.add(member);
    notifyListeners();
  }

  void deleteMember(int id) {
    _members.removeWhere((m) => m.id == id);
    notifyListeners();
  }

  void addClass(GymClass gymClass) {
    _classes.add(gymClass);
    notifyListeners();
  }

  void addTrainer(Trainer trainer) {
    _trainers.add(trainer);
    notifyListeners();
  }

  void deleteTrainer(int id) {
    _trainers.removeWhere((t) => t.id == id);
    notifyListeners();
  }
}
