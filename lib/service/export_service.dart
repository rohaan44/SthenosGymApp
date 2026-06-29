import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import '../models/models.dart';

// For web download
import 'package:universal_html/html.dart' as html;

// For mobile download/share
import 'dart:io' as io;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ExportService {
  static Future<String?> exportPaymentsToExcel() async {
    try {
      final db = FirebaseFirestore.instance;

      // 1. Fetch all members and payments
      final membersSnap = await db.collection('members').get();
      final paymentsSnap = await db.collection('payments').get();

      // Create a map for quick member lookup by document ID
      final Map<String, Member> membersMap = {};
      for (var doc in membersSnap.docs) {
        membersMap[doc.id] = Member.fromFirestore(doc.data(), doc.id);
      }

      // Map payments
      final payments = paymentsSnap.docs
          .map((doc) => Payment.fromFirestore(doc.data(), doc.id))
          .toList();

      // Sort payments by timestamp descending (or date)
      payments.sort((a, b) {
        if (a.timestamp == null && b.timestamp == null) return 0;
        if (a.timestamp == null) return 1;
        if (b.timestamp == null) return -1;
        return b.timestamp!.compareTo(a.timestamp!);
      });

      // 2. Generate Excel file
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Payments Export'];
      excel.setDefaultSheet('Payments Export');

      // Define header row
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

      // Populate data
      for (var payment in payments) {
        // Fallback to empty string if member not found (deleted)
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

      // Save file
      var fileBytes = excel.save();
      if (fileBytes == null) {
        return "Failed to generate Excel file";
      }

      final fileName = 'Payments_Export_${DateTime.now().millisecondsSinceEpoch}.xlsx';

      if (kIsWeb) {
        // Web Download
        final blob = html.Blob([Uint8List.fromList(fileBytes)]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute("download", fileName)
          ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        // Mobile Save & Share
        final dir = await getApplicationDocumentsDirectory();
        final filePath = '${dir.path}/$fileName';
        final file = io.File(filePath);
        await file.writeAsBytes(fileBytes);

        await Share.shareXFiles([XFile(filePath)], text: 'Exported Payments Data');
      }

      return null; // Success
    } catch (e) {
      debugPrint('Export error: $e');
      return "An error occurred while exporting data: $e";
    }
  }
}
