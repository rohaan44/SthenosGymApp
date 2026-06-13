import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/gym_provider.dart';
import '../shared_widgets.dart';
import '../ui/helpers/app_layout_helper.dart';
import 'package:app/ui/helpers/font_size_helper.dart';


class PaymentsState extends ChangeNotifier {
  String _search = '';
  String _filterStatus = 'all';

  String get search => _search;
  String get filterStatus => _filterStatus;

  void setSearch(String value) {
    _search = value;
    notifyListeners();
  }

  void setFilterStatus(String value) {
    _filterStatus = value;
    notifyListeners();
  }

  static const Map<String, double> planAmounts = {
    'Basic': 50,
    'Standard': 80,
    'Premium': 120,
  };

  List<Payment> filtered(List<Payment> payments) => payments.where((p) {
        final matchSearch = p.member.toLowerCase().contains(_search.toLowerCase()) ||
            p.invoiceId.toLowerCase().contains(_search.toLowerCase());
        final matchStatus =
            _filterStatus == 'all' || p.status.toLowerCase() == _filterStatus.toLowerCase();
        return matchSearch && matchStatus;
      }).toList();
}

class PaymentsScreen extends StatelessWidget {
  const PaymentsScreen({super.key});

  double _totalRevenue(List<Payment> payments) =>
      payments.where((p) => p.status == 'Paid').fold(0, (s, p) => s + p.amount);
  double _totalPending(List<Payment> payments) =>
      payments.where((p) => p.status == 'Pending').fold(0, (s, p) => s + p.amount);
  double _totalOverdue(List<Payment> payments) =>
      payments.where((p) => p.status == 'Overdue').fold(0, (s, p) => s + p.amount);

  void _showAddDialog(BuildContext context) {
    final provider = context.read<GymProvider>();
    String member = provider.members.isNotEmpty ? provider.members.first.name : '';
    String plan = 'Basic';
    String method = 'Credit Card';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Record New Payment'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              DropdownButtonFormField<String>(
                initialValue: member.isEmpty ? null : member,
                decoration: customInputDecoration('Member'),
                items: provider.members
                    .map((m) => DropdownMenuItem(value: m.name, child: Text(m.name)))
                    .toList(),
                onChanged: (v) => setS(() => member = v!),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: plan,
                decoration: customInputDecoration('Plan'),
                items: PaymentsState.planAmounts.entries
                    .map((e) => DropdownMenuItem(
                        value: e.key, child: Text('${e.key} — \$${e.value.toInt()}/mo')))
                    .toList(),
                onChanged: (v) => setS(() => plan = v!),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(8)),
                child: Row(children: [
                  const Icon(Icons.info_outline, size: 16, color: Color(0xFF2563EB)),
                  const SizedBox(width: 8),
                  Text('Amount: \$${PaymentsState.planAmounts[plan]!.toInt()}',
                      style: const TextStyle(
                          color: Color(0xFF2563EB), fontSize: 13, fontWeight: FontWeight.w500)),
                ]),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: method,
                decoration: customInputDecoration('Payment Method'),
                items: ['Credit Card', 'Bank Transfer', 'Cash']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setS(() => method = v!),
              ),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFF2563EB)),
              onPressed: () {
                final now = DateTime.now();
                final dateStr = '${_month(now.month)} ${now.day}, ${now.year}';
                provider.addPayment(Payment(
                  id: provider.payments.length + 1,
                  member: member,
                  amount: PaymentsState.planAmounts[plan]!,
                  plan: plan,
                  method: method,
                  status: 'Paid',
                  date: dateStr,
                  dueDate: dateStr,
                  invoiceId:
                      'INV-${(provider.payments.length + 1).toString().padLeft(3, '0')}',
                ));
                Navigator.pop(ctx);
              },
              child: const Text('Record Payment'),
            ),
          ],
        ),
      ),
    );
  }

  String _month(int m) =>
      ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][m - 1];

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PaymentsState(),
      child: Consumer<PaymentsState>(
        builder: (context, state, child) {
          final provider = context.watch<GymProvider>();
          final payments = provider.payments;
          final filtered = state.filtered(payments);
          final paidCount = payments.where((p) => p.status == 'Paid').length;
          final phone = isPhone(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SingleChildScrollView(
        padding: pagePadding(context),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(height: ch(8.1)),

          // ── Header ────────────────────────────────────────────────────────
          phone
              ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Payments',
                      style: TextStyle(
                          fontSize: AppFontSize.f19,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF111827))),
                  Text('Track membership fees and billing',
                      style: TextStyle(fontSize: AppFontSize.f12, color: const Color(0xFF6B7280))),
                  SizedBox(height: ch(12.2)),
                  Row(children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.download_outlined, size: 18),
                        label: const Text('Export'),
                        onPressed: () {},
                      ),
                    ),
                    SizedBox(width: cw(7.5)),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => _showAddDialog(context),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Record'),
                        style: FilledButton.styleFrom(backgroundColor: const Color(0xFF2563EB)),
                      ),
                    ),
                  ]),
                ])
              : Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Payments',
                        style: TextStyle(
                            fontSize: AppFontSize.f19,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF111827))),
                    Text('Track membership fees and billing',
                        style: TextStyle(fontSize: AppFontSize.f12, color: const Color(0xFF6B7280))),
                  ]),
                  Row(children: [
                    OutlinedButton.icon(
                      icon: const Icon(Icons.download_outlined, size: 18),
                      label: const Text('Export'),
                      onPressed: () {},
                    ),
                    SizedBox(width: cw(7.5)),
                    FilledButton.icon(
                      onPressed: () => _showAddDialog(context),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Record Payment'),
                      style: FilledButton.styleFrom(backgroundColor: const Color(0xFF2563EB)),
                    ),
                  ]),
                ]),

          SizedBox(height: ch(20.3)),

          // ── Summary stat cards ────────────────────────────────────────────
          LayoutBuilder(builder: (context, constraints) {
            final crossAxis = constraints.maxWidth > 600 ? 4 : 2;
            final aspectRatio = constraints.maxWidth > 600 ? 1.5 : 1.3;
            return GridView.count(
              crossAxisCount: crossAxis,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: cw(7.5),
              mainAxisSpacing: ch(12.2),
              childAspectRatio: aspectRatio,
              children: [
                _SummaryCard(
                    title: 'Total Revenue',
                    value: '\$${_totalRevenue(payments).toInt()}',
                    sub: '$paidCount payments',
                    icon: Icons.attach_money,
                    iconColor: const Color(0xFF059669),
                    iconBg: const Color(0xFFECFDF5)),
                _SummaryCard(
                    title: 'Pending',
                    value: '\$${_totalPending(payments).toInt()}',
                    sub: '${payments.where((p) => p.status == "Pending").length} invoices',
                    icon: Icons.pending_outlined,
                    iconColor: const Color(0xFFD97706),
                    iconBg: const Color(0xFFFFFBEB)),
                _SummaryCard(
                    title: 'Overdue',
                    value: '\$${_totalOverdue(payments).toInt()}',
                    sub: '${payments.where((p) => p.status == "Overdue").length} members',
                    icon: Icons.warning_amber_outlined,
                    iconColor: const Color(0xFFDC2626),
                    iconBg: const Color(0xFFFEF2F2)),
                _SummaryCard(
                    title: 'Paid This Month',
                    value: '$paidCount',
                    sub: 'of ${payments.length} total',
                    icon: Icons.check_circle_outline,
                    iconColor: const Color(0xFF2563EB),
                    iconBg: const Color(0xFFEFF6FF)),
              ],
            );
          }),

          SizedBox(height: ch(16.2)),

          // ── Filters ───────────────────────────────────────────────────────
          Card(
            child: Padding(
              padding: EdgeInsets.all(cw(11.2)),
              child: phone
                  ? Column(children: [
                      TextField(
                        decoration: customInputDecoration('Search member or invoice...').copyWith(
                          prefixIcon: const Icon(Icons.search, size: 18, color: Color(0xFF9CA3AF)),
                        ),
                        onChanged: (v) => state.setSearch(v),
                      ),
                      SizedBox(height: ch(9.7)),
                      DropdownButtonFormField<String>(
                        initialValue: state.filterStatus,
                        isExpanded: true,
                        decoration: customInputDecoration('Status'),
                        items: const [
                          DropdownMenuItem(value: 'all', child: Text('All Status')),
                          DropdownMenuItem(value: 'paid', child: Text('Paid')),
                          DropdownMenuItem(value: 'pending', child: Text('Pending')),
                          DropdownMenuItem(value: 'overdue', child: Text('Overdue')),
                        ],
                        onChanged: (v) => state.setFilterStatus(v!),
                      ),
                    ])
                  : Row(children: [
                      Expanded(
                        child: TextField(
                          decoration: customInputDecoration('Search member or invoice...').copyWith(
                            prefixIcon:
                                const Icon(Icons.search, size: 18, color: Color(0xFF9CA3AF)),
                          ),
                          onChanged: (v) => state.setSearch(v),
                        ),
                      ),
                      SizedBox(width: cw(7.5)),
                      SizedBox(
                        width: 160,
                        child: DropdownButtonFormField<String>(
                          initialValue: state.filterStatus,
                          decoration: customInputDecoration('Status'),
                          items: const [
                            DropdownMenuItem(value: 'all', child: Text('All Status')),
                            DropdownMenuItem(value: 'paid', child: Text('Paid')),
                            DropdownMenuItem(value: 'pending', child: Text('Pending')),
                            DropdownMenuItem(value: 'overdue', child: Text('Overdue')),
                          ],
                          onChanged: (v) => state.setFilterStatus(v!),
                        ),
                      ),
                    ]),
            ),
          ),

          SizedBox(height: ch(12.2)),

          // ── Payment list ──────────────────────────────────────────────────
          Card(
            child: Padding(
              padding: EdgeInsets.all(cw(11.2)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Payment History (${filtered.length})',
                    style: TextStyle(
                        fontSize: AppFontSize.f13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF111827))),
                SizedBox(height: ch(12.2)),

                // Phone → card list; Tablet/Desktop → DataTable
                phone
                    ? _MobilePaymentList(payments: filtered)
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowColor: WidgetStateProperty.all(const Color(0xFFF9FAFB)),
                          columns: const [
                            DataColumn(label: Text('Invoice', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)))),
                            DataColumn(label: Text('Member', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)))),
                            DataColumn(label: Text('Plan', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)))),
                            DataColumn(label: Text('Amount', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)))),
                            DataColumn(label: Text('Method', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)))),
                            DataColumn(label: Text('Due Date', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)))),
                            DataColumn(label: Text('Paid Date', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)))),
                            DataColumn(label: Text('Status', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)))),
                          ],
                          rows: filtered
                              .map((p) => DataRow(cells: [
                                    DataCell(Text(p.invoiceId,
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontFamily: 'monospace',
                                            color: Color(0xFF6B7280)))),
                                    DataCell(Text(p.member,
                                        style: const TextStyle(
                                            fontSize: 13, fontWeight: FontWeight.w500))),
                                    DataCell(_PlanChip(plan: p.plan)),
                                    DataCell(Text('\$${p.amount.toInt()}',
                                        style: const TextStyle(
                                            fontSize: 13, fontWeight: FontWeight.w600))),
                                    DataCell(Text(p.method,
                                        style: const TextStyle(
                                            fontSize: 13, color: Color(0xFF6B7280)))),
                                    DataCell(Text(p.dueDate,
                                        style: const TextStyle(
                                            fontSize: 13, color: Color(0xFF6B7280)))),
                                    DataCell(Text(p.date,
                                        style: const TextStyle(
                                            fontSize: 13, color: Color(0xFF6B7280)))),
                                    DataCell(StatusBadge(status: p.status)),
                                  ]))
                              .toList(),
                        ),
                      ),
              ]),
            ),
          ),

          SizedBox(height: ch(16.2)),
        ]),
      ),
    );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Mobile payment card list
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
          child: Text('No payments found',
              style: TextStyle(color: const Color(0xFF9CA3AF), fontSize: AppFontSize.f12)),
        ),
      );
    }
    return Column(
      children: payments
          .map((p) => Container(
                margin: EdgeInsets.only(bottom: ch(9.7)),
                padding: EdgeInsets.all(cw(11.2)),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // Row 1: Invoice ID + Status
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(p.invoiceId,
                        style: TextStyle(
                            fontSize: AppFontSize.f11,
                            fontFamily: 'monospace',
                            color: const Color(0xFF9CA3AF))),
                    StatusBadge(status: p.status),
                  ]),
                  SizedBox(height: ch(4.1)),

                  // Row 2: Member name + Amount
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(p.member,
                        style: TextStyle(
                            fontSize: AppFontSize.f14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF111827))),
                    Text('\$${p.amount.toInt()}',
                        style: TextStyle(
                            fontSize: AppFontSize.f14,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF111827))),
                  ]),
                  SizedBox(height: ch(6.5)),

                  // Row 3: Plan + Method
                  Row(children: [
                    _PlanChip(plan: p.plan),
                    SizedBox(width: cw(7.5)),
                    Row(children: [
                      const Icon(Icons.credit_card_outlined, size: 12, color: Color(0xFF9CA3AF)),
                      const SizedBox(width: 4),
                      Text(p.method,
                          style: TextStyle(fontSize: AppFontSize.f11, color: const Color(0xFF6B7280))),
                    ]),
                  ]),
                  SizedBox(height: ch(4.1)),

                  // Row 4: Dates
                  Row(children: [
                    const Icon(Icons.calendar_today_outlined, size: 12, color: Color(0xFF9CA3AF)),
                    const SizedBox(width: 4),
                    Text('Due: ${p.dueDate}',
                        style: TextStyle(fontSize: AppFontSize.f10, color: const Color(0xFF9CA3AF))),
                    SizedBox(width: cw(11.2)),
                    const Icon(Icons.check_outlined, size: 12, color: Color(0xFF9CA3AF)),
                    const SizedBox(width: 4),
                    Text('Paid: ${p.date}',
                        style: TextStyle(fontSize: AppFontSize.f10, color: const Color(0xFF9CA3AF))),
                  ]),
                ]),
              ))
          .toList(),
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
  });
  final String title, value, sub;
  final IconData icon;
  final Color iconColor, iconBg;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: EdgeInsets.all(cw(11.2)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Expanded(
                  child: Text(title,
                      style: TextStyle(fontSize: AppFontSize.f11, color: const Color(0xFF6B7280)))),
              Container(
                padding: EdgeInsets.all(cw(5.6)),
                decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, size: cw(9.4).clamp(14.0, 20.0), color: iconColor),
              ),
            ]),
            SizedBox(height: ch(8.1)),
            Text(value,
                style: TextStyle(
                    fontSize: AppFontSize.f16, fontWeight: FontWeight.w600, color: const Color(0xFF111827))),
            SizedBox(height: ch(2.4)),
            Text(sub, style: TextStyle(fontSize: AppFontSize.f9, color: iconColor)),
          ]),
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
        decoration:
            BoxDecoration(color: const Color(0xFFF5F3FF), borderRadius: BorderRadius.circular(12)),
        child: Text(plan,
            style: const TextStyle(
                fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF7C3AED))),
      );
}
