import 'package:app/providers/main_dashboard_provider.dart';
import 'package:app/providers/payment_provider.dart';
import 'package:app/screens/main_dashboard_screen.dart';
import 'package:app/service/firestore_service.dart';
import 'package:app/ui/helpers/color_helper.dart';
import 'package:app/ui/utils/app_gradient.dart';
import 'package:app/ui/utils/app_primary_button.dart';
import 'package:app/ui/utils/app_text.dart';
import 'package:app/ui/utils/primary_textfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../shared_widgets.dart';
import '../ui/helpers/app_layout_helper.dart';
import 'package:app/ui/helpers/font_size_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../ui/routes/app_routes.dart';
import 'member/members_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Payments Screen — fully driven by a Firestore snapshot stream.
// Stateless: this widget itself holds no mutable state. All state lives
// either in Firestore (via streams) or in the specific child widgets that
// actually need local edit-state (dropdown cells, save buttons).
// ─────────────────────────────────────────────────────────────────────────────
class PaymentsScreen extends StatelessWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final phone = isPhone(context);

    return Scaffold(
      body: SingleChildScrollView(
        padding: pagePadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: ch(8.1)),

            // Header sits above the StreamBuilder, so it never rebuilds on
            // Firestore snapshot emissions — only StreamBuilder's own
            // subtree rebuilds when the stream fires.
            _PaymentsHeader(phone: phone),

            SizedBox(height: ch(20)),
            StreamBuilder<List<Payment>>(
              stream: FirestoreService.instance.paymentsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 64),
                      child: CircularProgressIndicator(color: AppColor.cFFFFFF),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Color(0xFFDC2626),
                            size: 40,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Failed to load payments: ${snapshot.error}',
                            style: const TextStyle(color: Color(0xFFDC2626)),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final allPayments = snapshot.data ?? [];

                return StreamBuilder<dynamic>(
                  stream: FirestoreService.instance.membersStream(),
                  builder: (context, memberSnapshot) {
                    if (memberSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 64),
                          child: CircularProgressIndicator(
                            color: AppColor.cFFFFFF,
                          ),
                        ),
                      );
                    }
                    final members = memberSnapshot.data ?? <Member>[];

                    // TextButton(
                    //   onPressed: () {
                    //     // Added missing quotes to the print statement and added a safe check for the index
                    //     print(
                    //       '===== ${members.length > 1 ? members[1] : "No member"}',
                    //     );
                    //   },
                    //   // Converted the list to a String (e.g., joining or taking the first item)
                    //   child: AppText(
                    //     txt: members.isNotEmpty ? members.first.toString() : '',
                    //   ),
                    // );
                    if (memberSnapshot.hasError) {
                      return _PaymentsBody(
                        phone: phone,
                        allPayments: allPayments,
                      );
                    }

                    return _PaymentsBody(
                      phone: phone,
                      allPayments: allPayments,
                      members: members,
                    );
                  },
                );
              },
            ),

            // StreamBuilder<List<Payment>>(
            //   stream: FirestoreService.instance.paymentsStream(),
            //   builder: (context, snapshot) {
            //     if (snapshot.connectionState == ConnectionState.waiting) {
            //       return const Center(
            //         child: Padding(
            //           padding: EdgeInsets.symmetric(vertical: 64),
            //           child: CircularProgressIndicator(color: AppColor.cFFFFFF),
            //         ),
            //       );
            //     }

            //     if (snapshot.hasError) {
            //       return Center(
            //         child: Padding(
            //           padding: const EdgeInsets.all(32),
            //           child: Column(
            //             mainAxisSize: MainAxisSize.min,
            //             children: [
            //               const Icon(
            //                 Icons.error_outline,
            //                 color: Color(0xFFDC2626),
            //                 size: 40,
            //               ),
            //               const SizedBox(height: 8),
            //               Text(
            //                 'Failed to load payments: ${snapshot.error}',
            //                 style: const TextStyle(color: Color(0xFFDC2626)),
            //               ),
            //             ],
            //           ),
            //         ),
            //       );
            //     }

            //     final allPayments = snapshot.data ?? [];
            //     return _PaymentsBody(phone: phone, allPayments: allPayments);
            //   },
            // ),
            SizedBox(height: ch(16.2)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Header — title + export button. Split out purely for clarity; it's cheap
// and static enough that isolating it makes the rebuild boundary explicit.
// ─────────────────────────────────────────────────────────────────────────────
class _PaymentsHeader extends StatelessWidget {
  const _PaymentsHeader({required this.phone});
  final bool phone;

  Widget _exportButton(BuildContext context) => AppButton(
    width: 100,
    onPressed: () => _onExportTap(context),
    isRow: true,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.download_outlined, size: 18, color: AppColor.cFFFFFF),
        const SizedBox(width: 5),
        AppText(
          txt: 'Export',
          fontSize: AppFontSize.f12,
          fontWeight: FontWeight.w600,
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final titleBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          txt: 'Payments',
          fontSize: AppFontSize.f19,
          fontWeight: FontWeight.w600,
        ),
        SizedBox(height: ch(8)),
        AppText(
          txt: 'Track membership fees and billing',
          fontSize: AppFontSize.f15,
          color: phone ? const Color(0xFF6B7280) : AppColor.themeGrey,
        ),
      ],
    );

    if (phone) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleBlock,
          SizedBox(height: ch(12.2)),
          _exportButton(context),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            titleBlock,

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

        _exportButton(context),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Body: summary cards + filter + list. Depends on allPayments, so it lives
// inside the StreamBuilder scope — but is its own widget so the StreamBuilder
// builder function stays thin, and so Provider's Consumer only wraps the
// filter+list section rather than re-running the summary-card computation
// widget tree unnecessarily.
// ─────────────────────────────────────────────────────────────────────────────
class _PaymentsBody extends StatelessWidget {
  const _PaymentsBody({
    required this.phone,
    required this.allPayments,

    this.members = const [],
  });
  final bool phone;
  final List<Payment> allPayments;
  final List<dynamic> members;

  static bool _isThisMonth(String dateStr, DateTime reference) {
    if (dateStr.isEmpty) return false;
    try {
      final d = DateTime.parse(dateStr);
      return d.year == reference.year && d.month == reference.month;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalRevenue = allPayments
        .where((p) => p.status == 'Paid')
        .fold<double>(0, (s, p) => s + p.amount);
    final pendingCount = allPayments.where((p) => p.status == 'Pending').length;
    final pendingTotal = allPayments
        .where((p) => p.status == 'Pending')
        .fold<double>(0, (s, p) => s + p.amount);
    final overdueCount = allPayments.where((p) => p.status == 'Overdue').length;
    final overdueTotal = allPayments
        .where((p) => p.status == 'Overdue')
        .fold<double>(0, (s, p) => s + p.amount);
    final now = DateTime.now();
    final prevMonth = DateTime(now.year, now.month - 1, 1);
    final paidThisMonth = allPayments
        .where((p) => p.status == 'Paid' && _isThisMonth(p.date, now))
        .length;
    final paidPrevMonth = allPayments
        .where((p) => p.status == 'Paid' && _isThisMonth(p.date, prevMonth))
        .length;
    final prevMonthRevenue = allPayments
        .where((p) => p.status == 'Paid' && _isThisMonth(p.date, prevMonth))
        .fold<double>(0, (s, p) => s + p.amount);

    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            double cardWidth;
            if (constraints.maxWidth > 900) {
              cardWidth = (constraints.maxWidth - 48) / 4;
            } else if (constraints.maxWidth > 600) {
              cardWidth = (constraints.maxWidth - 16) / 2;
            } else {
              cardWidth = constraints.maxWidth;
            }
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                SizedBox(
                  width: cardWidth,
                  child: _SummaryCard(
                    title: 'Total Revenue',
                    value: 'Rs. ${totalRevenue.toInt()}',
                    sub:
                        '${allPayments.where((p) => p.status == 'Paid').length} payments',
                    icon: Icons.attach_money,
                    isRupeeIcon: true,
                    iconColor: const Color(0xFF059669),
                    iconBg: const Color(0xFFECFDF5),
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: _SummaryCard(
                    title: 'Pending',
                    value: 'Rs. ${pendingTotal.toInt()}',
                    sub: '$pendingCount invoices',
                    icon: Icons.pending_outlined,
                    iconColor: const Color(0xFFD97706),
                    iconBg: const Color(0xFFFFFBEB),
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: _SummaryCard(
                    title: 'Overdue',
                    value: 'Rs. ${overdueTotal.toInt()}',
                    sub: '$overdueCount members',
                    icon: Icons.warning_amber_outlined,
                    iconColor: const Color(0xFFDC2626),
                    iconBg: const Color(0xFFFEF2F2),
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: _SummaryCard(
                    title: 'Paid This Month',
                    value: '$paidThisMonth',
                    sub:
                        'Prev month: $paidPrevMonth (Rs. ${prevMonthRevenue.toInt()})',
                    icon: Icons.check_circle_outline,
                    iconColor: const Color(0xFF2563EB),
                    iconBg: const Color(0xFFEFF6FF),
                  ),
                ),
              ],
            );
          },
        ),
        SizedBox(height: ch(16.2)),
        Consumer<PaymentsProvider>(
          builder: (context, paymentsState, _) {
            final filtered = paymentsState.filtered(allPayments);
            return Column(
              children: [
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(cw(11.2)),
                    child: phone
                        ? Column(
                            children: [
                              _searchField(paymentsState),
                              SizedBox(height: ch(9.7)),
                              _statusDropdown(paymentsState, isExpanded: true),
                              SizedBox(height: ch(9.7)),
                              _monthDropdown(paymentsState, isExpanded: true),
                            ],
                          )
                        : Row(
                            children: [
                              Expanded(child: _searchField(paymentsState)),
                              SizedBox(width: cw(7.5)),
                              SizedBox(
                                width: 150,
                                child: _statusDropdown(paymentsState),
                              ),
                              SizedBox(width: cw(7.5)),
                              SizedBox(
                                width: 170,
                                child: _monthDropdown(paymentsState),
                              ),
                            ],
                          ),
                  ),
                ),
                SizedBox(height: ch(12.2)),
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(cw(11.2)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AppText(
                              txt: 'Payment History (${filtered.length})',
                              fontSize: AppFontSize.f16,
                              fontWeight: FontWeight.w600,
                            ),
                            if (filtered.isEmpty &&
                                (paymentsState.search.isNotEmpty ||
                                    paymentsState.filterStatus != 'all' ||
                                    paymentsState.filterMonth != 'all'))
                              InkWell(
                                onTap: () {
                                  paymentsState.searchTextFieldCntrl.clear();
                                  paymentsState.setSearch('');
                                  paymentsState.setFilterStatus('all');
                                  paymentsState.setFilterMonth('all');
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    vertical: ch(4),
                                    horizontal: cw(4),
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    gradient: AppGradients.redGradient,
                                  ),

                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppColor.cFFFFFF,
                                        ),
                                        child: Icon(
                                          Icons.clear,
                                          size: 14,
                                          color: AppColor.primary,
                                        ),
                                      ),
                                      SizedBox(width: cw(2)),
                                      AppText(
                                        txt: 'Clear filters',
                                        fontSize: AppFontSize.f11,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: ch(12.2)),
                        (phone || screenWidth(context) < 950)
                            ? _MobilePaymentList(
                                payments: filtered,

                                members: members,
                              )
                            : filtered.isEmpty
                            ? Padding(
                                padding: EdgeInsets.symmetric(vertical: ch(30)),
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.receipt_long_outlined,
                                        size: 48,
                                        color: Color(0xFFD1D5DB),
                                      ),
                                      SizedBox(height: ch(8)),
                                      AppText(
                                        txt: 'No payments found',
                                        fontSize: AppFontSize.f15,
                                        color: const Color(0xFF9CA3AF),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: _DesktopPaymentTable(
                                  payments: filtered,
                                  members: members,
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  static Widget _searchField(PaymentsProvider state) => primaryTextField(
    hintText: "Search member or invoice...",
    controller: state.searchTextFieldCntrl,
    prefixIcon: const Icon(Icons.search, size: 18, color: Color(0xFF9CA3AF)),
    onChanged: state.setSearch,
  );

  static Widget _statusDropdown(
    PaymentsProvider state, {
    bool isExpanded = false,
  }) => DropdownButtonFormField<String>(
    initialValue: state.filterStatus,
    isExpanded: isExpanded,
    dropdownColor: AppColor.red,
    decoration: customInputDecoration(label: 'Status'),
    items: [
      DropdownMenuItem(
        value: 'all',
        child: AppText(txt: 'All Status'),
      ),
      DropdownMenuItem(
        value: 'paid',
        child: AppText(txt: 'Paid'),
      ),
      DropdownMenuItem(
        value: 'pending',
        child: AppText(txt: 'Pending'),
      ),
      DropdownMenuItem(
        value: 'overdue',
        child: AppText(txt: 'Overdue'),
      ),
    ],
    onChanged: (v) => state.setFilterStatus(v!),
  );

  static Widget _monthDropdown(
    PaymentsProvider state, {
    bool isExpanded = false,
  }) {
    final now = DateTime.now();
    final prevMonth = DateTime(now.year, now.month - 1, 1);
    final thisMonthName = DateFormat.MMMM().format(now);
    final prevMonthName = DateFormat.MMMM().format(prevMonth);

    return DropdownButtonFormField<String>(
      initialValue: state.filterMonth,
      isExpanded: isExpanded,
      dropdownColor: AppColor.red,
      decoration: customInputDecoration(label: 'Month'),
      items: [
        DropdownMenuItem(
          value: 'all',
          child: AppText(txt: 'All Months'),
        ),
        DropdownMenuItem(
          value: 'this_month',
          child: AppText(txt: 'This Month ($thisMonthName)'),
        ),
        DropdownMenuItem(
          value: 'prev_month',
          child: AppText(txt: 'Prev Month ($prevMonthName)'),
        ),
      ],
      onChanged: (v) => state.setFilterMonth(v!),
    );
  }
}

Future<void> _onExportTap(BuildContext context) async {
  final provider = context.read<PaymentsProvider>();
  final error = await provider.handleExport();
  if (!context.mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(error ?? 'Export successful!'),
      backgroundColor: error != null ? Colors.red : null,
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Desktop DataTable — StatefulWidget so per-row ValueNotifiers survive
// StreamBuilder rebuilds. Previously these were recreated on every Firestore
// emission (a `final statusNotifier = ValueNotifier(...)` inside a static
// build function), which silently discarded any unsaved status edit whenever
// a new snapshot arrived — not just wasteful, an actual data-loss bug.
// ─────────────────────────────────────────────────────────────────────────────
class _DesktopPaymentTable extends StatefulWidget {
  const _DesktopPaymentTable({required this.payments, required this.members});
  final List<Payment> payments;
  final List<dynamic> members;

  @override
  State<_DesktopPaymentTable> createState() => _DesktopPaymentTableState();
}

class _DesktopPaymentTableState extends State<_DesktopPaymentTable> {
  // docId -> local (unsaved) status selection, owned by State so it's stable
  // across rebuilds instead of recreated per build.
  final Map<String, ValueNotifier<String>> _statusNotifiers = {};

  ValueNotifier<String> _notifierFor(Payment p) => _statusNotifiers.putIfAbsent(
    p.docId,
    () => ValueNotifier<String>(p.status),
  );

  @override
  void didUpdateWidget(_DesktopPaymentTable old) {
    super.didUpdateWidget(old);
    // Drop notifiers for rows no longer present (filtered out / deleted) to
    // avoid an unbounded memory leak across many stream emissions.
    final currentIds = widget.payments.map((p) => p.docId).toSet();
    _statusNotifiers.removeWhere((id, notifier) {
      final stale = !currentIds.contains(id);
      if (stale) notifier.dispose();
      return stale;
    });
  }

  @override
  void dispose() {
    for (final n in _statusNotifiers.values) {
      n.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DataTable(
      showCheckboxColumn: false,

      headingRowColor: WidgetStateProperty.all(const Color(0xFF790600)),
      columns: [
        DataColumn(
          label: AppText(txt: 'Gym ID', fontSize: AppFontSize.f12),
        ),
        DataColumn(
          label: AppText(txt: 'Invoice ID', fontSize: AppFontSize.f12),
        ),
        DataColumn(
          label: AppText(txt: 'Member', fontSize: AppFontSize.f12),
        ),
        DataColumn(
          label: AppText(txt: 'Plan', fontSize: AppFontSize.f12),
        ),
        DataColumn(
          label: AppText(txt: 'Fees', fontSize: AppFontSize.f12),
        ),
        DataColumn(
          label: AppText(txt: 'Method', fontSize: AppFontSize.f12),
        ),
        DataColumn(
          label: AppText(txt: 'Date', fontSize: AppFontSize.f12),
        ),
        DataColumn(
          label: AppText(txt: 'Status', fontSize: AppFontSize.f12),
        ),
        DataColumn(
          label: AppText(txt: 'Action', fontSize: AppFontSize.f12),
        ),
      ],
      rows: widget.payments
          .map(
            (p) =>
                _buildPaymentRow(context, p, widget.members, _notifierFor(p)),
          )
          .toList(),
    );
  }

  static DataRow _buildPaymentRow(
    BuildContext context,
    Payment p,
    List<dynamic> members,

    ValueNotifier<String> statusNotifier,
  ) {
    final paymentMemberId = p.memberId.toString().trim();

    final isMemberExists = members.any((member) {
      final memberId = member.docId.toString().trim();

      debugPrint("DESKTOP PAYMENT MEMBER ID => $paymentMemberId");
      debugPrint("DESKTOP MEMBER DOC ID => $memberId");
      debugPrint("DESKTOP COMPARE => $memberId == $paymentMemberId");

      return memberId == paymentMemberId;
    });

    debugPrint("DESKTOP RESULT => $paymentMemberId : $isMemberExists");
    return DataRow(
      onSelectChanged: (selected) {
        if (selected != true) return;
        _navigateToMemberPaymentHistory(context, p);
      },
      key: ValueKey(p.docId),
      cells: [
        DataCell(
          AppText(
            txt: p.gymId,
            fontSize: AppFontSize.f12,
            fontWeight: FontWeight.w700,
          ),
        ),
        DataCell(
          AppText(
            txt: p.invoiceId,
            fontSize: AppFontSize.f12,
            color: const Color(0xFF6B7280),
          ),
        ),
        DataCell(
          AppText(
            txt: p.member,
            fontSize: AppFontSize.f13,
            fontWeight: FontWeight.w500,
          ),
        ),
        DataCell(_PlanChip(plan: p.plan)),
        DataCell(
          Text(
            'Rs. ${p.amount.toInt()}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColor.cFFFFFF,
            ),
          ),
        ),
        DataCell(
          Text(
            p.method,
            style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
          ),
        ),
        DataCell(
          Text(
            p.date,
            style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
          ),
        ),
        DataCell(
          isMemberExists
              ? _StatusDropdownCell(payment: p, statusNotifier: statusNotifier)
              : StatusBadge(status: "Deleted"),

          // _StatusDropdownCell(payment: p, statusNotifier: statusNotifier),
        ),
        DataCell(
          isMemberExists
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _SaveButtonCell(payment: p, statusNotifier: statusNotifier),
                    if (p.status.toLowerCase() == 'pending' ||
                        p.status.toLowerCase() == 'overdue') ...[
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(
                          Icons.payments,
                          color: Color(0xFF7C3AED),
                        ),
                        tooltip: 'Pay Fees',
                        onPressed: () => _handlePay(context, p),
                      ),
                    ],
                  ],
                )
              : StatusBadge(status: "Deleted"),

          // Row(
          //   mainAxisSize: MainAxisSize.min,
          //   children: [
          //     _SaveButtonCell(payment: p, statusNotifier: statusNotifier),
          //     if (p.status.toLowerCase() == 'pending' ||
          //         p.status.toLowerCase() == 'overdue') ...[
          //       const SizedBox(width: 8),
          //       IconButton(
          //         icon: const Icon(Icons.payments, color: Color(0xFF7C3AED)),
          //         tooltip: 'Pay Fees',
          //         onPressed: () => _handlePay(context, p),
          //       ),
          //     ],
          //   ],
          // ),
        ),
      ],
    );
  }

  static Future<void> _navigateToMemberPaymentHistory(
    BuildContext context,
    Payment p,
  ) async {
    if (p.memberId.isEmpty) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) =>
          const Center(child: CircularProgressIndicator(color: Colors.white)),
    );

    try {
      // 1. Try to find the member in the members collection first.
      final memberDoc = await FirebaseFirestore.instance
          .collection('members')
          .doc(p.memberId)
          .get();

      Member? member;

      if (memberDoc.exists && memberDoc.data() != null) {
        member = Member.fromFirestore(memberDoc.data()!, memberDoc.id);
      } else {
        // 2. Member record is gone — check if payment history still exists
        //    for this memberId in the payments collection.
        final paymentsQuery = await FirebaseFirestore.instance
            .collection('payments')
            .where('memberId', isEqualTo: p.memberId)
            .limit(1)
            .get();

        if (paymentsQuery.docs.isNotEmpty) {
          // Build a minimal fallback Member from the payment's own data,
          // just enough for the payment-history screen to query by memberId.
          member = Member.fromFirestore({
            'name': p.member,
            'gymId': p.gymId,
          }, p.memberId);
        }
      }

      if (context.mounted) Navigator.pop(context); // close loading dialog

      if (member == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No member or payment record found')),
          );
        }
        return;
      }

      if (context.mounted) {
        Navigator.pushNamed(
          context,
          AppRoutes.memberPaymentHistory,
          arguments: member,
        );
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error fetching member: $e')));
      }
    }
  }

  static Future<void> _handlePay(BuildContext context, Payment p) async {
    if (p.memberId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Member ID missing for this payment')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) =>
          const Center(child: CircularProgressIndicator(color: Colors.white)),
    );

    try {
      final doc = await FirebaseFirestore.instance
          .collection('payments')
          .doc(p.memberId)
          .get();
      if (context.mounted) Navigator.pop(context);

      if (!doc.exists || doc.data() == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Payment not found')));
        }
        return;
      }

      final member = Member.fromFirestore(doc.data()!, doc.id);
      if (context.mounted) {
        MembersScreenHelper.showPaymentDialog(
          context,
          member,
          paymentDocIdToUpdate: p.docId,
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error fetching member: $e')));
      }
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _StatusDropdownCell extends StatefulWidget {
  const _StatusDropdownCell({
    required this.payment,
    required this.statusNotifier,
  });
  final Payment payment;
  final ValueNotifier<String> statusNotifier;

  @override
  State<_StatusDropdownCell> createState() => _StatusDropdownCellState();
}

class _StatusDropdownCellState extends State<_StatusDropdownCell> {
  static String _normalizeStatus(String status) {
    final s = status.trim().toLowerCase();
    if (s == 'paid') return 'Paid';
    if (s == 'pending') return 'Pending';
    if (s == 'overdue') return 'Overdue';
    return 'Pending';
  }

  @override
  void didUpdateWidget(_StatusDropdownCell old) {
    super.didUpdateWidget(old);
    // If Firestore delivers a new status, keep the dropdown in sync
    if (old.payment.status != widget.payment.status) {
      widget.statusNotifier.value = _normalizeStatus(widget.payment.status);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: widget.statusNotifier,
      builder: (_, current, __) {
        final val = ['Paid', 'Pending', 'Overdue'].contains(current)
            ? current
            : _normalizeStatus(current);
        return DropdownButton<String>(
          value: val,
          dropdownColor: AppColor.red,
          underline: const SizedBox(),
          items: [
            DropdownMenuItem(
              value: 'Paid',
              child: AppText(txt: 'Paid'),
            ),
            DropdownMenuItem(
              value: 'Pending',
              child: AppText(txt: 'Pending'),
            ),
            DropdownMenuItem(
              value: 'Overdue',
              child: AppText(txt: 'Overdue'),
            ),
          ],
          onChanged: (v) {
            if (v != null) widget.statusNotifier.value = v;
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _SaveButtonCell extends StatefulWidget {
  const _SaveButtonCell({required this.payment, required this.statusNotifier});
  final Payment payment;
  final ValueNotifier<String> statusNotifier;

  @override
  State<_SaveButtonCell> createState() => _SaveButtonCellState();
}

class _SaveButtonCellState extends State<_SaveButtonCell> {
  bool _loading = false;

  Future<void> _save() async {
    setState(() => _loading = true);

    final newStatus = widget.statusNotifier.value;
    final error = await FirestoreService.instance.updatePaymentStatus(
      paymentDocId: widget.payment.docId,
      newStatus: newStatus,
      paymentDate: widget.payment.date,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error ?? 'Status updated successfully'),
        backgroundColor: error == null
            ? const Color(0xFF059669)
            : const Color(0xFFDC2626),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppButton(
      isLoading: _loading,
      width: cw(25),
      height: ch(33),
      onPressed: _save,
      text: "Save",
      color: AppColor.green,
      buttonColor: AppColor.green,
      textColor: AppColor.cFFFFFF,
    );
  }
}

class _MobilePaymentList extends StatelessWidget {
  const _MobilePaymentList({required this.payments, required this.members});

  final List<Payment> payments;
  final List<dynamic> members;

  @override
  Widget build(BuildContext context) {
    if (payments.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(cw(15.0)),
          child: Text(
            'No payments found',
            style: TextStyle(
              color: const Color(0xFF9CA3AF),
              fontSize: AppFontSize.f15,
            ),
          ),
        ),
      );
    }

    return Column(
      children: payments.map((p) {
        // final memberIds = members
        //     .map((member) => member.docId.toString().trim())
        //     .toSet();

        // final isMemberExists = memberIds.contains(p.memberId.toString().trim());

        debugPrint("PAYMENT MEMBER ID => ${p.memberId}");
        debugPrint("MEMBERS => $members");

        final paymentMemberId = p.memberId.toString().trim();

        final isMemberExists = members.any((member) {
          final memberId = member.docId.toString().trim();

          debugPrint("MEMBER DOC ID => $memberId");
          debugPrint("COMPARE => $memberId == $paymentMemberId");

          return memberId == paymentMemberId;
        });

        debugPrint("RESULT => $paymentMemberId : $isMemberExists");

        return _MobilePaymentCard(
          key: ValueKey(p.docId),
          payment: p,
          isMemberExists: isMemberExists,
        );
      }).toList(),
    );
  }
}
// ─────────────────────────────────────────────────────────────────────────────
// class _MobilePaymentList extends StatelessWidget {
//   const _MobilePaymentList({required this.payments, required this.members});
//   final List<Payment> payments;
//   final List<dynamic> members;

//   @override
//   Widget build(BuildContext context) {

//     if (payments.isEmpty) {
//       return Center(
//         child: Padding(
//           padding: EdgeInsets.all(cw(15.0)),
//           child: Text(
//             'No payments found',
//             style: TextStyle(
//               color: const Color(0xFF9CA3AF),
//               fontSize: AppFontSize.f15,
//             ),
//           ),
//         ),
//       );
//     }
//     return Column(
//       children: payments
//           // Key by docId so state (selected status, saving flag) is
//           // correctly re-associated with the right card if the list order
//           // changes (sort/filter), instead of by position.
//           .map((p) => _MobilePaymentCard(key: ValueKey(p.docId), payment: p,
//           isMemberExists: ,
//           ))
//           .toList(),
//     );
//   }
// }

class _MobilePaymentCard extends StatefulWidget {
  const _MobilePaymentCard({
    super.key,
    required this.payment,

    required this.isMemberExists,
  });
  final Payment payment;
  final bool isMemberExists;

  @override
  State<_MobilePaymentCard> createState() => _MobilePaymentCardState();
}

class _MobilePaymentCardState extends State<_MobilePaymentCard> {
  late String _selectedStatus;
  bool _saving = false;

  static String _normalizeStatus(String status) {
    final s = status.trim().toLowerCase();
    if (s == 'paid') return 'Paid';
    if (s == 'pending') return 'Pending';
    if (s == 'overdue') return 'Overdue';
    return 'Pending';
  }

  @override
  void initState() {
    super.initState();
    _selectedStatus = _normalizeStatus(widget.payment.status);
  }

  @override
  void didUpdateWidget(_MobilePaymentCard old) {
    super.didUpdateWidget(old);
    if (old.payment.status != widget.payment.status) {
      _selectedStatus = _normalizeStatus(widget.payment.status);
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);

    final error = await FirestoreService.instance.updatePaymentStatus(
      paymentDocId: widget.payment.docId,
      newStatus: _selectedStatus,
      paymentDate: widget.payment.date,
    );

    if (!mounted) return;
    setState(() => _saving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error ?? 'Status updated successfully'),
        backgroundColor: error == null
            ? const Color(0xFF059669)
            : const Color(0xFFDC2626),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.payment;

    final isMemberExists = widget.isMemberExists;

    return Container(
      margin: EdgeInsets.only(bottom: ch(9.7)),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () =>
              _DesktopPaymentTableState._navigateToMemberPaymentHistory(
                context,
                p,
              ),
          child: Padding(
            padding: EdgeInsets.all(cw(11.2)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        AppText(
                          txt: 'Gym ID: ${p.gymId}',
                          // style: TextStyle(
                          fontSize: AppFontSize.f11,
                          fontWeight: FontWeight.w600,
                          color: AppColor.cFFFFFF,
                        ),
                        // ),
                        SizedBox(width: cw(5.0)),
                        AppText(
                          txt: p.invoiceId,
                          // style: TextStyle(
                          fontSize: AppFontSize.f11,
                          // fontFamily: 'monospace',
                          color: const Color(0xFF9CA3AF),
                          // ),
                        ),
                      ],
                    ),

                    if (isMemberExists)
                      StatusBadge(status: p.status)
                    else
                      StatusBadge(status: "Deleted"),

                    // Container(height: 100, width: 200, color: AppColor.blue),
                  ],
                ),
                SizedBox(height: ch(5)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppText(
                      txt: p.member,
                      // style: TextStyle(
                      fontSize: AppFontSize.f15,
                      fontWeight: FontWeight.w600,
                      color: AppColor.cFFFFFF,
                      // ),
                    ),
                    AppText(
                      txt: 'Rs. ${p.amount.toInt()}',
                      // style: TextStyle(
                      fontSize: AppFontSize.f14,
                      fontWeight: FontWeight.w700,
                      color: AppColor.cFFFFFF,
                    ),
                    // ),
                  ],
                ),
                SizedBox(height: ch(6)),
                Row(
                  children: [
                    _PlanChip(plan: p.plan),
                    SizedBox(width: cw(7.5)),
                    Row(
                      children: [
                        Icon(
                          Icons.credit_card_outlined,
                          size: cw(20),
                          color: Color(0xFF9CA3AF),
                        ),
                        SizedBox(width: cw(4)),
                        AppText(
                          txt: p.method,
                          // style: TextStyle(
                          fontSize: AppFontSize.f12,
                          color: const Color(0xFF6B7280),
                          // ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: ch(8)),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 12,
                      color: AppColor.cFFFFFF,
                    ),
                    SizedBox(width: cw(4)),
                    AppText(
                      txt: 'Paid: ${p.date}',
                      // style: TextStyle(
                      fontSize: AppFontSize.f10,
                      color: AppColor.cFFFFFF,
                      // ),
                    ),
                  ],
                ),
                SizedBox(height: ch(10)),

                if (isMemberExists)
                  Row(
                    children: [
                      SizedBox(
                        width: cw(170),
                        child: DropdownButtonFormField<String>(
                          style: TextStyle(
                            fontSize: AppFontSize.f15,
                            color: AppColor.cFFFFFF,
                          ),
                          initialValue: _selectedStatus,
                          dropdownColor: AppColor.red,
                          decoration: customInputDecoration(label: 'Status')
                              .copyWith(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                          items: [
                            DropdownMenuItem(
                              value: 'Paid',
                              child: AppText(
                                txt: 'Paid',
                                fontSize: AppFontSize.f14,
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'Pending',
                              child: AppText(
                                txt: 'Pending',
                                fontSize: AppFontSize.f14,
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'Overdue',
                              child: AppText(
                                txt: 'Overdue',
                                fontSize: AppFontSize.f14,
                              ),
                            ),
                          ],
                          onChanged: (v) {
                            if (v != null) setState(() => _selectedStatus = v);
                          },
                        ),
                      ),
                      Spacer(),
                      ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: 100,
                          minWidth: 50,
                        ),
                        child: AppButton(
                          progressSize: 5,
                          isLoading: _saving,
                          width: cw(30),
                          onPressed: _save,
                          text: "Save",
                          fontSize: AppFontSize.f11,
                          color: AppColor.green,
                          textColor: AppColor.cFFFFFF,
                        ),
                      ),
                      if (p.status.toLowerCase() == 'pending' ||
                          p.status.toLowerCase() == 'overdue') ...[
                        SizedBox(width: cw(10)),
                        IconButton(
                          icon: const Icon(
                            Icons.payments,
                            color: Color(0xFF7C3AED),
                          ),
                          tooltip: 'Pay Fees',
                          onPressed: () =>
                              _DesktopPaymentTableState._handlePay(context, p),
                        ),
                      ],
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.sub,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    this.isRupeeIcon = false,
  });
  final String title, value, sub;
  final IconData icon;
  final bool isRupeeIcon;
  final Color iconColor, iconBg;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: EdgeInsets.all(cw(11.2)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                  // ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(cw(5.6)),
                decoration: BoxDecoration(
                  gradient: AppGradients.redGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: isRupeeIcon
                    ? AppText(txt: "Rs")
                    : Icon(
                        icon,
                        size: cw(9.4).clamp(14.0, 20.0),
                        color: AppColor.cFFFFFF,
                      ),
              ),
            ],
          ),
          SizedBox(height: ch(8.1)),
          AppText(
            txt: value,
            // style: TextStyle(
            fontSize: AppFontSize.f16,
            fontWeight: FontWeight.w700,
            color: AppColor.cFFFFFF,
            // ),
          ),
          SizedBox(height: ch(5)),
          AppText(txt: sub, fontSize: AppFontSize.f14, color: iconColor),
        ],
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
class _PlanChip extends StatelessWidget {
  const _PlanChip({required this.plan});
  final String plan;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: const Color(0xFFF5F3FF),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      plan,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColor.blue2,
      ),
    ),
  );
}
