import 'package:flutter/foundation.dart'; // kIsWeb ke liye lazmi hai
import 'package:sizer/sizer.dart';

class AppFontSize {
  AppFontSize._();

  // Helper method: Agar web/desktop hai to normal size, agar mobile app hai to .sp size
  static double _getResponsiveSize(double webSize, double mobileSpSize) {
    if (kIsWeb) {
      // If the browser frame width is small (e.g. mobile view), use mobile responsive font sizes
      if (100.w < 600) {
        return mobileSpSize.sp;
      }
      return webSize; // Web par exact font size chalega
    }
    return mobileSpSize.sp; // Mobile apps par responsive logic
  }

  // ── Multi-platform Font Sizes (Dynamic Getters) ────────────────────────────
  static double get floatingLabel => _getResponsiveSize(16.0, 14.6);

  static double get f40 => _getResponsiveSize(40.0, 32.0);
  static double get f32 => _getResponsiveSize(32.0, 26.5);
  static double get f30 => _getResponsiveSize(30.0, 25.0);
  static double get f28 => _getResponsiveSize(28.0, 22.5);
  static double get f27 => _getResponsiveSize(27.0, 18.0);
  static double get f26 => _getResponsiveSize(26.0, 20.5);

  static double get f24 => _getResponsiveSize(24.0, 21.0);
  static double get f22 => _getResponsiveSize(22.0, 18.0);

  static double get f20 => _getResponsiveSize(20.0, 17.5);
  static double get f19 => _getResponsiveSize(19.0, 16.0);
  static double get f18 => _getResponsiveSize(18.0, 14.5);
  static double get f17 => _getResponsiveSize(17.0, 11.3);

  static double get f16 => _getResponsiveSize(16.0, 12.5);
  static double get f15 => _getResponsiveSize(15.0, 14.0);
  static double get f14 => _getResponsiveSize(14.0, 11.0);
  static double get f13 => _getResponsiveSize(13.0, 10.2);
  static double get f12 => _getResponsiveSize(12.0, 9.0);
  static double get f11 => _getResponsiveSize(11.0, 8.5);
  static double get f10 => _getResponsiveSize(10.0, 8.0);
  static double get f9 => _getResponsiveSize(9.0, 7.5);
  static double get f8 => _getResponsiveSize(8.0, 5.0);
}
