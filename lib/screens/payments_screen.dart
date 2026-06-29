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

// ─────────────────────────────────────────────────────────────────────────────
// Payments Screen — fully driven by a Firestore snapshot stream.
// Any payment write (from any device, or directly in the Firestore console)
// appears automatically. No manual refresh is ever needed.
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

            // ── Header ────────────────────────────────────────────────────────
            phone
                ? Column(
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
                        color: const Color(0xFF6B7280),
                      ),
                      SizedBox(height: ch(12.2)),
                      AppButton(
                        width: 100,
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  Icon(Icons.av_timer, color: AppColor.cFFFFFF),
                                  SizedBox(width: cw(5)),
                                  AppText(txt: 'Coming Soon!'),
                                ],
                              ),
                              backgroundColor: AppColor.blue2,
                            ),
                          );
                        },
                        isRow: true,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.download_outlined,
                              size: 18,
                              color: AppColor.cFFFFFF,
                            ),
                            SizedBox(width: 5),
                            AppText(
                              txt: 'Export',
                              fontSize: AppFontSize.f12,
                              fontWeight: FontWeight.w600,
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
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
                            color: AppColor.themeGrey,
                          ),
                        ],
                      ),
                      AppButton(
                        width: 100,
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  Icon(Icons.av_timer, color: AppColor.cFFFFFF),
                                  SizedBox(width: cw(5)),
                                  AppText(txt: 'Coming Soon!'),
                                ],
                              ),
                              backgroundColor: AppColor.blue2,
                            ),
                          );
                        },
                        isRow: true,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.download_outlined,
                              size: 18,
                              color: AppColor.cFFFFFF,
                            ),
                            SizedBox(width: 5),
                            AppText(
                              txt: 'Export',
                              fontSize: AppFontSize.f12,
                              fontWeight: FontWeight.w600,
                            ),
                          ],
                        ),
                      ),
                      // OutlinedButton.icon(
                      //   icon: const Icon(Icons.download_outlined, size: 18),
                      //   label: AppText(
                      //     txt: 'Export',
                      //     fontSize: AppFontSize.f12,
                      //   ),
                      //   onPressed: () {},
                      // ),
                    ],
                  ),

            SizedBox(height: ch(20)),

            // ── Everything below is inside one StreamBuilder ─────────────────
            // The stream emits a new List<Payment> on every Firestore change.
            StreamBuilder<List<Payment>>(
              stream: FirestoreService.instance.paymentsStream(),
              builder: (context, snapshot) {
                // Loading
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 64),
                      child: CircularProgressIndicator(color: AppColor.cFFFFFF),
                    ),
                  );
                }

                // Error
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

                // Live aggregates — computed from the stream data, not stored values.
                final totalRevenue = allPayments
                    .where((p) => p.status == 'Paid')
                    .fold<double>(0, (s, p) => s + p.amount);
                final pendingCount = allPayments
                    .where((p) => p.status == 'Pending')
                    .length;
                final pendingTotal = allPayments
                    .where((p) => p.status == 'Pending')
                    .fold<double>(0, (s, p) => s + p.amount);
                final overdueCount = allPayments
                    .where((p) => p.status == 'Overdue')
                    .length;
                final overdueTotal = allPayments
                    .where((p) => p.status == 'Overdue')
                    .fold<double>(0, (s, p) => s + p.amount);
                final now = DateTime.now();
                final paidThisMonth = allPayments
                    .where(
                      (p) => p.status == 'Paid' && _isThisMonth(p.date, now),
                    )
                    .length;

                return Column(
                  children: [
                    // ── Summary stat cards ────────────────────────────────────
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

                    // ── Search/filter + payment list ───────────────────────────
                    Consumer<PaymentsProvider>(
                      builder: (context, paymentsState, _) {
                        final filtered = paymentsState.filtered(allPayments);

                        return Column(
                          children: [
                            // Filter card
                            Card(
                              child: Padding(
                                padding: EdgeInsets.all(cw(11.2)),
                                child: phone
                                    ? Column(
                                        children: [
                                          _searchField(paymentsState),
                                          SizedBox(height: ch(9.7)),
                                          _statusDropdown(
                                            paymentsState,
                                            isExpanded: true,
                                          ),
                                        ],
                                      )
                                    : Row(
                                        children: [
                                          Expanded(
                                            child: _searchField(paymentsState),
                                          ),
                                          SizedBox(width: cw(7.5)),
                                          SizedBox(
                                            width: 160,
                                            child: _statusDropdown(
                                              paymentsState,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),

                            SizedBox(height: ch(12.2)),

                            // Payment list card
                            Card(
                              child: Padding(
                                padding: EdgeInsets.all(cw(11.2)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        AppText(
                                          txt:
                                              'Payment History (${filtered.length})',
                                          fontSize: AppFontSize.f13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        if (filtered.isEmpty &&
                                            (paymentsState.search.isNotEmpty ||
                                                paymentsState.filterStatus !=
                                                    'all'))
                                          AppButton(
                                            width: cw(35),
                                            onPressed: () {
                                              paymentsState.setSearch('');
                                              paymentsState.setFilterStatus(
                                                'all',
                                              );
                                            },
                                            isRow: true,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                CircleAvatar(
                                                  radius: cw(2),
                                                  backgroundColor:
                                                      AppColor.cFFFFFF,
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
                                            text: "Clear filters",
                                          ),
                                        // TextButton.icon(
                                        //   onPressed: () {
                                        //     paymentsState.setSearch('');
                                        //     paymentsState.setFilterStatus(
                                        //       'all',
                                        //     );
                                        //   },
                                        //   icon: const Icon(
                                        //     Icons.clear,
                                        //     size: 14,
                                        //   ),
                                        //   label: AppText(
                                        //     txt: 'Clear filters',
                                        //     fontSize: AppFontSize.f11,
                                        //   ),
                                        // ),
                                      ],
                                    ),
                                    SizedBox(height: ch(12.2)),
                                    phone
                                        ? _MobilePaymentList(payments: filtered)
                                        : filtered.isEmpty
                                        ? Padding(
                                            padding: EdgeInsets.symmetric(
                                              vertical: ch(30),
                                            ),
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
                                                    color: const Color(
                                                      0xFF9CA3AF,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                        : SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: _DesktopPaymentTable(
                                              payments: filtered,
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
              },
            ),

            SizedBox(height: ch(16.2)),
          ],
        ),
      ),
    );
  }

  /// Returns `true` if the payment date string "YYYY-MM-DD" falls in the same
  /// calendar month as [reference].
  static bool _isThisMonth(String dateStr, DateTime reference) {
    if (dateStr.isEmpty) return false;
    try {
      final d = DateTime.parse(dateStr);
      return d.year == reference.year && d.month == reference.month;
    } catch (_) {
      return false;
    }
  }

  static Widget _searchField(PaymentsProvider state) => primaryTextField(
    hintText: "Search member or invoice...",

    prefixIcon: const Icon(Icons.search, size: 18, color: Color(0xFF9CA3AF)),

    onChanged: state.setSearch,
  );
  //  TextField(
  //   decoration: customInputDecoration(label: 'Search member or invoice...')
  //       .copyWith(
  //         prefixIcon: const Icon(
  //           Icons.search,
  //           size: 18,
  //           color: Color(0xFF9CA3AF),
  //         ),
  //       ),
  //   onChanged: state.setSearch,
  // );

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

// ─────────────────────────────────────────────────────────────────────────────
// Desktop DataTable — each row has a status dropdown (local state) + Save button.
// The Save button writes to Firestore; because the screen is stream-driven,
// the change reflects everywhere with no manual reload.
// ─────────────────────────────────────────────────────────────────────────────
class _DesktopPaymentTable extends StatelessWidget {
  const _DesktopPaymentTable({required this.payments});
  final List<Payment> payments;

  @override
  Widget build(BuildContext context) {
    return DataTable(
      headingRowColor: WidgetStateProperty.all(Color(0xFF790600)),
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
      rows: payments.map((p) => _buildPaymentRow(p)).toList(),
    );
  }

  static DataRow _buildPaymentRow(Payment p) {
    // One ValueNotifier per row — shared between the dropdown cell and Save cell.
    // This is created once per row widget and not recreated on rebuild.
    final statusNotifier = ValueNotifier<String>(p.status);

    return DataRow(
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
        // Dropdown — changes local ValueNotifier only, no Firestore write.
        DataCell(
          _StatusDropdownCell(payment: p, statusNotifier: statusNotifier),
        ),
        // Save — reads from ValueNotifier and writes to Firestore.
        DataCell(_SaveButtonCell(payment: p, statusNotifier: statusNotifier)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Status dropdown cell — selection stored in the shared [statusNotifier].
// No Firestore write happens here — the companion [_SaveButtonCell] writes.
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
  void initState() {
    super.initState();
    // Sync notifier with initial payment status.
    widget.statusNotifier.value = widget.payment.status;
  }

  @override
  void didUpdateWidget(_StatusDropdownCell old) {
    super.didUpdateWidget(old);
    // When the Firestore stream delivers an update and the user hasn't changed
    // the selection locally, sync the notifier to the new stored value.
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
        // Only updates the notifier — no Firestore write.
        onChanged: (v) {
          if (v != null) widget.statusNotifier.value = v;
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Save button — reads from [statusNotifier] and writes to Firestore.
// Shows a CircularProgressIndicator while the write is in-flight.
// Displays a success/error SnackBar on completion.
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
      // member: omitted here — admin-correction member update can be wired
      // as a follow-up enhancement with a member docId lookup.
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
    //     _loading
    //         ?  SizedBox(
    //             width: 20,
    //             height: 20,
    //             child: CircularProgressIndicator(
    //               strokeWidth: 2,
    // color: AppColor.cFFFFFF,            ),
    //           )
    //         : TextButton(
    //             onPressed: _save,
    //             style: TextButton.styleFrom(
    //               foregroundColor: const Color(0xFF2563EB),
    //               padding: const EdgeInsets.symmetric(horizontal: 8),
    //             ),
    //             child: const Text('Save', style: TextStyle(fontSize: 12)),
    //           );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Mobile payment card list — with inline status dropdown + Save button
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
      children: payments.map((p) => _MobilePaymentCard(payment: p)).toList(),
    );
  }
}

class _MobilePaymentCard extends StatefulWidget {
  const _MobilePaymentCard({required this.payment});
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
    // Sync when the stream delivers a new snapshot (only if not mid-edit).
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
          // Row 1: Gym ID + Invoice + Status badge
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

          // Row 2: Member + Amount
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

          // Row 3: Plan + Method
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

          // Row 4: Date
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

          // Row 5: Status dropdown + Save button
          // Dropdown changes are LOCAL only — Save button writes to Firestore.
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
              // _saving
              //     ? const SizedBox(
              //         width: 24,
              //         height: 24,
              //         child: CircularProgressIndicator(
              //           strokeWidth: 2,
              //           color: AppColor.cFFFFFF,
              //         ),
              //       )
              //     : FilledButton(
              //         onPressed: _save,
              //         style: FilledButton.styleFrom(
              //           backgroundColor: AppColor.green,
              //           padding: const EdgeInsets.symmetric(
              //             horizontal: 16,
              //             vertical: 10,
              //           ),
              //         ),
              //         child: const Text('Save', style: TextStyle(fontSize: 12)),
              //       ),
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
