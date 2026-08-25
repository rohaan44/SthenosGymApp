import 'package:flutter_test/flutter_test.dart';
import 'package:app/utils/payment_status_calculator.dart';

void main() {
  group('PaymentStatusCalculator Tests', () {
    test('Practical example from real data', () {
      const dateStr = '2026-07-07';
      const planStr = 'Monthly - Rs. 3000 / month';

      // paymentDate = 2026-07-07
      // cycleDuration = 1 month -> nextDueDate = 2026-08-07
      // pendingDate = 2026-08-05
      // overdueDate = 2026-08-09

      expect(
        PaymentStatusCalculator.calculateStatus(
          dateStr,
          planStr,
          nowForTesting: DateTime(2026, 8, 4),
        ),
        'Paid',
      );

      expect(
        PaymentStatusCalculator.calculateStatus(
          dateStr,
          planStr,
          nowForTesting: DateTime(2026, 8, 5),
        ),
        'Pending',
      );

      expect(
        PaymentStatusCalculator.calculateStatus(
          dateStr,
          planStr,
          nowForTesting: DateTime(2026, 8, 7),
        ),
        'Pending',
      );

      expect(
        PaymentStatusCalculator.calculateStatus(
          dateStr,
          planStr,
          nowForTesting: DateTime(2026, 8, 9),
        ),
        'Overdue',
      );

      expect(
        PaymentStatusCalculator.calculateStatus(
          dateStr,
          planStr,
          nowForTesting: DateTime(2026, 8, 10),
        ),
        'Overdue',
      );
    });

    test('Plan parsing - Monthly, Quarterly, Half Yearly, Yearly', () {
      expect(
        PaymentStatusCalculator.parsePlanMonths('Monthly - Rs. 3000 / month'),
        1,
      );
      expect(
        PaymentStatusCalculator.parsePlanMonths(
          'Quarterly - Rs. 7500 / 3 months',
        ),
        3,
      );
      expect(
        PaymentStatusCalculator.parsePlanMonths(
          'Half Yearly - Rs. 13000 / 6 months',
        ),
        6,
      );
      expect(
        PaymentStatusCalculator.parsePlanMonths('Yearly - Rs. 24000 / year'),
        12,
      );
    });

    test('Duration parser helper', () {
      expect(
        parsePlanDuration('Monthly - Rs. 3000 / month'),
        const Duration(days: 30),
      );
      expect(
        parsePlanDuration('Quarterly - Rs. 7500 / 3 months'),
        const Duration(days: 90),
      );
      expect(
        parsePlanDuration('Half Yearly - Rs. 13000 / 6 months'),
        const Duration(days: 183),
      );
      expect(
        parsePlanDuration('Yearly - Rs. 24000 / year'),
        const Duration(days: 365),
      );
    });

    test('Quarterly plan status calculation', () {
      const dateStr = '2026-01-15';
      const planStr = 'Quarterly - Rs. 7500 / 3 months';

      // paymentDate = 2026-01-15
      // nextDueDate = 2026-04-15
      // pendingDate = 2026-04-13
      // overdueDate = 2026-04-17

      expect(
        PaymentStatusCalculator.calculateStatus(
          dateStr,
          planStr,
          nowForTesting: DateTime(2026, 4, 12),
        ),
        'Paid',
      );

      expect(
        PaymentStatusCalculator.calculateStatus(
          dateStr,
          planStr,
          nowForTesting: DateTime(2026, 4, 14),
        ),
        'Pending',
      );

      expect(
        PaymentStatusCalculator.calculateStatus(
          dateStr,
          planStr,
          nowForTesting: DateTime(2026, 4, 18),
        ),
        'Overdue',
      );
    });

    test('Yearly plan status calculation', () {
      const dateStr = '2026-01-01';
      const planStr = 'Yearly - Rs. 24000 / year';

      // paymentDate = 2026-01-01
      // nextDueDate = 2027-01-01
      // pendingDate = 2026-12-30
      // overdueDate = 2027-01-03

      expect(
        PaymentStatusCalculator.calculateStatus(
          dateStr,
          planStr,
          nowForTesting: DateTime(2026, 12, 29),
        ),
        'Paid',
      );

      expect(
        PaymentStatusCalculator.calculateStatus(
          dateStr,
          planStr,
          nowForTesting: DateTime(2026, 12, 31),
        ),
        'Pending',
      );

      expect(
        PaymentStatusCalculator.calculateStatus(
          dateStr,
          planStr,
          nowForTesting: DateTime(2027, 1, 4),
        ),
        'Overdue',
      );
    });

    test('Month-boundary edge cases (Jan 31 + 1 month = Feb 28/29)', () {
      // Non-leap year 2026
      final jan312026 = DateTime(2026, 1, 31);
      final nextFeb2026 = PaymentStatusCalculator.addMonths(jan312026, 1);
      expect(nextFeb2026, DateTime(2026, 2, 28));

      // Leap year 2028
      final jan312028 = DateTime(2028, 1, 31);
      final nextFeb2028 = PaymentStatusCalculator.addMonths(jan312028, 1);
      expect(nextFeb2028, DateTime(2028, 2, 29));

      // 6 months addition: July 31, 2026 + 6 months = Jan 31, 2027
      final jul312026 = DateTime(2026, 7, 31);
      final nextJan2027 = PaymentStatusCalculator.addMonths(jul312026, 6);
      expect(nextJan2027, DateTime(2027, 1, 31));
    });

    test('Edge case handling - null/empty/invalid date', () {
      expect(
        PaymentStatusCalculator.calculateStatus(
          null,
          'Monthly - Rs. 3000 / month',
        ),
        'Overdue',
      );
      expect(
        PaymentStatusCalculator.calculateStatus(
          '',
          'Monthly - Rs. 3000 / month',
        ),
        'Overdue',
      );
      expect(
        PaymentStatusCalculator.calculateStatus(
          'invalid-date-format',
          'Monthly - Rs. 3000 / month',
        ),
        'Overdue',
      );
    });

    test('Edge case handling - null/empty/unrecognized plan', () {
      expect(PaymentStatusCalculator.parsePlanMonths(null), 1);
      expect(PaymentStatusCalculator.parsePlanMonths(''), 1);
      expect(
        PaymentStatusCalculator.parsePlanMonths('Unrecognized Custom Plan'),
        1,
      );
    });

    test('Top-level calculatePaymentStatus pure function', () {
      expect(
        calculatePaymentStatus('2026-07-07', 'Monthly - Rs. 3000 / month'),
        isA<String>(),
      );
    });
  });
}
