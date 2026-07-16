import 'package:flutter/material.dart';
import '../models/models.dart';
import '../service/firestore_service.dart';
import 'package:app/service/export_service.dart';
// import 'package:app/service/export_service.dart';

/// Holds only UI state for the Payments screen (search text + status filter).
/// All Firestore data arrives via [FirestoreService] snapshot streams.
class PaymentsProvider extends ChangeNotifier {
  String _search = '';
  String _filterStatus = 'all';
  bool _isExporting = false;
  String get search => _search;
  String get filterStatus => _filterStatus;

  TextEditingController searchTextFieldCntrl = TextEditingController();

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

  /// Applies the current search + status filter to a list of payments,
  /// keeping only the latest invoice for each member.
  List<Payment> filtered(List<Payment> payments) {
    // 1. First apply search and status filters
    final filteredList = payments.where((p) {
      final matchSearch =
          p.member.toLowerCase().contains(_search.toLowerCase()) ||
          p.invoiceId.toLowerCase().contains(_search.toLowerCase());
      final matchStatus =
          _filterStatus == 'all' ||
          p.status.toLowerCase() == _filterStatus.toLowerCase();
      return matchSearch && matchStatus;
    }).toList();

    // 2. Since payments is sorted descending by timestamp, the first payment
    // seen for each member is the latest. Filter the list to keep only that one.
    final seenMembers = <String>{};
    final uniquePayments = <Payment>[];
    for (final p in filteredList) {
      final key = p.memberId.isNotEmpty ? p.memberId : p.member;
      if (!seenMembers.contains(key)) {
        seenMembers.add(key);
        uniquePayments.add(p);
      }
    }

    return uniquePayments;
  }

  Future<String?> handleExport() async {
    if (_isExporting) return null; // guard against double taps

    _isExporting = true;
    notifyListeners();

    String? error;
    try {
      error = await ExportService.exportPaymentsToExcel();
    } catch (e) {
      error = e.toString();
    } finally {
      _isExporting = false;
      notifyListeners();
    }

    return error;
  }

  @override
  void dispose() {
    searchTextFieldCntrl.dispose();
    super.dispose();
  }
}
