import 'package:app/ui/helpers/color_helper.dart';
import 'package:app/ui/helpers/font_size_helper.dart';
import 'package:app/ui/utils/app_gradient.dart';
import 'package:app/ui/utils/app_text.dart';
import 'package:flutter/material.dart';
import '../ui/helpers/app_layout_helper.dart';

InputDecoration customInputDecoration({
  String? label,
  Color? filledColor,

  Widget? preFixIcon,
}) => InputDecoration(
  prefixIcon: preFixIcon,
  labelText: label,
  labelStyle: TextStyle(
    color: AppColor.cFFFFFF,
    fontSize: AppFontSize.f14,
    fontWeight: FontWeight.w400,
  ),

  hintStyle: TextStyle(
    color: AppColor.cFFFFFF,
    fontSize: AppFontSize.f14,
    fontWeight: FontWeight.w400,
  ),

  filled: true,
  fillColor: filledColor ?? AppColor.c151515,

  isDense: false,

  contentPadding: EdgeInsets.symmetric(horizontal: cw(8), vertical: ch(15)),

  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: const BorderSide(color: AppColor.c252525, width: 1),
  ),

  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: const BorderSide(color: AppColor.c252525, width: 1),
  ),

  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: const BorderSide(color: AppColor.white, width: 1),
  ),

  errorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: const BorderSide(color: Colors.red, width: 1),
  ),

  focusedErrorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: const BorderSide(color: Colors.red, width: 1),
  ),
);
TextField customTf(
  String label,
  TextEditingController ctrl, {
  TextInputType? type,
}) => TextField(
  controller: ctrl,
  keyboardType: type,
  decoration: customInputDecoration(label: label),
);

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final Map<String, (Gradient, Color)> gradients = {
      // Success
      "Active": (AppGradients.redGradient, AppColor.cFFFFFF),
      "Paid": (AppGradients.redGradient, AppColor.cFFFFFF),
      "Present": (AppGradients.redGradient, AppColor.cFFFFFF),

      // Warning
      "Pending": (
        const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)]),
        Colors.white,
      ),

      "Late": (
        const LinearGradient(colors: [Color(0xFFFF8A00), Color(0xFFFFC107)]),
        Colors.white,
      ),

      // Error
      "Expired": (
        const LinearGradient(colors: [Color(0xFFDC2626), Color(0xFFF43F5E)]),
        Colors.white,
      ),

      "Overdue": (
        const LinearGradient(colors: [Color(0xFF991B1B), Color(0xFFEF4444)]),
        Colors.white,
      ),

      "Absent": (
        const LinearGradient(colors: [Color(0xFFB91C1C), Color(0xFFFB7185)]),
        Colors.white,
      ),

      // Neutral
      "Full": (
        const LinearGradient(colors: [Color(0xFF475569), Color(0xFF64748B)]),
        Colors.white,
      ),
    };

    final data = gradients[status];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: data?.$1,
        color: data == null ? const Color(0xFFF3F4F6) : null,
      ),
      child: AppText(
        txt: status,
        fontWeight: FontWeight.w600,
        fontSize: AppFontSize.f12,
        color: data?.$2 ?? const Color(0xFF6B7280),
      ),
    );
  }
}
// class StatusBadge extends StatelessWidget {
//   const StatusBadge({super.key, required this.status});

//   final String status;

//   @override
//   Widget build(BuildContext context) {
//     final bool isGradient =
//         status == "Active" || status == "Paid" || status == "Present";

//     final colors = {
//       'Pending': (const Color(0xFFFFFBEB), const Color(0xFFD97706)),
//       'Expired': (const Color(0xFFFEF2F2), const Color(0xFFDC2626)),
//       'Overdue': (const Color(0xFFFEF2F2), const Color(0xFFDC2626)),
//       'Absent': (const Color(0xFFFEF2F2), const Color(0xFFDC2626)),
//       'Late': (const Color(0xFFFFFBEB), const Color(0xFFD97706)),
//       'Full': (const Color(0xFFFEF2F2), const Color(0xFFDC2626)),
//     };

//     final pair =
//         colors[status] ?? (const Color(0xFFF3F4F6), const Color(0xFF6B7280));

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(30),
//         color: isGradient ? null : pair.$1,
//         gradient: isGradient ? AppGradients.redGradient : null,
//       ),
//       child: AppText(
//         txt: status,
//         fontWeight: FontWeight.w600,
//         fontSize: AppFontSize.f12,
//         color: isGradient ? AppColor.cFFFFFF : pair.$2,
//       ),
//     );
//   }
// }

// class StatusBadge extends StatelessWidget {
//   const StatusBadge({super.key, required this.status});
//   final String status;

//   @override
//   Widget build(BuildContext context) {
//     final colors = {
//       'Active': (AppColor.primary, AppColor.cFFFFFF),
//       'Pending': (const Color(0xFFFFFBEB), const Color(0xFFD97706)),
//       'Expired': (const Color(0xFFFEF2F2), const Color(0xFFDC2626)),
//       'Paid': (AppColor.primary, AppColor.cFFFFFF),
//       'Overdue': (const Color(0xFFFEF2F2), const Color(0xFFDC2626)),
//       'Present': (AppColor.primary, AppColor.cFFFFFF),
//       'Absent': (const Color(0xFFFEF2F2), const Color(0xFFDC2626)),
//       'Late': (const Color(0xFFFFFBEB), const Color(0xFFD97706)),
//       'Full': (const Color(0xFFFEF2F2), const Color(0xFFDC2626)),
//     };
//     final pair =
//         colors[status] ?? (const Color(0xFFF3F4F6), const Color(0xFF6B7280));
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: cw(7.5), vertical: ch(3.2)),
//       decoration: BoxDecoration(
//         color: pair.$1,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: AppText(
//         txt: status,
//         fontWeight: FontWeight.w500,
//         fontSize: AppFontSize.f12,
//         color: pair.$2,
//       ),
//     );
//   }
// }
