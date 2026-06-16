import 'package:flutter/foundation.dart'; // kIsWeb ke liye lazmi hai
import 'package:sizer/sizer.dart';

class AppFontSize {
  AppFontSize._();

  // Helper method: Agar web/desktop hai to normal size, agar mobile app hai to .sp size
  static double _getResponsiveSize(double webSize, double mobileSpSize) {
    if (kIsWeb) {
      return webSize; // Web par exact font size chalega (No deformation on minimize)
    }
    return mobileSpSize.sp; // Mobile apps par aap ka puraana logic
  }

  // ── Multi-platform Font Sizes ─────────────────────────────────────────────
  static double floatingLabel = _getResponsiveSize(16.0, 14.6);

  static double f40 = _getResponsiveSize(40.0, 32.0);
  static double f32 = _getResponsiveSize(32.0, 26.5);
  static double f30 = _getResponsiveSize(30.0, 25.0);
  static double f28 = _getResponsiveSize(28.0, 22.5);
  static double f27 = _getResponsiveSize(27.0, 18.0);
  static double f26 = _getResponsiveSize(26.0, 20.5);

  static double f24 = _getResponsiveSize(24.0, 21.0);
  static double f22 = _getResponsiveSize(22.0, 18.0);

  static double f20 = _getResponsiveSize(20.0, 17.5);
  static double f19 = _getResponsiveSize(19.0, 16.0);
  static double f18 = _getResponsiveSize(18.0, 14.5);
  static double f17 = _getResponsiveSize(17.0, 11.3);

  static double f16 = _getResponsiveSize(16.0, 12.5);
  static double f15 = _getResponsiveSize(15.0, 10.0);
  static double f14 = _getResponsiveSize(14.0, 11.0);
  static double f13 = _getResponsiveSize(13.0, 10.2);
  static double f12 = _getResponsiveSize(12.0, 9.0);
  static double f11 = _getResponsiveSize(11.0, 8.5);
  static double f10 = _getResponsiveSize(10.0, 8.0);
  static double f9 = _getResponsiveSize(9.0, 7.5);
  static double f8 = _getResponsiveSize(8.0, 5.0);
}
