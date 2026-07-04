import 'package:app/providers/payment_provider.dart';
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
                return _PaymentsBody(phone: phone, allPayments: allPayments);
              },
            ),

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
        SizedBox(height: ch(4)),
        AppText(
          txt: 'Track membership fees and billing',
          fontSize: AppFontSize.f13,
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
      children: [titleBlock, _exportButton(context)],
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
  const _PaymentsBody({required this.phone, required this.allPayments});
  final bool phone;
  final List<Payment> allPayments;

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
    final paidThisMonth = allPayments
        .where((p) => p.status == 'Paid' && _isThisMonth(p.date, now))
        .length;

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
                    sub: 'of ${allPayments.length} total',
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
                            ],
                          )
                        : Row(
                            children: [
                              Expanded(child: _searchField(paymentsState)),
                              SizedBox(width: cw(7.5)),
                              SizedBox(
                                width: 160,
                                child: _statusDropdown(paymentsState),
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
                              fontSize: AppFontSize.f13,
                              fontWeight: FontWeight.w600,
                            ),
                            if (filtered.isEmpty &&
                                (paymentsState.search.isNotEmpty ||
                                    paymentsState.filterStatus != 'all'))
                              InkWell(
                                onTap: () {
                                  paymentsState.searchTextFieldCntrl.clear();
                                  paymentsState.setSearch('');
                                  paymentsState.setFilterStatus('all');
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
                        phone
                            ? _MobilePaymentList(payments: filtered)
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
                                        fontSize: AppFontSize.f13,
                                        color: const Color(0xFF9CA3AF),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: _DesktopPaymentTable(payments: filtered),
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
  const _DesktopPaymentTable({required this.payments});
  final List<Payment> payments;

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
          .map((p) => _buildPaymentRow(context, p, _notifierFor(p)))
          .toList(),
    );
  }

  static DataRow _buildPaymentRow(
    BuildContext context,
    Payment p,
    ValueNotifier<String> statusNotifier,
  ) {
    return DataRow(
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
          _StatusDropdownCell(payment: p, statusNotifier: statusNotifier),
        ),
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _SaveButtonCell(payment: p, statusNotifier: statusNotifier),
              if (p.status.toLowerCase() == 'pending' ||
                  p.status.toLowerCase() == 'overdue') ...[
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.payments, color: Color(0xFF7C3AED)),
                  tooltip: 'Pay Fees',
                  onPressed: () => _handlePay(context, p),
                ),
              ],
            ],
          ),
        ),
      ],
    );
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
          .collection('members')
          .doc(p.memberId)
          .get();
      if (context.mounted) Navigator.pop(context);

      if (!doc.exists || doc.data() == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Member not found')));
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
  @override
  void didUpdateWidget(_StatusDropdownCell old) {
    super.didUpdateWidget(old);
    // If Firestore delivers a new status and the user hasn't made an unsaved
    // local edit, keep the dropdown in sync with the stored value.
    if (old.payment.status != widget.payment.status &&
        widget.statusNotifier.value == old.payment.status) {
      widget.statusNotifier.value = widget.payment.status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: widget.statusNotifier,
      builder: (_, current, __) => DropdownButton<String>(
        value: current,
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
      ),
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

// ─────────────────────────────────────────────────────────────────────────────
class _MobilePaymentList extends StatelessWidget {
  const _MobilePaymentList({required this.payments});
  final List<Payment> payments;

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
              fontSize: AppFontSize.f12,
            ),
          ),
        ),
      );
    }
    return Column(
      children: payments
          // Key by docId so state (selected status, saving flag) is
          // correctly re-associated with the right card if the list order
          // changes (sort/filter), instead of by position.
          .map((p) => _MobilePaymentCard(key: ValueKey(p.docId), payment: p))
          .toList(),
    );
  }
}

class _MobilePaymentCard extends StatefulWidget {
  const _MobilePaymentCard({super.key, required this.payment});
  final Payment payment;

  @override
  State<_MobilePaymentCard> createState() => _MobilePaymentCardState();
}

class _MobilePaymentCardState extends State<_MobilePaymentCard> {
  late String _selectedStatus;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.payment.status;
  }

  @override
  void didUpdateWidget(_MobilePaymentCard old) {
    super.didUpdateWidget(old);
    if (old.payment.status != widget.payment.status &&
        _selectedStatus == old.payment.status) {
      _selectedStatus = widget.payment.status;
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
    return Container(
      margin: EdgeInsets.only(bottom: ch(9.7)),
      padding: EdgeInsets.all(cw(11.2)),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'Gym ID: ${p.gymId}',
                    style: TextStyle(
                      fontSize: AppFontSize.f11,
                      fontWeight: FontWeight.w600,
                      color: AppColor.cFFFFFF,
                    ),
                  ),
                  SizedBox(width: cw(8.0)),
                  Text(
                    p.invoiceId,
                    style: TextStyle(
                      fontSize: AppFontSize.f11,
                      fontFamily: 'monospace',
                      color: const Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
              StatusBadge(status: p.status),
            ],
          ),
          SizedBox(height: ch(4.1)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                p.member,
                style: TextStyle(
                  fontSize: AppFontSize.f14,
                  fontWeight: FontWeight.w600,
                  color: AppColor.cFFFFFF,
                ),
              ),
              Text(
                'Rs. ${p.amount.toInt()}',
                style: TextStyle(
                  fontSize: AppFontSize.f14,
                  fontWeight: FontWeight.w700,
                  color: AppColor.cFFFFFF,
                ),
              ),
            ],
          ),
          SizedBox(height: ch(6.5)),
          Row(
            children: [
              _PlanChip(plan: p.plan),
              SizedBox(width: cw(7.5)),
              Row(
                children: [
                  const Icon(
                    Icons.credit_card_outlined,
                    size: 12,
                    color: Color(0xFF9CA3AF),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    p.method,
                    style: TextStyle(
                      fontSize: AppFontSize.f11,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: ch(4.1)),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 12,
                color: AppColor.cFFFFFF,
              ),
              const SizedBox(width: 4),
              Text(
                'Paid: ${p.date}',
                style: TextStyle(
                  fontSize: AppFontSize.f10,
                  color: AppColor.cFFFFFF,
                ),
              ),
            ],
          ),
          SizedBox(height: ch(10)),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedStatus,
                  dropdownColor: AppColor.red,
                  decoration: customInputDecoration(label: 'Status').copyWith(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
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
                    if (v != null) setState(() => _selectedStatus = v);
                  },
                ),
              ),
              SizedBox(width: cw(8)),
              AppButton(
                progressSize: 5,
                isLoading: _saving,
                width: cw(35),
                onPressed: _save,
                text: "Save",
                color: AppColor.green,
                textColor: AppColor.cFFFFFF,
              ),
              if (p.status.toLowerCase() == 'pending' ||
                  p.status.toLowerCase() == 'overdue') ...[
                SizedBox(width: cw(8)),
                IconButton(
                  icon: const Icon(Icons.payments, color: Color(0xFF7C3AED)),
                  tooltip: 'Pay Fees',
                  onPressed: () =>
                      _DesktopPaymentTableState._handlePay(context, p),
                ),
              ],
            ],
          ),
        ],
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
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: AppFontSize.f11,
                    color: AppColor.cFFFFFF,
                  ),
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
          Text(
            value,
            style: TextStyle(
              fontSize: AppFontSize.f16,
              fontWeight: FontWeight.w700,
              color: AppColor.cFFFFFF,
            ),
          ),
          SizedBox(height: ch(2.4)),
          Text(
            sub,
            style: TextStyle(fontSize: AppFontSize.f9, color: iconColor),
          ),
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
