import 'package:flutter/foundation.dart';

/// Pure Dart calculator and helper utility for dynamic payment status calculations.
class PaymentStatusCalculator {
  PaymentStatusCalculator._();

  /// Calculates the real-time payment status ("Paid", "Pending", or "Overdue").
  ///
  /// Takes [paymentDateStr] (string "YYYY-MM-DD") and [plan] string.
  /// An optional [nowForTesting] parameter can be passed for unit testing.
  static String calculateStatus(
    String? paymentDateStr,
    String? plan, {
    DateTime? nowForTesting,
  }) {
    // Edge case 1: date is null or empty -> log warning and return Overdue safe default
    if (paymentDateStr == null || paymentDateStr.trim().isEmpty) {
      debugPrint(
        'PaymentStatusCalculator Warning: payment date is null or empty. Defaulting status to "Overdue".',
      );
      return 'Overdue';
    }

    // Edge case 3: date parsing error handling
    DateTime paymentDate;
    try {
      paymentDate = DateTime.parse(paymentDateStr.trim());
    } on FormatException catch (e) {
      debugPrint(
        'PaymentStatusCalculator Warning: Invalid date format "$paymentDateStr" ($e). Defaulting status to "Overdue".',
      );
      return 'Overdue';
    } catch (e) {
      debugPrint(
        'PaymentStatusCalculator Warning: Failed to parse date "$paymentDateStr" ($e). Defaulting status to "Overdue".',
      );
      return 'Overdue';
    }

    // Date-only comparison (strip time component)
    paymentDate = DateTime(
      paymentDate.year,
      paymentDate.month,
      paymentDate.day,
    );

    // Step 1: Parse plan duration in months
    final months = parsePlanMonths(plan);

    // Step 2: Calculate key dates using DateTime(y, m+n, d) for month boundaries
    final nextDueDate = addMonths(paymentDate, months);
    final pendingDate = nextDueDate.subtract(const Duration(days: 2));
    final overdueDate = nextDueDate.add(const Duration(days: 2));

    // Step 3: Determine status based on today's date (date-only)
    final now = nowForTesting ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final pDate = DateTime(
      pendingDate.year,
      pendingDate.month,
      pendingDate.day,
    );
    final oDate = DateTime(
      overdueDate.year,
      overdueDate.month,
      overdueDate.day,
    );

    if (today.isBefore(pDate)) {
      return 'Paid';
    } else if (today.isBefore(oDate)) {
      return 'Pending';
    } else {
      return 'Overdue';
    }
  }

  /// Parses cycle duration in months based on plan keywords.
  /// Handled keywords:
  ///   - "Half" / "Half Yearly" -> 6 months
  ///   - "Yearly" / "Year" -> 12 months
  ///   - "Quarterly" / "3 Month" -> 3 months
  ///   - "Monthly" / "Month" -> 1 month
  /// Default fallback: 1 month cycle + warning log for unrecognized/null plans.
  static int parsePlanMonths(String? plan) {
    if (plan == null || plan.trim().isEmpty) {
      debugPrint(
        'PaymentStatusCalculator Warning: plan string is null or empty. Defaulting to 1 month cycle.',
      );
      return 1;
    }

    final lower = plan.toLowerCase();
    if (lower.contains('half')) {
      return 6;
    } else if (lower.contains('yearly') || lower.contains('year')) {
      return 12;
    } else if (lower.contains('quarterly') || lower.contains('3 month')) {
      return 3;
    } else if (lower.contains('monthly') || lower.contains('month')) {
      return 1;
    }

    debugPrint(
      'PaymentStatusCalculator Warning: Unrecognized plan string "$plan". Defaulting to 1 month cycle.',
    );
    return 1;
  }

  /// Parses plan duration into a [Duration] object as specified by helper spec.
  static Duration parsePlanDuration(String? plan) {
    final months = parsePlanMonths(plan);
    if (months == 12) return const Duration(days: 365);
    if (months == 6) return const Duration(days: 183);
    if (months == 3) return const Duration(days: 90);
    return const Duration(days: 30);
  }

  /// Adds [months] to [date] handling month boundary edge cases with day clamping.
  /// E.g. paying on Jan 31 + 1 month results in Feb 28 (or Feb 29 in leap year).
  static DateTime addMonths(DateTime date, int months) {
    var year = date.year;
    var month = date.month + months;

    year += (month - 1) ~/ 12;
    month = ((month - 1) % 12) + 1;

    // Last day of target month (DateTime(year, month + 1, 0) gives last day of 'month')
    final daysInTargetMonth = DateTime(year, month + 1, 0).day;
    final day = date.day > daysInTargetMonth ? daysInTargetMonth : date.day;

    return DateTime(year, month, day);
  }
}

/// Pure Dart utility function for calculatePaymentStatus (Option A)
String calculatePaymentStatus(String paymentDateStr, String plan) {
  return PaymentStatusCalculator.calculateStatus(paymentDateStr, plan);
}

/// Helper function to parse plan duration as specified in prompt
Duration parsePlanDuration(String plan) {
  return PaymentStatusCalculator.parsePlanDuration(plan);
}
