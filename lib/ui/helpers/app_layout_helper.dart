import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

// ── Breakpoints ────────────────────────────────────────────────
const double kPhoneBreak = 600;
const double kDesktopBreak = 1024;

// ── Tier helpers ───────────────────────────────────────────────
bool isPhone(BuildContext context) =>
    MediaQuery.of(context).size.width < kPhoneBreak;
bool isTablet(BuildContext context) =>
    MediaQuery.of(context).size.width >= kPhoneBreak &&
    MediaQuery.of(context).size.width < kDesktopBreak;
bool isDesktop(BuildContext context) =>
    MediaQuery.of(context).size.width >= kDesktopBreak;

/// Returns the current screen width.
double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;

// ── Responsive padding ─────────────────────────────────────────
/// Screen-aware page padding: 4 w on phone, 3 w on tablet, 2.5 w on desktop
EdgeInsets pagePadding(BuildContext context) {
  if (isDesktop(context)) return EdgeInsets.all(cw(9.4));
  if (isTablet(context)) return EdgeInsets.all(cw(11.2));
  return EdgeInsets.all(cw(15.0));
}

/// Horizontal padding variant (keeps vertical as-is at 2%)
EdgeInsets pageHPadding(BuildContext context) {
  if (isDesktop(context))
    return EdgeInsets.symmetric(horizontal: cw(9.4), vertical: ch(8.1));
  if (isTablet(context))
    return EdgeInsets.symmetric(horizontal: cw(11.2), vertical: ch(8.1));
  return EdgeInsets.symmetric(horizontal: cw(15.0), vertical: ch(8.1));
}

// ── Responsive grid helpers ────────────────────────────────────
/// Stat-card grid columns: 2 phone, 2 tablet, 4 desktop
int statGridCols(BuildContext context) => isDesktop(context) ? 4 : 2;

/// Content grid columns: 1 phone, 2 tablet, 3 desktop
int contentGridCols(BuildContext context) {
  if (isDesktop(context)) return 3;
  if (isTablet(context)) return 2;
  return 1;
}

String capitalizeFirstLetter(String text) {
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1);
}

// ── Legacy pixel-to-sizer helpers (kept for compatibility) ─────
double cw(double width) => ((width / 375) * 100).w;
double ch(double height) => ((height / 812) * 100).h;
