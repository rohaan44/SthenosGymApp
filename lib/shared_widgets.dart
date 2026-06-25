import 'package:app/ui/helpers/font_size_helper.dart';
import 'package:app/ui/utils/app_text.dart';
import 'package:flutter/material.dart';
import '../ui/helpers/app_layout_helper.dart';

InputDecoration customInputDecoration(String label) => InputDecoration(
  labelText: label,
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: const BorderSide(color: Color(0xFF2563EB)),
  ),
  contentPadding: EdgeInsets.symmetric(horizontal: cw(11.2), vertical: ch(9.7)),
  isDense: true,
);

TextField customTf(
  String label,
  TextEditingController ctrl, {
  TextInputType? type,
}) => TextField(
  controller: ctrl,
  keyboardType: type,
  decoration: customInputDecoration(label),
);

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final colors = {
      'Active': (const Color(0xFFECFDF5), const Color(0xFF059669)),
      'Pending': (const Color(0xFFFFFBEB), const Color(0xFFD97706)),
      'Expired': (const Color(0xFFFEF2F2), const Color(0xFFDC2626)),
      'Paid': (const Color(0xFFECFDF5), const Color(0xFF059669)),
      'Overdue': (const Color(0xFFFEF2F2), const Color(0xFFDC2626)),
      'Present': (const Color(0xFFECFDF5), const Color(0xFF059669)),
      'Absent': (const Color(0xFFFEF2F2), const Color(0xFFDC2626)),
      'Late': (const Color(0xFFFFFBEB), const Color(0xFFD97706)),
      'Full': (const Color(0xFFFEF2F2), const Color(0xFFDC2626)),
    };
    final pair =
        colors[status] ?? (const Color(0xFFF3F4F6), const Color(0xFF6B7280));
    return Container(
      padding: EdgeInsets.symmetric(horizontal: cw(7.5), vertical: ch(3.2)),
      decoration: BoxDecoration(
        color: pair.$1,
        borderRadius: BorderRadius.circular(12),
      ),
      child: AppText(
        txt: status,
        fontWeight: FontWeight.w500,
        fontSize: AppFontSize.f12,
        color: pair.$2,
      ),
    );
  }
}
