// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../providers/gym_provider.dart';
// import '../shared_widgets.dart';
// import '../ui/helpers/app_layout_helper.dart';
// import 'package:app/ui/helpers/font_size_helper.dart';

// class DashboardScreen extends StatelessWidget {
//   const DashboardScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final provider = context.watch<GymProvider>();
//     final activeMembers = provider.members
//         .where((m) => m.status == 'Active')
//         .length;
//     final totalRevenue = provider.payments
//         .where((p) => p.status == 'Paid')
//         .fold(0.0, (s, p) => s + p.amount);
//     final todayPresent = provider.attendance
//         .where((a) => a.status == 'Present')
//         .length;

//     return Scaffold(
//       backgroundColor: const Color(0xFFF9FAFB),
//       body: SingleChildScrollView(
//         padding: pagePadding(context),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             SizedBox(height: ch(8.1)),
//             Text(
//               'Dashboard',
//               style: TextStyle(
//                 fontSize: AppFontSize.f19,
//                 fontWeight: FontWeight.w600,
//                 color: const Color(0xFF111827),
//               ),
//             ),
//             SizedBox(height: ch(4.1)),
//             Text(
//               "Welcome back! Here's what's happening today.",
//               style: TextStyle(
//                 fontSize: AppFontSize.f12,
//                 color: const Color(0xFF6B7280),
//               ),
//             ),
//             SizedBox(height: ch(20.3)),

//             // ── Stat cards ──────────────────────────────────────────────────
//             LayoutBuilder(
//               builder: (context, constraints) {
//                 final crossAxis = constraints.maxWidth > 600 ? 4 : 2;
//                 final aspectRatio = constraints.maxWidth > 600 ? 1.5 : 1.3;
//                 return GridView.count(
//                   crossAxisCount: crossAxis,
//                   shrinkWrap: true,
//                   physics: const NeverScrollableScrollPhysics(),
//                   crossAxisSpacing: cw(7.5),
//                   mainAxisSpacing: ch(12.2),
//                   childAspectRatio: aspectRatio,
//                   children: [
//                     _StatCard(
//                       title: 'Active Members',
//                       value: '$activeMembers',
//                       subtitle: 'of ${provider.members.length} total',
//                       icon: Icons.people,
//                       iconColor: const Color(0xFF2563EB),
//                       iconBg: const Color(0xFFEFF6FF),
//                     ),
//                     _StatCard(
//                       title: 'Classes Today',
//                       value: '${provider.classes.length}',
//                       subtitle:
//                           '${provider.classes.where((c) => c.status == "Full").length} full',
//                       icon: Icons.calendar_today,
//                       iconColor: const Color(0xFF7C3AED),
//                       iconBg: const Color(0xFFF5F3FF),
//                     ),
//                     _StatCard(
//                       title: 'Attendance',
//                       value: '$todayPresent',
//                       subtitle: 'present today',
//                       icon: Icons.fact_check,
//                       iconColor: const Color(0xFF059669),
//                       iconBg: const Color(0xFFECFDF5),
//                     ),
//                     _StatCard(
//                       title: 'Revenue',
//                       value: '\$${totalRevenue.toInt()}',
//                       subtitle: 'this month',
//                       icon: Icons.attach_money,
//                       iconColor: const Color(0xFFD97706),
//                       iconBg: const Color(0xFFFFFBEB),
//                     ),
//                   ],
//                 );
//               },
//             ),

//             SizedBox(height: ch(20.3)),

//             // ── Recent members & class schedule ────────────────────────────
//             LayoutBuilder(
//               builder: (context, constraints) {
//                 if (constraints.maxWidth > 700) {
//                   return Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Expanded(child: _RecentMembersCard()),
//                       SizedBox(width: cw(7.5)),
//                       Expanded(child: _ClassScheduleCard()),
//                     ],
//                   );
//                 }
//                 return Column(
//                   children: [
//                     _RecentMembersCard(),
//                     SizedBox(height: ch(12.2)),
//                     _ClassScheduleCard(),
//                   ],
//                 );
//               },
//             ),

//             SizedBox(height: ch(12.2)),
//             _PaymentStatusCard(),
//             SizedBox(height: ch(16.2)),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────────────────────
// class _StatCard extends StatelessWidget {
//   const _StatCard({
//     required this.title,
//     required this.value,
//     required this.subtitle,
//     required this.icon,
//     required this.iconColor,
//     required this.iconBg,
//   });
//   final String title, value, subtitle;
//   final IconData icon;
//   final Color iconColor, iconBg;

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       child: Padding(
//         padding: EdgeInsets.all(cw(11.2)),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Expanded(
//                   child: Text(
//                     title,
//                     style: TextStyle(
//                       fontSize: AppFontSize.f11,
//                       color: const Color(0xFF6B7280),
//                     ),
//                   ),
//                 ),
//                 Container(
//                   padding: EdgeInsets.all(cw(5.6)),
//                   decoration: BoxDecoration(
//                     color: iconBg,
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Icon(
//                     icon,
//                     size: cw(9.4).clamp(14.0, 20.0),
//                     color: iconColor,
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: ch(8.1)),
//             Text(
//               value,
//               style: TextStyle(
//                 fontSize: AppFontSize.f16,
//                 fontWeight: FontWeight.w600,
//                 color: const Color(0xFF111827),
//               ),
//             ),
//             SizedBox(height: ch(2.4)),
//             Text(
//               subtitle,
//               style: TextStyle(
//                 fontSize: AppFontSize.f9,
//                 color: const Color(0xFF9CA3AF),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────────────────────
// class _RecentMembersCard extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       child: Padding(
//         padding: EdgeInsets.all(cw(11.2)),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Recent Members',
//               style: TextStyle(
//                 fontSize: AppFontSize.f13,
//                 fontWeight: FontWeight.w600,
//                 color: const Color(0xFF111827),
//               ),
//             ),
//             SizedBox(height: ch(12.2)),
//             ...context
//                 .watch<GymProvider>()
//                 .members
//                 .take(4)
//                 .map(
//                   (m) => Padding(
//                     padding: EdgeInsets.only(bottom: ch(9.7)),
//                     child: Row(
//                       children: [
//                         CircleAvatar(
//                           radius: cw(15.0).clamp(16.0, 22.0),
//                           backgroundColor: const Color(0xFFEFF6FF),
//                           child: Text(
//                             m.name[0],
//                             style: TextStyle(
//                               color: const Color(0xFF2563EB),
//                               fontWeight: FontWeight.w600,
//                               fontSize: AppFontSize.f15,
//                             ),
//                           ),
//                         ),
//                         SizedBox(width: cw(7.5)),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 m.name,
//                                 style: TextStyle(
//                                   fontSize: AppFontSize.f12,
//                                   fontWeight: FontWeight.w500,
//                                   color: const Color(0xFF111827),
//                                 ),
//                               ),
//                               Text(
//                                 m.membership,
//                                 style: TextStyle(
//                                   fontSize: AppFontSize.f10,
//                                   color: const Color(0xFF6B7280),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         StatusBadge(status: m.status),
//                       ],
//                     ),
//                   ),
//                 ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────────────────────
// class _ClassScheduleCard extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       child: Padding(
//         padding: EdgeInsets.all(cw(11.2)),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               "Today's Classes",
//               style: TextStyle(
//                 fontSize: AppFontSize.f13,
//                 fontWeight: FontWeight.w600,
//                 color: const Color(0xFF111827),
//               ),
//             ),
//             SizedBox(height: ch(12.2)),
//             ...context
//                 .watch<GymProvider>()
//                 .classes
//                 .take(4)
//                 .map(
//                   (c) => Padding(
//                     padding: EdgeInsets.only(bottom: ch(9.7)),
//                     child: Row(
//                       children: [
//                         Container(
//                           width: cw(2.2).clamp(3.0, 5.0),
//                           height: ch(36.5),
//                           decoration: BoxDecoration(
//                             color: const Color(0xFF2563EB),
//                             borderRadius: BorderRadius.circular(2),
//                           ),
//                         ),
//                         SizedBox(width: cw(7.5)),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 c.name,
//                                 style: TextStyle(
//                                   fontSize: AppFontSize.f12,
//                                   fontWeight: FontWeight.w500,
//                                   color: const Color(0xFF111827),
//                                 ),
//                               ),
//                               Text(
//                                 '${c.time} · ${c.trainer}',
//                                 style: TextStyle(
//                                   fontSize: AppFontSize.f10,
//                                   color: const Color(0xFF6B7280),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         Text(
//                           '${c.enrolled}/${c.capacity}',
//                           style: TextStyle(
//                             fontSize: AppFontSize.f11,
//                             color: const Color(0xFF6B7280),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────────────────────
// class _PaymentStatusCard extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final provider = context.watch<GymProvider>();
//     final paid = provider.payments.where((p) => p.status == 'Paid').length;
//     final pending = provider.payments
//         .where((p) => p.status == 'Pending')
//         .length;
//     final overdue = provider.payments
//         .where((p) => p.status == 'Overdue')
//         .length;

//     return Card(
//       child: Padding(
//         padding: EdgeInsets.all(cw(11.2)),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Payment Overview',
//               style: TextStyle(
//                 fontSize: AppFontSize.f13,
//                 fontWeight: FontWeight.w600,
//                 color: const Color(0xFF111827),
//               ),
//             ),
//             SizedBox(height: ch(12.2)),
//             Row(
//               children: [
//                 _PaymentPill(
//                   label: 'Paid',
//                   count: paid,
//                   color: const Color(0xFF059669),
//                   bg: const Color(0xFFECFDF5),
//                 ),
//                 SizedBox(width: cw(7.5)),
//                 _PaymentPill(
//                   label: 'Pending',
//                   count: pending,
//                   color: const Color(0xFFD97706),
//                   bg: const Color(0xFFFFFBEB),
//                 ),
//                 SizedBox(width: cw(7.5)),
//                 _PaymentPill(
//                   label: 'Overdue',
//                   count: overdue,
//                   color: const Color(0xFFDC2626),
//                   bg: const Color(0xFFFEF2F2),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────────────────────
// class _PaymentPill extends StatelessWidget {
//   const _PaymentPill({
//     required this.label,
//     required this.count,
//     required this.color,
//     required this.bg,
//   });
//   final String label;
//   final int count;
//   final Color color, bg;

//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: Container(
//         padding: EdgeInsets.symmetric(vertical: ch(12.2)),
//         decoration: BoxDecoration(
//           color: bg,
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Column(
//           children: [
//             Text(
//               '$count',
//               style: TextStyle(
//                 fontSize: AppFontSize.f16,
//                 fontWeight: FontWeight.w700,
//                 color: color,
//               ),
//             ),
//             SizedBox(height: ch(2.4)),
//             Text(
//               label,
//               style: TextStyle(fontSize: AppFontSize.f11, color: color),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:app/ui/helpers/color_helper.dart';
import 'package:app/ui/utils/app_gradient.dart';
import 'package:app/ui/utils/app_text.dart';
import 'package:app/ui/utils/asset_utils.dart';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../shared_widgets.dart';
import '../ui/helpers/app_layout_helper.dart';
import 'package:app/ui/helpers/font_size_helper.dart';
import '../service/firestore_service.dart';

/// **DashboardScreen**
///
/// The main landing screen of the application dashboard.
/// It displays aggregated metrics (Active Members, Classes Today, Attendance, Revenue)
/// and secondary cards for recent members, class schedules, and payment overviews.
///
/// It connects to the real-time Firestore streams for members and payments, allowing
/// the dashboard metrics and cards to update in real-time without manual refreshes.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Member>>(
      stream: FirestoreService.instance.membersStream(),
      builder: (context, memberSnapshot) {
        return StreamBuilder<List<Payment>>(
          stream: FirestoreService.instance.paymentsStream(),
          builder: (context, paymentSnapshot) {
            if (memberSnapshot.connectionState == ConnectionState.waiting ||
                paymentSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(color: AppColor.cFFFFFF),
                ),
              );
            }

            if (memberSnapshot.hasError || paymentSnapshot.hasError) {
              return const Scaffold(
                backgroundColor: Color(0xFFF9FAFB),
                body: Center(child: Text('Error loading dashboard data')),
              );
            }

            final members = memberSnapshot.data ?? [];
            final payments = paymentSnapshot.data ?? [];

            // Compute active members from Firestore stream
            final activeMembers = members
                .where((m) => m.status == 'Active')
                .length;

            // Compute total revenue from Paid payments in Firestore stream
            final totalRevenue = payments
                .where((p) => p.status == 'Paid')
                .fold(0.0, (s, p) => s + p.amount);

            // (Attendance is now fetched locally where it is built to prevent broad rebuilds)

            return Scaffold(
              // backgroundColor: const Color(0xFFF9FAFB),
              body: SingleChildScrollView(
                padding: pagePadding(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: ch(8.1)),
                    AppText(
                      txt: "Dashboard",
                      fontSize: AppFontSize.f19,
                      fontWeight: FontWeight.w600,
                      // color: const Color(0xFF111827),
                    ),
                    SizedBox(height: ch(4.1)),
                    AppText(
                      txt: "Welcome back! Here's what's happening today.",
                      fontSize: AppFontSize.f12,
                      // color: const Color(0xFF6B7280),
                      color: const Color(0xFF6B7280),
                    ),
                    SizedBox(height: ch(20.3)),

                    // ── Stat cards (1 Row mein 4 Containers fixed for Web/Desktop) ──
                    LayoutBuilder(
                      builder: (context, constraints) {
                        double cardWidth;

                        // Desktop / Web View (> 900px) -> 4 Cards in 1 Row
                        if (constraints.maxWidth > 900) {
                          cardWidth = (constraints.maxWidth - 48) / 4;
                        }
                        // Tablet View (600px se 900px) -> 2 Cards in 1 Row
                        else if (constraints.maxWidth > 600) {
                          cardWidth = (constraints.maxWidth - 16) / 2;
                        }
                        // Mobile View (< 600px) -> 1 Card in 1 Row (Stacked)
                        else {
                          cardWidth = constraints.maxWidth;
                        }

                        return Wrap(
                          spacing: 16.0, // Horizontal space
                          runSpacing: 16.0, // Vertical space
                          children: [
                            SizedBox(
                              width: cardWidth,
                              child: _StatCard(
                                title: 'Active Members',
                                value: '$activeMembers',
                                subtitle: 'of ${members.length} total',
                                icon: Icons.people,
                                iconColor: const Color(0xFF2563EB),
                                iconBg: const Color(0xFFEFF6FF),
                              ),
                            ),
                            // SizedBox(
                            //   width: cardWidth,
                            //   child: _StatCard(
                            //     title: 'Classes Today',
                            //     value: '${provider.classes.length}',
                            //     subtitle:
                            //         '${provider.classes.where((c) => c.status == "Full").length} full',
                            //     icon: Icons.calendar_today,
                            //     iconColor: const Color(0xFF7C3AED),
                            //     iconBg: const Color(0xFFF5F3FF),
                            //   ),
                            // ),
                            // SizedBox(
                            //   width: cardWidth,
                            //   child: _StatCard(
                            //     title: 'Attendance',
                            //     value: '$todayPresent',
                            //     subtitle: 'present today',
                            //     icon: Icons.fact_check,
                            //     iconColor: const Color(0xFF059669),
                            //     iconBg: const Color(0xFFECFDF5),
                            //   ),
                            // ),
                            SizedBox(
                              width: cardWidth,
                              child: _StatCard(
                                title: 'Revenue',
                                value: 'Rs. ${totalRevenue.toInt()}',
                                subtitle: 'this month',
                                icon: Icons.attach_money,
                                iconColor: const Color(0xFFD97706),
                                iconBg: const Color(0xFFFFFBEB),
                              ),
                            ),
                            Spacer(),
                            Image.asset(
                              AssetUtils.titleLogo1,
                              width: cw(100),
                              height: ch(100),
                            ),
                          ],
                        );
                      },
                    ),

                    SizedBox(height: ch(20.3)),

                    // ── Recent members & class schedule ────────────────────────────
                    LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth > 700) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _RecentMembersCard(members: members),
                              ),
                              // SizedBox(width: cw(7.5)),
                              // Expanded(child: _ClassScheduleCard()),
                            ],
                          );
                        }
                        return Column(
                          children: [
                            _RecentMembersCard(members: members),
                            SizedBox(height: ch(12.2)),
                            //   _ClassScheduleCard(),
                          ],
                        );
                      },
                    ),

                    SizedBox(height: ch(12.2)),
                    _PaymentStatusCard(payments: payments),
                    SizedBox(height: ch(16.2)),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// **_StatCard**
///
/// A reusable dashboard card widget designed to highlight key metrics.
/// Displays a metric title, value, helper subtitle, and an aesthetic icon badge.
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    this.isRupeeIocn = false,
  });
  final String title, value, subtitle;
  final IconData icon;
  final bool isRupeeIocn;
  final Color iconColor, iconBg;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(cw(11.2).clamp(12.0, 16.0)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: AppFontSize.f11,
                      color: AppColor.cFFFFFF,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(cw(5.6).clamp(6.0, 8.0)),
                  decoration: BoxDecoration(
                    gradient: AppGradients.redGradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: isRupeeIocn
                      ? AppText(txt: "Rs")
                      : Icon(
                          icon,
                          size: cw(9.4).clamp(16.0, 20.0),
                          color: AppColor.cFFFFFF,
                        ),
                ),
              ],
            ),
            SizedBox(height: ch(8.1)),
            Text(
              value,
              style: TextStyle(
                fontSize: AppFontSize.f16,
                fontWeight: FontWeight.w600,
                color: AppColor.cFFFFFF,
              ),
            ),
            SizedBox(height: ch(2.4)),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: AppFontSize.f9,
                color: AppColor.cFFFFFF,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// **_RecentMembersCard**
///
/// Displays up to four most recently registered members.
/// It uses a live list of members fed from the parent real-time Firestore stream,
/// updating automatically when new members sign up.
class _RecentMembersCard extends StatelessWidget {
  final List<Member> members;
  const _RecentMembersCard({required this.members});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(cw(11.2).clamp(12.0, 16.0)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Members',
              style: TextStyle(
                fontSize: AppFontSize.f13,
                fontWeight: FontWeight.w600,
                color: AppColor.cFFFFFF,
              ),
            ),
            SizedBox(height: ch(12.2)),
            ...members
                .take(4)
                .map(
                  (m) => Padding(
                    padding: EdgeInsets.only(bottom: ch(9.7)),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: cw(15.0).clamp(16.0, 20.0),
                          backgroundColor: AppColor.cFFFFFF,
                          child: Text(
                            m.name.isNotEmpty ? m.name[0].toUpperCase() : 'M',
                            style: TextStyle(
                              color: AppColor.blue2,
                              fontWeight: FontWeight.w700,
                              fontSize: AppFontSize.f12,
                            ),
                          ),
                        ),
                        SizedBox(width: cw(7.5)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                capitalizeFirstLetter(m.name),
                                style: TextStyle(
                                  fontSize: AppFontSize.f12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColor.cFFFFFF,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                m.membership,
                                style: TextStyle(
                                  fontSize: AppFontSize.f10,
                                  color: const Color(0xFF6B7280),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),

                        StatusBadge(
                          status: FirestoreService.isOverdueByDate(m)
                              ? 'Overdue'
                              : m.status,
                        ),
                      ],
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// class _ClassScheduleCard extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: EdgeInsets.zero,
//       child: Padding(
//         padding: EdgeInsets.all(cw(11.2).clamp(12.0, 16.0)),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               "Today's Classes",
//               style: TextStyle(
//                 fontSize: AppFontSize.f13,
//                 fontWeight: FontWeight.w600,
//                 color: AppColor.cFFFFFF,
//               ),
//             ),
//             SizedBox(height: ch(12.2)),
//             ...context
//                 .watch<GymProvider>()
//                 .classes
//                 .take(4)
//                 .map(
//                   (c) => Padding(
//                     padding: EdgeInsets.only(bottom: ch(9.7)),
//                     child: Row(
//                       children: [
//                         Container(
//                           width: cw(2.2).clamp(3.0, 4.0),
//                           height: ch(32.0).clamp(28.0, 36.0),
//                           decoration: BoxDecoration(
//                             gradient: AppGradients.redGradient,
//                             borderRadius: BorderRadius.circular(2),
//                           ),
//                         ),
//                         SizedBox(width: cw(7.5)),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 c.name,
//                                 style: TextStyle(
//                                   fontSize: AppFontSize.f12,
//                                   fontWeight: FontWeight.w500,
//                                   color: AppColor.cFFFFFF,
//                                 ),
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                               Text(
//                                 '${c.time} · ${c.trainer}',
//                                 style: TextStyle(
//                                   fontSize: AppFontSize.f10,
//                                   color: const Color(0xFF6B7280),
//                                 ),
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ],
//                           ),
//                         ),
//                         Text(
//                           '${c.enrolled}/${c.capacity}',
//                           style: TextStyle(
//                             fontSize: AppFontSize.f11,
//                             color: const Color(0xFF6B7280),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//           ],
//         ),
//       ),
//     );
//   }
// }

/// **_ClassScheduleCard**
///
/// Displays up to four of today's classes from the local seed schedule,
/// showing their category, trainer, scheduling time, and capacity.
// class _ClassScheduleCard extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: EdgeInsets.zero,
//       child: Padding(
//         padding: EdgeInsets.all(cw(11.2).clamp(12.0, 16.0)),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               "Today's Classes",
//               style: TextStyle(
//                 fontSize: AppFontSize.f13,
//                 fontWeight: FontWeight.w600,
//                 color: const Color(0xFF111827),
//               ),
//             ),
//             SizedBox(height: ch(12.2)),
//             ...context
//                 .watch<GymProvider>()
//                 .classes
//                 .take(4)
//                 .map(
//                   (c) => Padding(
//                     padding: EdgeInsets.only(bottom: ch(9.7)),
//                     child: Row(
//                       children: [
//                         Container(
//                           width: cw(2.2).clamp(3.0, 4.0),
//                           height: ch(32.0).clamp(28.0, 36.0),
//                           decoration: BoxDecoration(
//                             color: const Color(0xFF2563EB),
//                             borderRadius: BorderRadius.circular(2),
//                           ),
//                         ),
//                         SizedBox(width: cw(7.5)),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 c.name,
//                                 style: TextStyle(
//                                   fontSize: AppFontSize.f12,
//                                   fontWeight: FontWeight.w500,
//                                   color: const Color(0xFF111827),
//                                 ),
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                               Text(
//                                 '${c.time} · ${c.trainer}',
//                                 style: TextStyle(
//                                   fontSize: AppFontSize.f10,
//                                   color: const Color(0xFF6B7280),
//                                 ),
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ],
//                           ),
//                         ),
//                         Text(
//                           '${c.enrolled}/${c.capacity}',
//                           style: TextStyle(
//                             fontSize: AppFontSize.f11,
//                             color: const Color(0xFF6B7280),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//           ],
//         ),
//       ),
//     );
//   }
// }

/// **_PaymentStatusCard**
///
/// Displays aggregated totals of Paid, Pending, and Overdue payments.
/// Integrates with the real-time payments list from Firestore.
/// Uses a responsive layout to swap from horizontal rows to stacked columns in portrait screen modes.
class _PaymentStatusCard extends StatelessWidget {
  final List<Payment> payments;
  const _PaymentStatusCard({required this.payments});

  @override
  Widget build(BuildContext context) {
    final paid = payments.where((p) => p.status == 'Paid').length;
    final pending = payments.where((p) => p.status == 'Pending').length;
    final overdue = payments.where((p) => p.status == 'Overdue').length;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(cw(11.2).clamp(12.0, 16.0)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Overview',
              style: TextStyle(
                fontSize: AppFontSize.f13,
                fontWeight: FontWeight.w600,
                color: AppColor.cFFFFFF,
              ),
            ),
            SizedBox(height: ch(12.2)),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 450) {
                  return Column(
                    children: [
                      _PaymentPillHorizontal(
                        label: 'Paid',
                        count: paid,
                        color: const Color(0xFF059669),
                        bg: const Color(0xFFECFDF5),
                      ),
                      const SizedBox(height: 8.0),
                      _PaymentPillHorizontal(
                        label: 'Pending',
                        count: pending,
                        color: const Color(0xFFD97706),
                        bg: const Color(0xFFFFFBEB),
                      ),
                      const SizedBox(height: 8.0),
                      _PaymentPillHorizontal(
                        label: 'Overdue',
                        count: overdue,
                        color: const Color(0xFFDC2626),
                        bg: const Color(0xFFFEF2F2),
                      ),
                    ],
                  );
                }
                return Row(
                  children: [
                    _PaymentPill(
                      label: 'Paid',
                      count: paid,
                      color: const Color(0xFF059669),
                      bg: const Color(0xFFECFDF5),
                    ),
                    SizedBox(width: cw(7.5)),
                    _PaymentPill(
                      label: 'Pending',
                      count: pending,
                      color: const Color(0xFFD97706),
                      bg: const Color(0xFFFFFBEB),
                    ),
                    SizedBox(width: cw(7.5)),
                    _PaymentPill(
                      label: 'Overdue',
                      count: overdue,
                      color: const Color(0xFFDC2626),
                      bg: const Color(0xFFFEF2F2),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// **_PaymentPill**
///
/// A vertical layout status metric box displaying counting status for a payment category.
class _PaymentPill extends StatelessWidget {
  const _PaymentPill({
    required this.label,
    required this.count,
    required this.color,
    required this.bg,
  });
  final String label;
  final int count;
  final Color color, bg;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: ch(12.2).clamp(12.0, 16.0)),
        decoration: BoxDecoration(
          gradient: AppGradients.redGradient,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(
                fontSize: AppFontSize.f16,
                fontWeight: FontWeight.w700,
                color: AppColor.cFFFFFF,
              ),
            ),
            SizedBox(height: ch(2.4)),
            Text(
              label,
              style: TextStyle(
                fontSize: AppFontSize.f11,
                color: AppColor.cFFFFFF,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// **_PaymentPillHorizontal**
///
/// A horizontal status metric layout pill displaying counters and categories for narrow layouts.
class _PaymentPillHorizontal extends StatelessWidget {
  const _PaymentPillHorizontal({
    required this.label,
    required this.count,
    required this.color,
    required this.bg,
  });
  final String label;
  final int count;
  final Color color, bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      decoration: BoxDecoration(
        gradient: AppGradients.redGradient,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: AppFontSize.f11,
              fontWeight: FontWeight.w500,
              color: AppColor.cFFFFFF,
            ),
          ),
          Text(
            '$count',
            style: TextStyle(
              fontSize: AppFontSize.f16,
              fontWeight: FontWeight.w700,
              color: AppColor.cFFFFFF,
            ),
          ),
        ],
      ),
    );
  }
}
