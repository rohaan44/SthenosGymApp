import 'package:app/models/models.dart';
import 'package:app/providers/payment_provider.dart';
import 'package:app/ui/helpers/app_layout_helper.dart';
import 'package:app/ui/helpers/color_helper.dart';
import 'package:app/ui/helpers/font_size_helper.dart';
import 'package:app/ui/utils/app_gradient.dart';
import 'package:app/ui/utils/app_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Member Payment History Screen
//
// Usage: Navigator.pushNamed(context, AppRoutes.memberPaymentHistory,
//          arguments: member);
//
// Uses a StreamBuilder bound to FirestoreService.memberPaymentsStream()
// via PaymentsProvider so the list updates in real-time when payments change.
// ─────────────────────────────────────────────────────────────────────────────
class MemberPaymentHistoryScreen extends StatelessWidget {
  const MemberPaymentHistoryScreen({super.key, required this.member});

  final Member member;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<PaymentsProvider>();

    return Scaffold(
      appBar: _buildAppBar(context),
      body: StreamBuilder<List<Payment>>(
        stream: provider.memberPaymentsStream(member.docId),
        builder: (context, snapshot) {
          // ── Loading ──────────────────────────────────────────────────────
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color:AppColor.cFFFFFF),
            );
          }

          // ── Error ────────────────────────────────────────────────────────
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(cw(16)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Color(0xFFDC2626),
                      size: 48,
                    ),
                    SizedBox(height: ch(12)),
                    AppText(
                      txt: 'Failed to load payment history',
                      fontSize: AppFontSize.f14,
                      color: const Color(0xFFDC2626),
                      fontWeight: FontWeight.w500,
                    ),
                    SizedBox(height: ch(6)),
                    AppText(
                      txt: snapshot.error.toString(),
                      fontSize: AppFontSize.f12,
                      color: const Color(0xFF9CA3AF),
                    ),
                  ],
                ),
              ),
            );
          }

          final payments = snapshot.data ?? [];
          final summary = PaymentSummary.fromPayments(payments);

          return CustomScrollView(
            slivers: [
              // ── Summary Card ───────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(cw(12), ch(16), cw(12), 0),
                  child: _SummaryCard(member: member, summary: summary),
                ),
              ),

              SliverToBoxAdapter(child: SizedBox(height: ch(16))),

              // ── Section header ─────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: cw(12)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppText(
                        txt: 'Payment History',
                        fontSize: AppFontSize.f15,
                        fontWeight: FontWeight.w600,
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: cw(8),
                          vertical: ch(6),
                        ),
                        decoration: BoxDecoration(
                          color: AppColor.cFFFFFF,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: AppText(
                          txt: '${payments.length} records',
                          fontSize: AppFontSize.f11,
                          color: AppColor.blue2,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(child: SizedBox(height: ch(10))),

              // ── Empty state ─────────────────────────────────────────────
              if (payments.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: cw(12),
                      vertical: ch(32),
                    ),
                    child: _EmptyState(),
                  ),
                ),

              // ── Payment list ───────────────────────────────────────────
              if (payments.isNotEmpty)
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: cw(12)),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) =>
                          _PaymentTile(payment: payments[index]),
                      childCount: payments.length,
                    ),
                  ),
                ),

              SliverToBoxAdapter(child: SizedBox(height: ch(24))),
            ],
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: AppColor.c252525,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: SizedBox(width: cw(15)),
      // IconButton(
      //   icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
      //   color: const Color(0xFF111827),
      //   onPressed: () => Navigator.pop(context),
      // ),
      titleSpacing: 0,
      title: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFFEFF6FF),
            backgroundImage:
                (member.profileImageUrl != null &&
                    member.profileImageUrl!.isNotEmpty)
                ? NetworkImage(member.profileImageUrl!)
                : null,
            child:
                (member.profileImageUrl == null ||
                    member.profileImageUrl!.isEmpty)
                ? Text(
                    member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: Color(0xFF2563EB),
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  )
                : null,
          ),
          SizedBox(width: cw(8)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                member.name,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColor.cFFFFFF,
                ),
              ),
              Text(
                member.membership,
                style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
              ),
            ],
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppColor.cFFFFFF),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Summary Card
// ─────────────────────────────────────────────────────────────────────────────
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.member, required this.summary});

  final Member member;
  final PaymentSummary summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppGradients.redGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(cw(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: AppColor.cFFFFFF,
                  size: 18,
                ),
                SizedBox(width: cw(6)),
                const Text(
                  'Payment Summary',
                  style: TextStyle(
                    color: AppColor.cFFFFFF,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            SizedBox(height: ch(16)),

            // Stats grid
            Row(
              children: [
                Expanded(
                  child: _StatCell(
                    label: 'Total Paid',
                    value: 'Rs ${summary.totalPaid.toStringAsFixed(0)}',
                    icon: Icons.check_circle_outline_rounded,
                    accent: const Color(0xFF86EFAC),
                  ),
                ),
                Container(
                  width: 1,
                  height: 48,
                  color: Colors.white24,
                  margin: EdgeInsets.symmetric(horizontal: cw(8)),
                ),
                Expanded(
                  child: _StatCell(
                    label: 'Overdue',
                    value: 'Rs ${summary.totalOverdue.toStringAsFixed(0)}',
                    icon: Icons.warning_amber_rounded,
                    accent: AppColor.cFFFFFF,
                  ),
                ),
              ],
            ),

            SizedBox(height: ch(12)),
            Container(height: 1, color: Colors.white24),
            SizedBox(height: ch(12)),

            // Bottom row
            Row(
              children: [
                Expanded(
                  child: _StatCell(
                    label: 'Last Payment',
                    value: summary.lastPaymentDate ?? '—',
                    icon: Icons.calendar_today_outlined,
                    accent: AppColor.cFFFFFF,
                    smallText: true,
                  ),
                ),
                Container(
                  width: 1,
                  height: 48,
                  color: Colors.white24,
                  margin: EdgeInsets.symmetric(horizontal: cw(8)),
                ),
                Expanded(
                  child: _StatCell(
                    label: 'Total Records',
                    value: '${summary.totalCount}',
                    icon: Icons.receipt_long_outlined,
                    accent: const Color(0xFFC4B5FD),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
    this.smallText = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accent;
  final bool smallText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: accent, size: 14),
            SizedBox(width: cw(4)),
            Text(
              label,
              style: const TextStyle(
                color: AppColor.cFFFFFF,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: ch(4)),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: smallText ? 12 : 16,
            fontWeight: FontWeight.w700,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Individual Payment Tile
// ─────────────────────────────────────────────────────────────────────────────
class _PaymentTile extends StatelessWidget {
  const _PaymentTile({required this.payment});

  final Payment payment;

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(payment.status);
    final statusBg = _statusBg(payment.status);
    final methodIcon = _methodIcon(payment.method);

    return Container(
      margin: EdgeInsets.only(bottom: ch(10)),
      decoration: BoxDecoration(
        color: AppColor.c252525,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(cw(12)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Method icon circle
            Container(
              width: cw(38).clamp(36.0, 48.0),
              height: cw(38).clamp(36.0, 48.0),
              decoration: BoxDecoration(
                gradient: AppGradients.redGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(methodIcon, color: AppColor.cFFFFFF, size: 18),
            ),

            SizedBox(width: cw(10)),

            // Middle: invoice + plan + date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    payment.invoiceId,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColor.cFFFFFF,
                    ),
                  ),
                  SizedBox(height: ch(2)),
                  Text(
                    payment.plan.isNotEmpty ? payment.plan : 'N/A',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  SizedBox(height: ch(3)),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 10,
                        color: Color(0xFF9CA3AF),
                      ),
                      SizedBox(width: cw(3)),
                      Text(
                        payment.date.isNotEmpty ? payment.date : '—',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                      SizedBox(width: cw(8)),
                      const Icon(
                        Icons.payment_outlined,
                        size: 10,
                        color: Color(0xFF9CA3AF),
                      ),
                      SizedBox(width: cw(3)),
                      Text(
                        payment.method.isNotEmpty ? payment.method : '—',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(width: cw(8)),

            // Right: amount + status badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Rs ${payment.amount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColor.cFFFFFF,
                  ),
                ),
                SizedBox(height: ch(6)),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: cw(8),
                    vertical: ch(3),
                  ),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _statusIcon(payment.status),
                        size: 10,
                        color: statusColor,
                      ),
                      SizedBox(width: cw(3)),
                      Text(
                        payment.status,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Paid':
        return const Color(0xFF059669);
      case 'Overdue':
        return const Color(0xFFDC2626);
      case 'Active':
        return const Color(0xFF2563EB);
      default:
        return const Color(0xFFD97706);
    }
  }

  Color _statusBg(String status) {
    switch (status) {
      case 'Paid':
        return const Color(0xFFECFDF5);
      case 'Overdue':
        return const Color(0xFFFEF2F2);
      case 'Active':
        return const Color(0xFFEFF6FF);
      default:
        return const Color(0xFFFFFBEB);
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'Paid':
        return Icons.check_circle_rounded;
      case 'Overdue':
        return Icons.cancel_rounded;
      case 'Active':
        return Icons.radio_button_checked_rounded;
      default:
        return Icons.access_time_rounded;
    }
  }

  IconData _methodIcon(String method) {
    final m = method.toLowerCase();
    if (m.contains('cash')) return Icons.money_rounded;
    if (m.contains('card') || m.contains('credit') || m.contains('debit')) {
      return Icons.credit_card_rounded;
    }
    if (m.contains('bank') || m.contains('transfer')) {
      return Icons.account_balance_rounded;
    }
    if (m.contains('online') ||
        m.contains('jazzcash') ||
        m.contains('easypaisa')) {
      return Icons.phone_android_rounded;
    }
    return Icons.receipt_long_rounded;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty State
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              color: Color(0xFF2563EB),
              size: 36,
            ),
          ),
          SizedBox(height: ch(16)),
          const Text(
            'No payments yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColor.cFFFFFF,
            ),
          ),
          SizedBox(height: ch(6)),
          const Text(
            'This member has no payment records.',
            style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
