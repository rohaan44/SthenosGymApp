import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import '../models/models.dart';
import 'package:intl/intl.dart';
// For web download
import 'package:universal_html/html.dart' as html;

// For mobile download/share
import 'dart:io' as io;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ExportService {
  static bool _isExporting = false;

  static Future<String?> exportPaymentsToExcel() async {
    if (_isExporting) {
      debugPrint('Export already in progress, ignoring duplicate call');
      return null;
    }
    _isExporting = true;

    try {
      final db = FirebaseFirestore.instance;

      // 1. Fetch all members and payments
      final membersSnap = await db.collection('members').get();
      final paymentsSnap = await db.collection('payments').get();

      final Map<String, Member> membersMap = {};
      for (var doc in membersSnap.docs) {
        membersMap[doc.id] = Member.fromFirestore(doc.data(), doc.id);
      }

      final payments = paymentsSnap.docs
          .map((doc) => Payment.fromFirestore(doc.data(), doc.id))
          .toList();

      payments.sort((a, b) {
        if (a.timestamp == null && b.timestamp == null) return 0;
        if (a.timestamp == null) return 1;
        if (b.timestamp == null) return -1;
        return b.timestamp!.compareTo(a.timestamp!);
      });

      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Payments Export'];
      excel.setDefaultSheet('Payments Export');

      sheetObject.appendRow([
        TextCellValue('Invoice ID'),
        TextCellValue('Member Name'),
        TextCellValue('Member ID (Gym ID)'),
        TextCellValue('Phone Number'),
        TextCellValue('Membership Plan'),
        TextCellValue('Payment Method'),
        TextCellValue('Amount (Rs)'),
        TextCellValue('Date Paid'),
        TextCellValue('Status'),
      ]);

      for (var payment in payments) {
        final member = membersMap[payment.memberId];
        final phone = member?.phone ?? 'N/A';
        final gymId = (member?.id ?? payment.gymId).toString();

        sheetObject.appendRow([
          TextCellValue(payment.invoiceId),
          TextCellValue(payment.member),
          TextCellValue(gymId),
          TextCellValue(phone),
          TextCellValue(payment.plan),
          TextCellValue(payment.method),
          DoubleCellValue(payment.amount),
          TextCellValue(payment.date),
          TextCellValue(payment.status),
        ]);
      }

      var fileBytes = excel.encode();
      if (fileBytes == null) {
        return "Failed to generate Excel file";
      }

      final fileName =
          'Payments_Export_${DateFormat('yyyy-MM-dd').format(DateTime.now())}.xlsx';

      if (kIsWeb) {
        final blob = html.Blob([Uint8List.fromList(fileBytes)]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute("download", fileName)
          ..style.display = 'none';
        html.document.body?.children.add(anchor);
        anchor.click();
        anchor.remove();
        html.Url.revokeObjectUrl(url);
      } else {
        final dir = await getApplicationDocumentsDirectory();
        final filePath = '${dir.path}/$fileName';
        final file = io.File(filePath);
        await file.writeAsBytes(fileBytes);

        await Share.shareXFiles([
          XFile(filePath),
        ], text: 'Exported Payments Data');
      }

      return null; // Success
    } catch (e) {
      debugPrint('Export error: $e');
      return "An error occurred while exporting data: $e";
    } finally {
      _isExporting = false;
    }
  }
}
