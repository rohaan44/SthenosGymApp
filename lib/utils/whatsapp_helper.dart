import 'package:flutter/foundation.dart';
import 'package:universal_html/html.dart' as html;

/// Formats a phone number for WhatsApp with international country code (defaults to Pakistan: +92).
String formatPhoneForWhatsApp(String phone) {
  String digits = phone.replaceAll(RegExp(r'\D'), '');
  if (digits.startsWith('0092')) {
    digits = '92${digits.substring(4)}';
  } else if (digits.startsWith('92')) {
    // Already in 92XXXXXXXXXX format
    return digits;
  } else if (digits.startsWith('0') && digits.length == 11) {
    // Local Pakistani format e.g. 03001234567 -> 923001234567
    digits = '92${digits.substring(1)}';
  } else if (digits.length == 10) {
    // 3001234567 -> 923001234567
    digits = '92$digits';
  }
  return digits;
}

/// Launches WhatsApp with the specified phone number and message.
///
/// Uses the universal `wa.me` Click-to-Chat standard, which works reliably across
/// all desktop and mobile browsers. Opening in a clean new tab (`_blank`) ensures
/// existing WhatsApp Web sessions are not disrupted or frozen into a blank screen.
void launchWhatsApp(String phone, String message) {
  final cleanPhone = formatPhoneForWhatsApp(phone);
  if (cleanPhone.isEmpty) return;

  String encodedMessage;
  try {
    encodedMessage = Uri.encodeComponent(Uri.decodeComponent(message));
  } catch (_) {
    encodedMessage = Uri.encodeComponent(message);
  }

  final url = "https://wa.me/$cleanPhone?text=$encodedMessage";

  if (kIsWeb) {
    html.window.open(url, '_blank');
  }
}

