// import 'package:app/ui/utils/app_text.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../models/models.dart';
// import '../providers/gym_provider.dart';
// import '../shared_widgets.dart';
// import '../ui/helpers/app_layout_helper.dart';
// import 'package:app/ui/helpers/font_size_helper.dart';

// class AttendanceState extends ChangeNotifier {
//   String _search = '';
//   String _filterStatus = 'all';

//   String get search => _search;
//   String get filterStatus => _filterStatus;

//   void setSearch(String value) {
//     _search = value;
//     notifyListeners();
//   }

//   void setFilterStatus(String value) {
//     _filterStatus = value;
//     notifyListeners();
//   }

//   List<AttendanceRecord> filtered(List<AttendanceRecord> records) =>
//       records.where((r) {
//         final matchSearch =
//             r.member.toLowerCase().contains(_search.toLowerCase()) ||
//             r.className.toLowerCase().contains(_search.toLowerCase());
//         final matchStatus =
//             _filterStatus == 'all' ||
//             r.status.toLowerCase() == _filterStatus.toLowerCase();
//         return matchSearch && matchStatus;
//       }).toList();
// }

// class AttendanceScreen extends StatelessWidget {
//   const AttendanceScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//       create: (_) => AttendanceState(),
//       child: Builder(
//         builder: (context) {
//           final phone = isPhone(context);


//     return Scaffold(
//       backgroundColor: const Color(0xFFF9FAFB),
//       body: SingleChildScrollView(
//         padding: pagePadding(context),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             SizedBox(height: ch(8.1)),
//             AppText(
//               txt: 'Attendance',
//               fontSize: AppFontSize.f22,
//               fontWeight: FontWeight.w500,
//               color: const Color(0xFF111827),
//           return Scaffold(
//             backgroundColor: const Color(0xFFF9FAFB),
//             body: SingleChildScrollView(
//               padding: pagePadding(context),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   SizedBox(height: ch(8.1)),
//                   AppText(
//                     txt: 'Attendance',
//                     fontSize: AppFontSize.f22,
//                     fontWeight: FontWeight.w500,
//                     color: const Color(0xFF111827),
//                   ),
//                   SizedBox(height: ch(10)),
//                   AppText(
//                     txt: 'Track member class attendance',
//                     fontSize: AppFontSize.f14,
//                     color: const Color(0xFF6B7280),
//                   ),
//                   SizedBox(height: ch(20.3)),
//                   Consumer<AttendanceState>(
//                     builder: (context, state, child) {
//                       final provider = context.watch<GymProvider>();
//                       final records = provider.attendance;
//                       final filtered = state.filtered(records);
//                       final present = records.where((r) => r.status.toLowerCase() == 'present').length;
//                       final absent = records.where((r) => r.status.toLowerCase() == 'absent').length;
//                       final late = records.where((r) => r.status.toLowerCase() == 'late').length;
//                       final rate = records.isEmpty ? 0.0 : (present / records.length) * 100;

//                       return Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // ── Stat cards ────────────────────────────────────────────────────
//                           LayoutBuilder(
//                             builder: (context, constraints) {
//                               final crossAxis = constraints.maxWidth > 600 ? 4 : 2;
//                               final aspectRatio = constraints.maxWidth > 600 ? 1.6 : 1.4;
//                               return GridView.count(
//                                 crossAxisCount: crossAxis,
//                                 shrinkWrap: true,
//                                 physics: const NeverScrollableScrollPhysics(),
//                                 crossAxisSpacing: cw(7.5),
//                                 mainAxisSpacing: ch(12.2),
//                                 childAspectRatio: aspectRatio,
//                                 children: [
//                                   _StatCard(
//                                     label: 'Present',
//                                     value: '$present',
//                                     color: const Color(0xFF059669),
//                                     bg: const Color(0xFFECFDF5),
//                                     icon: Icons.check_circle_outline,
//                                   ),
//                                   _StatCard(
//                                     label: 'Absent',
//                                     value: '$absent',
//                                     color: const Color(0xFFDC2626),
//                                     bg: const Color(0xFFFEF2F2),
//                                     icon: Icons.cancel_outlined,
//                                   ),
//                                   _StatCard(
//                                     label: 'Late',
//                                     value: '$late',
//                                     color: const Color(0xFFD97706),
//                                     bg: const Color(0xFFFFFBEB),
//                                     icon: Icons.access_time_outlined,
//                                   ),
//                                   _StatCard(
//                                     label: 'Rate',
//                                     value: '${rate.toStringAsFixed(0)}%',
//                                     color: const Color(0xFF2563EB),
//                                     bg: const Color(0xFFEFF6FF),
//                                     icon: Icons.trending_up,
//                                   ),
//                                 ],
//                               );
//                             },
//                           ),

//                           SizedBox(height: ch(16.2)),

//                           // ── Filters ───────────────────────────────────────────────────────
//                           Card(
//                             child: Padding(
//                               padding: EdgeInsets.all(cw(11.2)),
//                               child: phone
//                                   ? Column(
//                                       children: [
//                                         TextField(
//                                           decoration: customInputDecoration(
//                                             label: 'Search member or class...',
//                                           ).copyWith(
//                                             prefixIcon: const Icon(
//                                               Icons.search,
//                                               size: 18,
//                                               color: Color(0xFF9CA3AF),
//                                             ),
//                                           ),
//                                           onChanged: (v) => state.setSearch(v),
//                                         ),
//                                         SizedBox(height: ch(9.7)),
//                                         DropdownButtonFormField<String>(
//                                           value: state.filterStatus,
//                                           isExpanded: true,
//                                           decoration: customInputDecoration(label: 'Status'),
//                                           items: const [
//                                             DropdownMenuItem(value: 'all', child: AppText(txt: 'All Status')),
//                                             DropdownMenuItem(value: 'present', child: AppText(txt: 'Present')),
//                                             DropdownMenuItem(value: 'absent', child: AppText(txt: 'Absent')),
//                                             DropdownMenuItem(value: 'late', child: AppText(txt: 'Late')),
//                                           ],
//                                           onChanged: (v) => state.setFilterStatus(v!),
//                                         ),
//                                       ],
//                                     )
//                                   : Row(
//                                       children: [
//                                         Expanded(
//                                           child: TextField(
//                                             decoration: customInputDecoration(
//                                               label: 'Search member or class...',
//                                             ).copyWith(
//                                               prefixIcon: const Icon(
//                                                 Icons.search,
//                                                 size: 18,
//                                                 color: Color(0xFF9CA3AF),
//                                               ),
//                                             ),
//                                             onChanged: (v) => state.setSearch(v),
//                                           ),
//                                         ),
//                                         SizedBox(width: cw(7.5)),
//                                         SizedBox(
//                                           width: cw(50),
//                                           child: DropdownButtonFormField<String>(
//                                             value: state.filterStatus,
//                                             decoration: customInputDecoration(label: 'Status'),
//                                             items: const [
//                                               DropdownMenuItem(value: 'all', child: AppText(txt: 'All Status', fontSize: 13)),
//                                               DropdownMenuItem(value: 'present', child: AppText(txt: 'Present', fontSize: 13)),
//                                               DropdownMenuItem(value: 'absent', child: AppText(txt: 'Absent', fontSize: 13)),
//                                               DropdownMenuItem(value: 'late', child: AppText(txt: 'Late', fontSize: 13)),
//                                             ],
//                                             onChanged: (v) => state.setFilterStatus(v!),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                             ),
//                           ),

//                           SizedBox(height: ch(12.2)),

//                           // ── Records ───────────────────────────────────────────────────────
//                           Card(
//                             child: Padding(
//                               padding: EdgeInsets.all(cw(11.2)),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   AppText(
//                                     txt: 'Attendance Records (${filtered.length})',
//                                     fontSize: AppFontSize.f13,
//                                     fontWeight: FontWeight.w600,
//                                     color: const Color(0xFF111827),
//                                   ),
//                                   SizedBox(height: ch(12.2)),
//                                   phone
//                                       ? _MobileAttendanceList(records: filtered)
//                                       : SingleChildScrollView(
//                                           scrollDirection: Axis.horizontal,
//                                           child: DataTable(
//                                             headingRowColor: WidgetStateProperty.all(const Color(0xFFF9FAFB)),
//                                             columns: const [
//                                               DataColumn(label: AppText(txt: 'Member', fontSize: 12, color: Color(0xFF6B7280))),
//                                               DataColumn(label: AppText(txt: 'Class', fontSize: 12, color: Color(0xFF6B7280))),
//                                               DataColumn(label: AppText(txt: 'Trainer', fontSize: 12, color: Color(0xFF6B7280))),
//                                               DataColumn(label: AppText(txt: 'Date', fontSize: 12, color: Color(0xFF6B7280))),
//                                               DataColumn(label: AppText(txt: 'Check In', fontSize: 12, color: Color(0xFF6B7280))),
//                                               DataColumn(label: AppText(txt: 'Check Out', fontSize: 12, color: Color(0xFF6B7280))),
//                                               DataColumn(label: AppText(txt: 'Status', fontSize: 12, color: Color(0xFF6B7280))),
//                                             ],
//                                             rows: filtered.map((r) => DataRow(cells: [
//                                               DataCell(AppText(txt: r.member, fontSize: 12, color: const Color(0xFF6B7280))),
//                                               DataCell(AppText(txt: r.className, fontSize: 12, color: const Color(0xFF6B7280))),
//                                               DataCell(AppText(txt: r.trainer, fontSize: 12, color: const Color(0xFF6B7280))),
//                                               DataCell(AppText(txt: r.date, fontSize: 12, color: const Color(0xFF6B7280))),
//                                               DataCell(AppText(txt: r.checkIn, fontSize: 12, color: const Color(0xFF6B7280))),
//                                               DataCell(AppText(txt: r.checkOut, fontSize: 12, color: const Color(0xFF6B7280))),
//                                               DataCell(StatusBadge(status: r.status)),
//                                             ])).toList(),
//                                           ),
//                                         ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                           SizedBox(height: ch(16.2)),
//                         ],
//                       );
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────────────────────
// // Mobile card list
// // ─────────────────────────────────────────────────────────────────────────────
// class _MobileAttendanceList extends StatelessWidget {
//   const _MobileAttendanceList({required this.records});
//   final List<AttendanceRecord> records;

//   @override
//   Widget build(BuildContext context) {
//     if (records.isEmpty) {
//       return Center(
//         child: Padding(
//           padding: EdgeInsets.all(cw(15.0)),
//           child: AppText(
//             txt: 'No records found',
//             fontSize: AppFontSize.f15,
//             color: const Color(0xFF6B7280),
//           ),
//         ),
//       );
//     }
//     return Column(
//       children: records
//           .map(
//             (r) => Container(
//               margin: EdgeInsets.only(bottom: ch(9.7)),
//               padding: EdgeInsets.all(cw(11.2)),
//               decoration: BoxDecoration(
//                 border: Border.all(color: const Color(0xFFE5E7EB)),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       AppText(
//                         txt: r.member,
//                         fontSize: AppFontSize.f15,
//                         color: const Color(0xFF6B7280),
//                       ),
//                       StatusBadge(status: r.status),
//                     ],
//                   ),
//                   SizedBox(height: ch(4.9)),
//                   AppText(
//                     txt: r.className,
//                     fontSize: AppFontSize.f12,
//                     color: const Color(0xFF6B7280),
//                   ),
//                   SizedBox(height: ch(6.5)),
//                   Row(
//                     children: [
//                       _pill(Icons.person_outline, r.trainer),
//                       SizedBox(width: cw(7.5)),
//                       _pill(Icons.calendar_today_outlined, r.date),
//                     ],
//                   ),
//                   SizedBox(height: ch(4.9)),
//                   Row(
//                     children: [
//                       _pill(Icons.login_outlined, r.checkIn),
//                       SizedBox(width: cw(7.5)),
//                       _pill(Icons.logout_outlined, r.checkOut),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           )
//           .toList(),
//     );
//   }

//   Widget _pill(IconData icon, String text) => Row(
//     mainAxisSize: MainAxisSize.min,
//     children: [
//       Icon(icon, size: 12, color: const Color(0xFF9CA3AF)),
//       const SizedBox(width: 4),
//       AppText(txt: text, fontSize: AppFontSize.f11, color: Color(0xFF6B7280)),
//     ],
//   );
// }

// // ─────────────────────────────────────────────────────────────────────────────
// class _StatCard extends StatelessWidget {
//   const _StatCard({
//     required this.label,
//     required this.value,
//     required this.color,
//     required this.bg,
//     required this.icon,
//   });
//   final String label, value;
//   final Color color, bg;
//   final IconData icon;

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       child: Padding(
//         padding: EdgeInsets.all(cw(11.2)),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 AppText(
//                   txt: label,
//                   fontSize: AppFontSize.f13,
//                   color: Color(0xFF6B7280),
//                 ),
//                 Container(
//                   padding: EdgeInsets.all(cw(5.6)),
//                   decoration: BoxDecoration(
//                     color: bg,
//                     borderRadius: BorderRadius.circular(6),
//                   ),
//                   child: Icon(
//                     icon,
//                     size: cw(9.4).clamp(12.0, 18.0),
//                     color: color,
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: ch(8.1)),
//             AppText(
//               txt: value,
//               fontSize: AppFontSize.f18,
//               fontWeight: FontWeight.w700,
//               color: color,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
