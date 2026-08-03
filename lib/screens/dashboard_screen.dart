import 'package:app/providers/main_dashboard_provider.dart';
import 'package:app/screens/main_dashboard_screen.dart';
import 'package:app/ui/helpers/color_helper.dart';
import 'package:app/ui/utils/app_gradient.dart';
import 'package:app/ui/utils/app_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
              return Scaffold(
                // backgroundColor: Color(0xFFF9FAFB),
                body: Center(
                  child: AppText(txt: 'Error loading dashboard data'),
                ),
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
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              txt: "Dashboard",
                              fontSize: AppFontSize.f19,
                              fontWeight: FontWeight.w600,
                              // color: const Color(0xFF111827),
                            ),
                            SizedBox(height: ch(8)),
                            AppText(
                              txt:
                                  "Welcome back! Here's what's happening today.",
                              fontSize: AppFontSize.f15,
                              fontWeight: FontWeight.w500,
                              // color: const Color(0xFF6B7280),
                              color: const Color(0xFF6B7280),
                            ),
                          ],
                        ),
                        SizedBox(width: 20),

                        if (isPhone(context))
                          const SizedBox.shrink()
                        else
                          Consumer<MainDashboardProvider>(
                            builder: (context, dashboardModel, _) {
                              return notificationButton(
                                isWeb: true,
                                context: context,
                                model: dashboardModel,
                              );
                            },
                          ),
                      ],
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

                            SizedBox(
                              width: cardWidth,
                              child: _StatCard(
                                title: 'Revenue',
                                value: 'Rs. ${totalRevenue.toInt()}',
                                subtitle: 'this month',
                                isRupeeIcon: true,
                                icon: Icons.attach_money,
                                iconColor: const Color(0xFFD97706),
                                iconBg: const Color(0xFFFFFBEB),
                              ),
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
                            SizedBox(height: ch(15)),
                            //   _ClassScheduleCard(),
                          ],
                        );
                      },
                    ),

                    SizedBox(height: ch(15)),
                    _PaymentStatusCard(payments: payments),
                    SizedBox(height: ch(20)),
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
    this.isRupeeIcon = false,
  });
  final String title, value, subtitle;
  final IconData icon;
  final bool isRupeeIcon;
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
                  child: AppText(
                    txt: title,
                    // style: TextStyle(
                    fontSize: AppFontSize.f15,
                    color: AppColor.cFFFFFF,
                    // ),
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
                  child: isRupeeIcon
                      ? AppText(txt: "Rs")
                      : Icon(
                          icon,
                          size: cw(9.4).clamp(16.0, 20.0),
                          color: AppColor.cFFFFFF,
                        ),
                ),
              ],
            ),
            SizedBox(height: ch(9)),
            AppText(
              txt: value,
              fontSize: AppFontSize.f16,
              fontWeight: FontWeight.w600,
              color: AppColor.cFFFFFF,
            ),
            SizedBox(height: ch(2.4)),
            AppText(
              txt: subtitle,
              fontSize: AppFontSize.f13,
              color: AppColor.cFFFFFF,
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
            AppText(
              txt: 'Recent Members',
              // style: TextStyle(
              fontSize: AppFontSize.f15,
              color: AppColor.cFFFFFF,
              // ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            SizedBox(height: ch(15)),
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
                          backgroundImage:
                              (m.profileImageUrl != null &&
                                  m.profileImageUrl!.isNotEmpty)
                              ? NetworkImage(m.profileImageUrl!)
                              : null,
                          child:
                              (m.profileImageUrl == null ||
                                  m.profileImageUrl!.isEmpty)
                              ? AppText(
                                  txt: m.name.isNotEmpty
                                      ? m.name[0].toUpperCase()
                                      : 'M',
                                  color: AppColor.blue2,
                                  fontWeight: FontWeight.w700,
                                  fontSize: AppFontSize.f12,
                                )
                              : null,
                        ),
                        SizedBox(width: cw(7.5)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(
                                txt: capitalizeFirstLetter(m.name),
                                // style: TextStyle(
                                fontSize: AppFontSize.f15,
                                fontWeight: FontWeight.w600,
                                color: AppColor.cFFFFFF,
                                // ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: ch(10)),
                              AppText(
                                txt: m.membership,
                                // style: TextStyle(
                                fontSize: AppFontSize.f12,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF6B7280),
                                // ),
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
            AppText(
              txt: 'Payment Overview',
              fontSize: AppFontSize.f15,
              color: AppColor.cFFFFFF,
              // ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: ch(13)),
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
            AppText(
              txt: '$count',
              fontSize: AppFontSize.f17,
              fontWeight: FontWeight.w700,
              color: AppColor.cFFFFFF,
            ),
            SizedBox(height: ch(3)),
            AppText(
              txt: label,
              // style: TextStyle(
              fontSize: AppFontSize.f13,
              color: AppColor.cFFFFFF,
              // ),
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
          AppText(
            txt: label,
            // style: TextStyle(
            fontSize: AppFontSize.f11,
            fontWeight: FontWeight.w500,
            color: AppColor.cFFFFFF,
            // ),
          ),
          AppText(
            txt: '$count',
            // style: TextStyle(
            fontSize: AppFontSize.f16,
            fontWeight: FontWeight.w700,
            color: AppColor.cFFFFFF,
            // ),
          ),
        ],
      ),
    );
  }
}
