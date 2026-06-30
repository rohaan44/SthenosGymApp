import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/models.dart';

/// Central Firestore service — all streams and writes for Members & Payments.
/// Screens use StreamBuilder directly with these streams; no polling required.
class FirestoreService {
  FirestoreService._();
  static final FirestoreService instance = FirestoreService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─────────────────────────────────────────────────────────────────────────
  // MEMBER WRITES
  // ─────────────────────────────────────────────────────────────────────────

  /// Deletes a member document from Firestore.
  /// Returns `null` on success, or an error message string.
  Future<String?> deleteMember(String docId) async {
    try {
      await _db.collection('members').doc(docId).delete();
      return null;
    } catch (e) {
      debugPrint('FirestoreService.deleteMember error: $e');
      return 'Failed to delete member: $e';
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // STREAMS
  // ─────────────────────────────────────────────────────────────────────────

  /// Live stream of all members, newest join date first.
  /// Every Firestore write (add/update) triggers a new event — no refresh needed.
  Stream<List<Member>> membersStream() {
    return _db
        .collection('members')
        .orderBy('joinDate', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => Member.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }

  /// Live stream of ALL payments, newest timestamp first.
  Stream<List<Payment>> paymentsStream() {
    return _db
        .collection('payments')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => Payment.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }

  /// Live stream of payments scoped to a single member's Firestore doc ID,
  /// newest first. Used for per-member payment history and cycle checks.
  ///
  /// NOTE: orderBy is intentionally done client-side to avoid requiring a
  /// Firestore composite index on (memberId + timestamp).
  Stream<List<Payment>> memberPaymentsStream(String memberDocId) {
    return _db
        .collection('payments')
        .where('memberId', isEqualTo: memberDocId)
        .snapshots()
        .map((snap) {
          final list = snap.docs
              .map((doc) => Payment.fromFirestore(doc.data(), doc.id))
              .toList();

          // Sort by timestamp descending (newest first) — client-side,
          // no composite index needed.
          list.sort((a, b) {
            final ta = a.timestamp;
            final tb = b.timestamp;
            if (ta == null && tb == null) return 0;
            if (ta == null) return 1;  // nulls go to end
            if (tb == null) return -1;
            return tb.compareTo(ta); // descending
          });

          return list;
        });
  }

  // ─────────────────────────────────────────────────────────────────────────
  // CYCLE HELPERS
  // ─────────────────────────────────────────────────────────────────────────

  /// Parses a "YYYY-MM-DD" string to a date-only [DateTime] (midnight UTC).
  /// Returns [DateTime.now()] if parsing fails — callers should handle this.
  static DateTime _parseDate(String dateStr) {
    try {
      return DateTime.parse(dateStr);
    } catch (_) {
      return DateTime.now();
    }
  }

  /// Computes the [start, end] of the member's current billing cycle.
  ///
  /// Rule:
  ///   - cycleEnd   = member.expiryDate  (the last day the current payment covers).
  ///   - cycleStart = cycleEnd − period
  ///       • "Monthly"          → − 1 month
  ///       • "Quarterly"        → − 3 months  (confirmed: 90-day fee-free window)
  ///       • "Yearly" / "Annual Plan" → − 1 year
  ///       • anything else      → − 1 month  (fail-safe)
  ///
  /// All comparisons are date-only (no time component) to avoid timezone
  /// off-by-one bugs when the app is used across midnight.
  static ({DateTime start, DateTime end}) currentCycleWindow(
    String expiryDateStr,
    String? billingFrequency,
  ) {
    final cycleEnd = _parseDate(expiryDateStr);

    DateTime cycleStart;
    final freq = (billingFrequency ?? '').toLowerCase();

    if (freq.contains('yearly') || freq.contains('annual')) {
      // Annual plan: cycle is exactly 1 year long.
      cycleStart = DateTime(cycleEnd.year - 1, cycleEnd.month, cycleEnd.day);
    } else if (freq.contains('quarterly') || freq.contains('3-month')) {
      // Quarterly plan: 3-month (≈90 day) window confirmed by user.
      cycleStart = DateTime(cycleEnd.year, cycleEnd.month - 3, cycleEnd.day);
    } else {
      // Monthly (default / fail-safe): 1 month window.
      cycleStart = DateTime(cycleEnd.year, cycleEnd.month - 1, cycleEnd.day);
    }

    return (start: cycleStart, end: cycleEnd);
  }

  /// Returns `true` if the member MAY pay now (no Paid payment exists
  /// within the current cycle window OR the current calendar period).
  ///
  /// Two-layer guard:
  ///   1. Calendar-period check — for monthly: same year+month; for quarterly:
  ///      same year+quarter; for yearly: same year. This is the primary check
  ///      and catches the case where expiryDate is stale in the passed Member.
  ///   2. Cycle-window check (legacy) — [expiryDate − period, expiryDate].
  ///      Kept as a fallback for edge cases (e.g. mid-cycle plan change).
  ///
  /// Returns false (= block) if EITHER check finds an existing paid payment.
  static bool canPayThisCycle(Member member, List<Payment> payments) {
    final now = DateTime.now();

    final freq = (member.billingFrequency ?? '').toLowerCase();
    final isYearly = freq.contains('yearly') || freq.contains('annual');
    final isQuarterly = freq.contains('quarterly') || freq.contains('3-month');

    // ── Layer 1: Calendar-period guard ───────────────────────────────────────
    // Blocks if ANY Paid payment falls in the same calendar period as today.
    for (final p in payments) {
      if (p.status != 'Paid') continue;
      if (p.date.isEmpty) continue;

      final payDate = _parseDate(p.date);

      if (isYearly) {
        // Same calendar year
        if (payDate.year == now.year) return false;
      } else if (isQuarterly) {
        // Same calendar quarter (Jan-Mar, Apr-Jun, Jul-Sep, Oct-Dec)
        final sameYear = payDate.year == now.year;
        final sameQuarter = ((payDate.month - 1) ~/ 3) == ((now.month - 1) ~/ 3);
        if (sameYear && sameQuarter) return false;
      } else {
        // Monthly (default): same year + same month
        if (payDate.year == now.year && payDate.month == now.month) return false;
      }
    }

    // ── Layer 2: Cycle-window guard (fallback) ────────────────────────────────
    if (member.expiryDate.isEmpty) return true;

    final window = currentCycleWindow(member.expiryDate, member.billingFrequency);

    for (final p in payments) {
      if (p.status != 'Paid') continue;
      if (p.date.isEmpty) continue;

      final payDate = _parseDate(p.date);

      // Check: cycleStart <= payDate <= cycleEnd (all date-only comparisons)
      final afterOrOnStart = !payDate.isBefore(
        DateTime(window.start.year, window.start.month, window.start.day),
      );
      final beforeOrOnEnd = !payDate.isAfter(
        DateTime(window.end.year, window.end.month, window.end.day),
      );

      if (afterOrOnStart && beforeOrOnEnd) {
        return false; // a paid payment already exists in this cycle
      }
    }
    return true;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // OVERDUE HELPERS
  // ─────────────────────────────────────────────────────────────────────────

  /// Returns `true` if the member is overdue RIGHT NOW.
  ///
  /// Overdue = today (date-only) is strictly after expiryDate
  ///           AND no Paid payment exists in the current cycle.
  ///
  /// This is a client-side derived value. It is recomputed on every
  /// StreamBuilder rebuild, so the status badge changes the moment:
  ///   • the date rolls past expiryDate (if the app is open), OR
  ///   • a new Paid payment arrives via snapshot.
  ///
  /// Note: For members who are not using the app, the persisted `status`
  /// field in Firestore will only be updated by a Cloud Function (follow-up).
  /// While the app IS open, this computed value takes precedence.
  static bool isOverdue(Member member, List<Payment> memberPayments) {
    if (member.expiryDate.isEmpty) return false;

    // Date-only comparison — strip time to avoid timezone off-by-one.
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final expiry = _parseDate(member.expiryDate);
    final expiryDate = DateTime(expiry.year, expiry.month, expiry.day);

    if (!todayDate.isAfter(expiryDate)) return false; // not yet expired

    // Expired — check if a Paid payment covers this cycle.
    return canPayThisCycle(member, memberPayments);
    // canPayThisCycle returns true when no paid payment exists → overdue.
    // canPayThisCycle returns false when paid payment exists → NOT overdue.
  }

  /// Returns the effective display status for a member.
  ///
  /// Priority:
  ///   1. If [isOverdue] → "Overdue" (computed, overrides stored value).
  ///   2. Otherwise → use the stored `member.status` from Firestore.
  static String effectiveStatus(Member member, List<Payment> memberPayments) {
    if (isOverdue(member, memberPayments)) return 'Overdue';
    return member.status;
  }

  /// Lightweight overdue check using only expiryDate (no payments needed).
  /// Used in the Members list where loading per-member payments would cause N+1.
  static bool isOverdueByDate(Member member) {
    if (member.expiryDate.isEmpty) return false;
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final expiry = _parseDate(member.expiryDate);
    final expiryDate = DateTime(expiry.year, expiry.month, expiry.day);
    return todayDate.isAfter(expiryDate);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // WRITES
  // ─────────────────────────────────────────────────────────────────────────

  /// Processes a payment for a member.
  ///
  /// Returns `null` on success, or an error/block message string.
  ///
  /// Flow:
  ///   1. Re-query the member's payments to get the freshest data.
  ///   2. Run [canPayThisCycle] — if false, return a user-facing block message.
  ///   3. Write a new payment doc to `payments`.
  ///   4. Recompute expiryDate (shift one period forward from current cycleEnd).
  ///   5. Update `members` doc: lastPaymentDate, expiryDate, status = "Active".
  Future<String?> processPayment({
    required Member member,
    required String method,
    required double amount,
    String? paymentDocIdToUpdate,
  }) async {
    try {
      // 1. Fresh payment query to catch concurrent payments (e.g. another device).
      final snap = await _db
          .collection('payments')
          .where('memberId', isEqualTo: member.docId)
          .get();
      final latestPayments = snap.docs
          .map((doc) => Payment.fromFirestore(doc.data(), doc.id))
          .toList();

      // 2. Cycle guard.
      if (!canPayThisCycle(member, latestPayments)) {
        final now = DateTime.now();
        final monthName = [
          '', 'January', 'February', 'March', 'April', 'May', 'June',
          'July', 'August', 'September', 'October', 'November', 'December'
        ][now.month];
        return 'Payment already collected for $monthName ${now.year}. Next due: ${member.expiryDate}';
      }

      final now = DateTime.now();
      final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final invoiceId = 'INV-${now.millisecondsSinceEpoch.toString().substring(5)}';

      final batch = _db.batch();

      String? targetDocId = paymentDocIdToUpdate;

      if (targetDocId == null) {
        // If not explicitly provided, look for an existing Overdue or Pending payment to update
        // (sort so we overwrite the most recent unpaid one first)
        final sortedPayments = List<Payment>.from(latestPayments);
        sortedPayments.sort((a, b) => b.timestamp?.compareTo(a.timestamp ?? DateTime(0)) ?? 0);
        for (final p in sortedPayments) {
          if (p.status == 'Overdue' || p.status == 'Pending') {
            targetDocId = p.docId;
            break;
          }
        }
      }

      if (targetDocId != null) {
        // Update existing invoice instead of creating a duplicate
        final docRef = _db.collection('payments').doc(targetDocId);
        batch.update(docRef, {
          'amount': amount,
          'method': method,
          'status': 'Paid',
          'date': dateStr, // updated to today's date
        });
      } else {
        // Create new invoice
        final newPaymentRef = _db.collection('payments').doc();
        batch.set(newPaymentRef, {
          'gymId': member.id.toString(),
          'memberId': member.docId,
          'member': member.name,
          'plan': member.membership,
          'amount': amount,
          'method': method,
          'status': 'Paid',
          'date': dateStr,
          'invoiceId': invoiceId,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }

      // 4. Compute new expiryDate = current cycleEnd + 1 period.
      final newExpiry = _nextExpiryDate(member.expiryDate, member.billingFrequency);

      // 5. Update member doc.
      final memberRef = _db.collection('members').doc(member.docId);
      batch.update(memberRef, {
        'lastPaymentDate': dateStr,
        'expiryDate': newExpiry,
        'status': 'Active',
      });

      await batch.commit();

      return null; // success
    } catch (e) {
      debugPrint('FirestoreService.processPayment error: $e');
      return 'Payment failed. Please try again.';
    }
  }

  /// Updates a payment's status field in Firestore.
  ///
  /// If [newStatus] is "Paid" and [member] is provided, also re-runs the
  /// cycle recompute (expiryDate / lastPaymentDate / member status) so
  /// admin-corrected payments behave identically to app-made ones.
  ///
  /// Returns `null` on success, or an error message string.
  Future<String?> updatePaymentStatus({
    required String paymentDocId,
    required String newStatus,
    required String paymentDate, // the payment's own date field
    Member? member,
  }) async {
    try {
      final batch = _db.batch();
      final paymentRef = _db.collection('payments').doc(paymentDocId);

      batch.update(paymentRef, {
        'status': newStatus,
      });

      // If admin corrects a payment to "Paid", recompute the member's cycle.
      if (newStatus == 'Paid' && member != null) {
        final dateStr = paymentDate.isNotEmpty
            ? paymentDate
            : DateTime.now().toIso8601String().split('T')[0];
        final newExpiry = _nextExpiryDate(
          member.expiryDate,
          member.billingFrequency,
        );
        final memberRef = _db.collection('members').doc(member.docId);
        batch.update(memberRef, {
          'lastPaymentDate': dateStr,
          'expiryDate': newExpiry,
          'status': 'Active',
        });
      }

      await batch.commit();

      return null;
    } catch (e) {
      debugPrint('FirestoreService.updatePaymentStatus error: $e');
      return 'Failed to update status. Please try again.';
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // PRIVATE HELPERS
  // ─────────────────────────────────────────────────────────────────────────

  /// Computes the next expiryDate by advancing the current cycleEnd by one
  /// billing period.
  ///
  ///   Monthly   → +1 month
  ///   Quarterly → +3 months
  ///   Yearly    → +1 year
  ///   Fallback  → +1 month
  ///
  /// Returns "YYYY-MM-DD" string.
  static String _nextExpiryDate(String currentExpiry, String? billingFrequency) {
    final current = _parseDate(currentExpiry);
    final freq = (billingFrequency ?? '').toLowerCase();

    DateTime next;
    if (freq.contains('yearly') || freq.contains('annual')) {
      next = DateTime(current.year + 1, current.month, current.day);
    } else if (freq.contains('quarterly') || freq.contains('3-month')) {
      next = DateTime(current.year, current.month + 3, current.day);
    } else {
      // Monthly (default)
      next = DateTime(current.year, current.month + 1, current.day);
    }

    return '${next.year}-${next.month.toString().padLeft(2, '0')}-${next.day.toString().padLeft(2, '0')}';
  }
}
