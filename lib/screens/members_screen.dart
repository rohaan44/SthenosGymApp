import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/gym_provider.dart';
import '../shared_widgets.dart';
import '../ui/helpers/app_layout_helper.dart';
import 'package:app/ui/helpers/font_size_helper.dart';


class MembersState extends ChangeNotifier {
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

  List<Member> filtered(List<Member> members) => members.where((m) {
        final matchSearch = m.name.toLowerCase().contains(_search.toLowerCase()) ||
            m.email.toLowerCase().contains(_search.toLowerCase());
        final matchStatus =
            _filterStatus == 'all' || m.status.toLowerCase() == _filterStatus.toLowerCase();
        return matchSearch && matchStatus;
      }).toList();
}

class MembersScreen extends StatelessWidget {
  const MembersScreen({super.key});

  void _showAddDialog(BuildContext context) {
    final provider = context.read<GymProvider>();
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    String membership = 'Basic';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Add New Member'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              customTf('Full Name', nameCtrl),
              const SizedBox(height: 12),
              customTf('Email', emailCtrl),
              const SizedBox(height: 12),
              customTf('Phone', phoneCtrl),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: membership,
                decoration: customInputDecoration('Membership Type'),
                items: ['Basic', 'Standard', 'Premium']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setS(() => membership = v!),
              ),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                if (nameCtrl.text.isEmpty) return;
                provider.addMember(Member(
                  id: provider.members.length + 1,
                  name: nameCtrl.text,
                  email: emailCtrl.text,
                  phone: phoneCtrl.text,
                  membership: membership,
                  status: 'Active',
                  joinDate: 'Jun 10, 2026',
                  expiryDate: 'Jun 10, 2027',
                ));
                Navigator.pop(ctx);
              },
              child: const Text('Add Member'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteMember(BuildContext context, int id) => context.read<GymProvider>().deleteMember(id);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MembersState(),
      child: Consumer<MembersState>(
        builder: (context, state, child) {
          final provider = context.watch<GymProvider>();
          final filtered = state.filtered(provider.members);
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
                  Text('Members',
                      style: TextStyle(
                          fontSize: AppFontSize.f19,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF111827))),
                  Text('Manage your gym members',
                      style: TextStyle(fontSize: AppFontSize.f12, color: const Color(0xFF6B7280))),
                  SizedBox(height: ch(12.2)),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => _showAddDialog(context),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add Member'),
                      style: FilledButton.styleFrom(backgroundColor: const Color(0xFF2563EB)),
                    ),
                  ),
                ])
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Members',
                          style: TextStyle(
                              fontSize: AppFontSize.f19,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF111827))),
                      Text('Manage your gym members',
                          style: TextStyle(fontSize: AppFontSize.f12, color: const Color(0xFF6B7280))),
                    ]),
                    FilledButton.icon(
                      onPressed: () => _showAddDialog(context),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add Member'),
                      style: FilledButton.styleFrom(backgroundColor: const Color(0xFF2563EB)),
                    ),
                  ],
                ),

          SizedBox(height: ch(16.2)),

          // ── Filters ───────────────────────────────────────────────────────
          Card(
            child: Padding(
              padding: EdgeInsets.all(cw(11.2)),
              child: phone
                  ? Column(children: [
                      TextField(
                        decoration: customInputDecoration('Search members...').copyWith(
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
                          DropdownMenuItem(value: 'active', child: Text('Active')),
                          DropdownMenuItem(value: 'pending', child: Text('Pending')),
                          DropdownMenuItem(value: 'expired', child: Text('Expired')),
                        ],
                        onChanged: (v) => state.setFilterStatus(v!),
                      ),
                    ])
                  : Row(children: [
                      Expanded(
                        child: TextField(
                          decoration: customInputDecoration('Search members...').copyWith(
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
                            DropdownMenuItem(value: 'active', child: Text('Active')),
                            DropdownMenuItem(value: 'pending', child: Text('Pending')),
                            DropdownMenuItem(value: 'expired', child: Text('Expired')),
                          ],
                          onChanged: (v) => state.setFilterStatus(v!),
                        ),
                      ),
                    ]),
            ),
          ),

          SizedBox(height: ch(12.2)),

          // ── Member list ───────────────────────────────────────────────────
          Card(
            child: Padding(
              padding: EdgeInsets.all(cw(11.2)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('All Members (${filtered.length})',
                    style: TextStyle(
                        fontSize: AppFontSize.f13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF111827))),
                SizedBox(height: ch(12.2)),

                // Phone → card list; Tablet/Desktop → DataTable
                phone
                    ? _MobileList(members: filtered, onDelete: (id) => _deleteMember(context, id))
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowColor: WidgetStateProperty.all(const Color(0xFFF9FAFB)),
                          columns: const [
                            DataColumn(label: Text('Member', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)))),
                            DataColumn(label: Text('Contact', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)))),
                            DataColumn(label: Text('Membership', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)))),
                            DataColumn(label: Text('Status', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)))),
                            DataColumn(label: Text('Expiry', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)))),
                            DataColumn(label: Text('Actions', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)))),
                          ],
                          rows: filtered
                              .map((m) => DataRow(cells: [
                                    DataCell(Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(m.name,
                                              style: const TextStyle(
                                                  fontSize: 13, fontWeight: FontWeight.w500)),
                                          Text('Joined ${m.joinDate}',
                                              style: const TextStyle(
                                                  fontSize: 11, color: Color(0xFF9CA3AF))),
                                        ])),
                                    DataCell(Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Row(children: [
                                            const Icon(Icons.email_outlined,
                                                size: 12, color: Color(0xFF9CA3AF)),
                                            const SizedBox(width: 4),
                                            Text(m.email,
                                                style: const TextStyle(
                                                    fontSize: 12, color: Color(0xFF6B7280)))
                                          ]),
                                          Row(children: [
                                            const Icon(Icons.phone_outlined,
                                                size: 12, color: Color(0xFF9CA3AF)),
                                            const SizedBox(width: 4),
                                            Text(m.phone,
                                                style: const TextStyle(
                                                    fontSize: 12, color: Color(0xFF6B7280)))
                                          ]),
                                        ])),
                                    DataCell(_Chip(
                                        label: m.membership,
                                        color: const Color(0xFF7C3AED),
                                        bg: const Color(0xFFF5F3FF))),
                                    DataCell(StatusBadge(status: m.status)),
                                    DataCell(Text(m.expiryDate,
                                        style: const TextStyle(
                                            fontSize: 13, color: Color(0xFF6B7280)))),
                                    DataCell(Row(children: [
                                      IconButton(
                                          icon: const Icon(Icons.edit_outlined, size: 18),
                                          onPressed: () {}),
                                      IconButton(
                                          icon: const Icon(Icons.delete_outline,
                                              size: 18, color: Color(0xFFDC2626)),
                                          onPressed: () => _deleteMember(context, m.id)),
                                    ])),
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
// Mobile card list (replaces DataTable on phone)
// ─────────────────────────────────────────────────────────────────────────────
class _MobileList extends StatelessWidget {
  const _MobileList({required this.members, required this.onDelete});
  final List<Member> members;
  final void Function(int) onDelete;

  @override
  Widget build(BuildContext context) {
    if (members.isEmpty) {
      return Center(
          child: Padding(
        padding: EdgeInsets.all(cw(15.0)),
        child: Text('No members found', style: TextStyle(color: const Color(0xFF9CA3AF), fontSize: AppFontSize.f12)),
      ));
    }
    return Column(
      children: members
          .map((m) => Container(
                margin: EdgeInsets.only(bottom: ch(9.7)),
                padding: EdgeInsets.all(cw(11.2)),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    CircleAvatar(
                      radius: cw(16.9).clamp(16.0, 22.0),
                      backgroundColor: const Color(0xFFEFF6FF),
                      child: Text(m.name[0],
                          style: TextStyle(
                              color: const Color(0xFF2563EB),
                              fontWeight: FontWeight.w600,
                              fontSize: AppFontSize.f15)),
                    ),
                    SizedBox(width: cw(7.5)),
                    Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(m.name,
                          style: TextStyle(
                              fontSize: AppFontSize.f15,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF111827))),
                      Text(m.membership,
                          style: TextStyle(fontSize: AppFontSize.f11, color: const Color(0xFF6B7280))),
                    ])),
                    StatusBadge(status: m.status),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFDC2626)),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => onDelete(m.id),
                    ),
                  ]),
                  SizedBox(height: ch(8.1)),
                  Row(children: [
                    const Icon(Icons.email_outlined, size: 13, color: Color(0xFF9CA3AF)),
                    SizedBox(width: cw(5.6)),
                    Expanded(
                        child: Text(m.email,
                            style: TextStyle(fontSize: AppFontSize.f11, color: const Color(0xFF6B7280)),
                            overflow: TextOverflow.ellipsis)),
                  ]),
                  SizedBox(height: ch(4.1)),
                  Row(children: [
                    const Icon(Icons.phone_outlined, size: 13, color: Color(0xFF9CA3AF)),
                    SizedBox(width: cw(5.6)),
                    Text(m.phone,
                        style: TextStyle(fontSize: AppFontSize.f11, color: const Color(0xFF6B7280))),
                    const Spacer(),
                    Text('Exp: ${m.expiryDate}',
                        style: TextStyle(fontSize: AppFontSize.f10, color: const Color(0xFF9CA3AF))),
                  ]),
                ]),
              ))
          .toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.color, required this.bg});
  final String label;
  final Color color, bg;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
        child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: color)),
      );
}
