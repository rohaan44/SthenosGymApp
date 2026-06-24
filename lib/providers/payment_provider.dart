import 'package:flutter/material.dart';
import '../models/models.dart';
import '../service/firestore_service.dart';

/// Holds only UI state for the Payments screen (search text + status filter).
/// All Firestore data arrives via [FirestoreService] snapshot streams.
class PaymentsProvider extends ChangeNotifier {
  String _search = '';
  String _filterStatus = 'all';

  String get search => _search;
  String get filterStatus => _filterStatus;

  /// Live stream of ALL payments, newest first.
  Stream<List<Payment>> get paymentsStream =>
      FirestoreService.instance.paymentsStream();

  /// Live stream of payments for a specific member (scoped by Firestore doc ID).
  Stream<List<Payment>> memberPaymentsStream(String memberDocId) =>
      FirestoreService.instance.memberPaymentsStream(memberDocId);

  void setSearch(String value) {
    _search = value;
    notifyListeners();
  }

  void setFilterStatus(String value) {
    _filterStatus = value;
    notifyListeners();
  }

  /// Applies the current search + status filter to a list of payments.
  List<Payment> filtered(List<Payment> payments) => payments.where((p) {
        final matchSearch =
            p.member.toLowerCase().contains(_search.toLowerCase()) ||
                p.invoiceId.toLowerCase().contains(_search.toLowerCase());
        final matchStatus = _filterStatus == 'all' ||
            p.status.toLowerCase() == _filterStatus.toLowerCase();
        return matchSearch && matchStatus;
      }).toList();
}
