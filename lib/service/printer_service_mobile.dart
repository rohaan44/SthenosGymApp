import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:typed_data';

class AppPrinter {
  static Future<void> printReceipt(Map<String, dynamic> memberData, double amount, String method) async {
    final printer = BlueThermalPrinter.instance;
    final isConnected = await printer.isConnected;

    if (isConnected != true) {
      final devices = await printer.getBondedDevices();
      if (devices.isNotEmpty) {
        try {
          // Connect to the first paired bluetooth printer
          await printer.connect(devices.first);
        } catch (e) {
          debugPrint('Could not connect to printer: $e');
          return;
        }
      } else {
        debugPrint('No bonded Bluetooth printers found.');
        return;
      }
    }

    // 1. Load the logo image
    Uint8List? logoBytes;
    try {
      final ByteData bytes = await rootBundle.load("assets/images/receipt_logo.png");
      logoBytes = bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
    } catch (e) {
      debugPrint("Error loading receipt logo asset: $e");
    }

    // 2. Format current date & time
    final now = DateTime.now();
    final formattedDate = "${now.month.toString().padLeft(2, '0')}/${now.day.toString().padLeft(2, '0')}/${now.year}";
    int displayHour = now.hour % 12;
    if (displayHour == 0) displayHour = 12;
    final period = now.hour >= 12 ? 'PM' : 'AM';
    final formattedTime = "${displayHour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')} $period";

    // 3. Format valid-thru date
    String expiryDate = memberData['expiryDate']?.toString() ?? '';
    if (expiryDate.contains('T')) {
      expiryDate = expiryDate.split('T')[0];
    }
    if (expiryDate.contains('-')) {
      final parts = expiryDate.split('-');
      if (parts.length == 3) {
        expiryDate = "${parts[1]}/${parts[2]}/${parts[0]}";
      }
    }

    // 4. Extract membership plan name
    final planRaw = memberData['membership']?.toString() ?? 'Monthly';
    final planName = planRaw.split('-')[0].trim().toUpperCase();
    final itemLine = "MEMBERSHIP $planName";

    // 5. Handle payment details
    String paymentType = method.toUpperCase();
    String? cardNum;
    if (paymentType.contains('CREDIT') || paymentType.contains('CARD')) {
      paymentType = 'VISA';
      cardNum = '****2222';
    }

    // 6. Print receipt
    printer.printNewLine();

    // Print Logo
    if (logoBytes != null) {
      try {
        await printer.printImageBytes(logoBytes);
      } catch (e) {
        debugPrint("Error printing image bytes: $e");
      }
    }

    printer.printCustom("STHENOS GYM", 2, 1);
    printer.printCustom("(555) 444-LIFT", 0, 1);
    printer.printNewLine();

    printer.printLeftRight("DATE: $formattedDate", "TIME: $formattedTime", 0);
    printer.printCustom("--------------------------------", 0, 1);

    printer.printCustom("MEMBER: ${memberData['name'] ?? ''}", 0, 1);
    printer.printCustom("MEMBER ID: ${memberData['gymId'] ?? ''}", 0, 1);
    printer.printCustom("MEMBERSHIP: ${memberData['membership'] ?? ''}", 0, 1);
    printer.printCustom("--------------------------------", 0, 1);

    printer.printLeftRight(itemLine, "Rs. ${amount.toStringAsFixed(2)}", 0);
    printer.printCustom("--------------------------------", 0, 1);

    printer.printLeftRight("TOTAL", "Rs. ${amount.toStringAsFixed(2)}", 1);

    printer.printLeftRight("PAYMENT", paymentType, 0);
    if (cardNum != null) {
      printer.printLeftRight("CARD #", cardNum, 0);
    }
    printer.printLeftRight("AMOUNT", "Rs. ${amount.toStringAsFixed(2)}", 0);
    printer.printNewLine();

    printer.printCustom("MEMBERSHIP VALID THRU: $expiryDate", 0, 1);
    printer.printNewLine();

    printer.printCustom("KEEP PUSHING YOUR LIMITS!", 0, 1);
    printer.printNewLine();
    printer.printNewLine();
    printer.paperCut();
  }
}
