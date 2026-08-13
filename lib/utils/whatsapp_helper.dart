import 'package:flutter/foundation.dart';
import 'package:universal_html/html.dart' as html;

html.WindowBase? _whatsappWindow;

/// Launches WhatsApp with the specified phone number and message.
///
/// On mobile browsers, it launches using the standard `wa.me` redirect link
/// to open the native WhatsApp mobile application.
/// On desktop browsers, it directly targets WhatsApp Web (`web.whatsapp.com`)
/// and maintains a window reference to reuse the same browser tab across
/// multiple reminders.
void launchWhatsApp(String phone, String message) {
  final userAgent = kIsWeb ? html.window.navigator.userAgent.toLowerCase() : '';
  final isMobile =
      !kIsWeb ||
      userAgent.contains('mobi') ||
      userAgent.contains('android') ||
      userAgent.contains('iphone');

  if (isMobile) {
    final url = "https://wa.me/$phone?text=$message";
    html.window.open(url, '_blank');
  } else {
    final url = "https://web.whatsapp.com/send?phone=$phone&text=$message";

    // Check if the previous tab reference is still open and active
    if (_whatsappWindow != null && _whatsappWindow!.closed == false) {
      dynamic win = _whatsappWindow;
      try {
        // Set the location cross-origin (setting win.location to a string is allowed in JS)
        win.location = url;
      } catch (e) {
        // Fallback to window.open if browser prevents direct location write
        _whatsappWindow = html.window.open(url, 'whatsapp_web');
      }
      try {
        win.focus();
      } catch (_) {}
    } else {
      _whatsappWindow = html.window.open(url, 'whatsapp_web');
    }
  }
}
