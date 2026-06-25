import 'package:app/models/models.dart';
import 'package:app/providers/members/members_provider.dart';
import 'package:app/service/firestore_service.dart';
import 'package:app/shared_widgets.dart';
import 'package:app/ui/helpers/app_layout_helper.dart';
import 'package:app/ui/helpers/font_size_helper.dart';
import 'package:app/ui/routes/app_routes.dart';
import 'package:app/ui/utils/app_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Members Screen — bound to a live Firestore snapshot stream.
// New members appear within ~1 s of the Firestore write with no manual refresh.
// ─────────────────────────────────────────────────────────────────────────────
class MembersScreen extends StatelessWidget {
  const MembersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final phone = isPhone(context);

    return Scaffold(
      body: Padding(
        padding: pagePadding(context),
        child: Column(
          children: [
            SizedBox(height: ch(8.1)),

            // ── Header row ──────────────────────────────────────────────────
            phone
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        txt: "Members",
                        fontSize: AppFontSize.f19,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF111827),
                      ),
                      AppText(
                        txt: "Manage Members",
                        fontSize: AppFontSize.f12,
                        color: const Color(0xFF6B7280),
                      ),
                      SizedBox(height: ch(12.2)),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () => Navigator.pushNamed(
                            context,
                            AppRoutes.addMemberScreen,
                          ),
                          icon: const Icon(Icons.add, size: 18),
                          label: AppText(
                            txt: "Add Members",
                            fontSize: AppFontSize.f12,
                            color: const Color(0xFFFFFFFF),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                          ),
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
                            txt: "Members",
                            fontSize: AppFontSize.f19,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF111827),
                          ),
                          AppText(
                            txt: "Manage Members",
                            fontSize: AppFontSize.f12,
                            color: const Color(0xFF6B7280),
                          ),
                        ],
                      ),
                      FilledButton.icon(
                        onPressed: () => Navigator.pushNamed(
                          context,
                          AppRoutes.addMemberScreen,
                        ),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add Members'),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                        ),
                      ),
                    ],
                  ),

            // ── Search / filter bar — driven by MembersProvider UI state ────
            Consumer<MembersProvider>(
              builder: (context, state, child) {
                return Card(
                  child: Padding(
                    padding: EdgeInsets.all(cw(11.2)),
                    child: phone
                        ? Column(
                            children: [
                              TextField(
                                decoration:
                                    customInputDecoration(
                                      'Search members...',
                                    ).copyWith(
                                      prefixIcon: const Icon(
                                        Icons.search,
                                        size: 18,
                                        color: Color(0xFF9CA3AF),
                                      ),
                                    ),
                                onChanged: (v) => state.setSearch(v),
                              ),
                              SizedBox(height: ch(9.7)),
                              DropdownButtonFormField<String>(
                                initialValue: state.filterStatus,
                                isExpanded: true,
                                decoration: customInputDecoration('Status'),
                                items: [
                                  DropdownMenuItem(
                                    value: 'all',
                                    child: AppText(txt: 'All Status'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'active',
                                    child: AppText(txt: 'Active'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'overdue',
                                    child: AppText(txt: 'Overdue'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'inactive',
                                    child: AppText(txt: 'Inactive'),
                                  ),
                                ],
                                onChanged: (v) => state.setFilterStatus(v!),
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  decoration:
                                      customInputDecoration(
                                        'Search members...',
                                      ).copyWith(
                                        prefixIcon: const Icon(
                                          Icons.search,
                                          size: 18,
                                          color: Color(0xFF9CA3AF),
                                        ),
                                      ),
                                  onChanged: (v) => state.setSearch(v),
                                ),
                              ),
                              SizedBox(width: cw(7.5)),
                              SizedBox(
                                width: cw(80),
                                child: DropdownButtonFormField<String>(
                                  initialValue: state.filterStatus,
                                  decoration: customInputDecoration('Status'),
                                  items: [
                                    DropdownMenuItem(
                                      value: 'all',
                                      child: AppText(txt: 'All Status'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'active',
                                      child: AppText(txt: 'Active'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'overdue',
                                      child: AppText(txt: 'Overdue'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'inactive',
                                      child: AppText(txt: 'Inactive'),
                                    ),
                                  ],
                                  onChanged: (v) => state.setFilterStatus(v!),
                                ),
                              ),
                            ],
                          ),
                  ),
                );
              },
            ),

            SizedBox(height: ch(12.2)),

            // ── Members list — StreamBuilder bound to Firestore snapshots ────
            // Every add/update to the 'members' collection triggers a rebuild.
            Expanded(
              child: Consumer<MembersProvider>(
                builder: (context, state, child) {
                  return StreamBuilder<List<Member>>(
                    stream: FirestoreService.instance.membersStream(),
                    builder: (context, snapshot) {
                      // Loading state
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Card(
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: ch(40)),
                              child: const CircularProgressIndicator(
                                color: Color(0xFF2563EB),
                              ),
                            ),
                          ),
                        );
                      }

                      // Error state
                      if (snapshot.hasError) {
                        return Card(
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.all(cw(16)),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    color: Color(0xFFDC2626),
                                    size: 40,
                                  ),
                                  SizedBox(height: ch(8)),
                                  AppText(
                                    txt: 'Failed to load members',
                                    fontSize: AppFontSize.f13,
                                    color: const Color(0xFFDC2626),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }

                      // Apply client-side search + status filter.
                      // Overdue status is computed here (date-only comparison)
                      // so it updates on every snapshot without N+1 payment queries.
                      final allMembers = snapshot.data ?? [];
                      final filtered = allMembers.where((m) {
                        final computedStatus =
                            FirestoreService.isOverdueByDate(m)
                            ? 'overdue'
                            : m.status.toLowerCase();

                        final matchSearch =
                            m.name.toLowerCase().contains(
                              state.search.toLowerCase(),
                            ) ||
                            m.email.toLowerCase().contains(
                              state.search.toLowerCase(),
                            );
                        final matchStatus =
                            state.filterStatus == 'all' ||
                            computedStatus == state.filterStatus.toLowerCase();
                        return matchSearch && matchStatus;
                      }).toList();

                      return Card(
                        child: Padding(
                          padding: EdgeInsets.all(cw(11.2)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(
                                txt: 'All Members (${filtered.length})',
                                fontSize: AppFontSize.f13,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF111827),
                              ),
                              SizedBox(height: ch(12.2)),
                              Expanded(
                                child: phone
                                    ? _MobileList(members: filtered)
                                    : SingleChildScrollView(
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: DataTable(
                                            headingRowColor:
                                                WidgetStateProperty.all(
                                                  const Color(0xFFF9FAFB),
                                                ),
                                            columns: [
                                              DataColumn(
                                                label: AppText(
                                                  txt: 'Member',
                                                  fontSize: 12,
                                                  color: const Color(
                                                    0xFF6B7280,
                                                  ),
                                                ),
                                              ),
                                              DataColumn(
                                                label: AppText(
                                                  txt: 'Contact',
                                                  fontSize: AppFontSize.f12,
                                                  color: const Color(
                                                    0xFF6B7280,
                                                  ),
                                                ),
                                              ),
                                              DataColumn(
                                                label: AppText(
                                                  txt: 'Membership',
                                                  fontSize: AppFontSize.f12,
                                                  color: const Color(
                                                    0xFF6B7280,
                                                  ),
                                                ),
                                              ),
                                              DataColumn(
                                                label: AppText(
                                                  txt: 'Status',
                                                  fontSize: AppFontSize.f12,
                                                  color: const Color(
                                                    0xFF6B7280,
                                                  ),
                                                ),
                                              ),
                                              DataColumn(
                                                label: AppText(
                                                  txt: 'Expiry',
                                                  fontSize: AppFontSize.f12,
                                                  color: const Color(
                                                    0xFF6B7280,
                                                  ),
                                                ),
                                              ),
                                              DataColumn(
                                                label: AppText(
                                                  txt: 'Actions',
                                                  fontSize: AppFontSize.f12,
                                                  color: const Color(
                                                    0xFF6B7280,
                                                  ),
                                                ),
                                              ),
                                            ],
                                            rows: filtered
                                                .map(
                                                  (m) => DataRow(
                                                    cells: [
                                                      DataCell(
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            AppText(
                                                              txt: m.name,
                                                              fontSize:
                                                                  AppFontSize
                                                                      .f16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                            SizedBox(
                                                              height: ch(5),
                                                            ),
                                                            AppText(
                                                              txt:
                                                                  'Joined ${m.joinDate}',
                                                              fontSize:
                                                                  AppFontSize
                                                                      .f13,
                                                              color:
                                                                  const Color(
                                                                    0xFF9CA3AF,
                                                                  ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      DataCell(
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Icon(
                                                                  Icons
                                                                      .email_outlined,
                                                                  size: cw(4),
                                                                  color: const Color(
                                                                    0xFF9CA3AF,
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  width: 4,
                                                                ),
                                                                AppText(
                                                                  txt: m.email,
                                                                  fontSize:
                                                                      AppFontSize
                                                                          .f15,
                                                                  color: const Color(
                                                                    0xFF6B7280,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            SizedBox(
                                                              height: ch(5),
                                                            ),
                                                            Row(
                                                              children: [
                                                                Icon(
                                                                  Icons
                                                                      .phone_outlined,
                                                                  size: cw(4),
                                                                  color: const Color(
                                                                    0xFF9CA3AF,
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                  width: 4,
                                                                ),
                                                                AppText(
                                                                  txt: m.phone,
                                                                  fontSize:
                                                                      AppFontSize
                                                                          .f13,
                                                                  color: const Color(
                                                                    0xFF6B7280,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      DataCell(
                                                        _Chip(
                                                          label: m.membership,
                                                          color: const Color(
                                                            0xFF7C3AED,
                                                          ),
                                                          bg: const Color(
                                                            0xFFF5F3FF,
                                                          ),
                                                        ),
                                                      ),
                                                      DataCell(
                                                        // Overdue is computed from expiryDate —
                                                        // badge updates on every snapshot.
                                                        StatusBadge(
                                                          status:
                                                              FirestoreService.isOverdueByDate(
                                                                m,
                                                              )
                                                              ? 'Overdue'
                                                              : m.status,
                                                        ),
                                                      ),
                                                      DataCell(
                                                        AppText(
                                                          txt: m.expiryDate,
                                                          fontSize:
                                                              AppFontSize.f13,
                                                          color: const Color(
                                                            0xFF6B7280,
                                                          ),
                                                        ),
                                                      ),
                                                      DataCell(
                                                        Row(
                                                          children: [
                                                            IconButton(
                                                              icon: const Icon(
                                                                Icons
                                                                    .edit_outlined,
                                                                size: 18,
                                                                color: Color(
                                                                  0xFF2563EB,
                                                                ),
                                                              ),
                                                              onPressed: () {
                                                                // Edit member — wire to edit screen
                                                                debugPrint(
                                                                  'Edit ${m.docId}',
                                                                );
                                                              },
                                                            ),
                                                            IconButton(
                                                              icon: const Icon(
                                                                Icons
                                                                    .delete_outline,
                                                                size: 18,
                                                                color: Color(
                                                                  0xFFDC2626,
                                                                ),
                                                              ),
                                                              onPressed: () =>
                                                                  _confirmDelete(
                                                                    context,
                                                                    m,
                                                                  ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                                .toList(),
                                          ),
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            SizedBox(height: ch(16.2)),
          ],
        ),
      ),
    );
  }

  /// Shows a confirmation dialog before deleting a member from Firestore.
  void _confirmDelete(BuildContext context, Member member) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Member'),
        content: Text('Remove "${member.name}" permanently?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final error = await FirestoreService.instance.deleteMember(
                member.docId,
              );
              if (error != null && context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(error)));
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Mobile card list
// ─────────────────────────────────────────────────────────────────────────────
class _MobileList extends StatelessWidget {
  const _MobileList({required this.members});
  final List<Member> members;

  @override
  Widget build(BuildContext context) {
    if (members.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(cw(15.0)),
          child: AppText(txt: 'No members found', fontSize: AppFontSize.f15),
        ),
      );
    }
    return ListView.builder(
      itemCount: members.length,
      itemBuilder: (context, index) {
        final m = members[index];
        // Compute overdue per-card — updates on every snapshot rebuild.
        final displayStatus = FirestoreService.isOverdueByDate(m)
            ? 'Overdue'
            : m.status;

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
                children: [
                  CircleAvatar(
                    radius: cw(16.9).clamp(16.0, 22.0),
                    backgroundColor: const Color(0xFFEFF6FF),
                    child: Text(
                      m.name.isNotEmpty ? m.name[0] : '?',
                      style: TextStyle(
                        color: const Color(0xFF2563EB),
                        fontWeight: FontWeight.w600,
                        fontSize: AppFontSize.f15,
                      ),
                    ),
                  ),
                  SizedBox(width: cw(7.5)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          m.name,
                          style: TextStyle(
                            fontSize: AppFontSize.f15,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF111827),
                          ),
                        ),
                        Text(
                          m.membership,
                          style: TextStyle(
                            fontSize: AppFontSize.f11,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  StatusBadge(status: displayStatus),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      size: 18,
                      color: Color(0xFFDC2626),
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () =>
                        _MembersScreenHelper.confirmDelete(context, m),
                  ),
                ],
              ),
              SizedBox(height: ch(8.1)),
              Row(
                children: [
                  const Icon(
                    Icons.email_outlined,
                    size: 13,
                    color: Color(0xFF9CA3AF),
                  ),
                  SizedBox(width: cw(5.6)),
                  Expanded(
                    child: Text(
                      m.email,
                      style: TextStyle(
                        fontSize: AppFontSize.f11,
                        color: const Color(0xFF6B7280),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: ch(4.1)),
              Row(
                children: [
                  const Icon(
                    Icons.phone_outlined,
                    size: 13,
                    color: Color(0xFF9CA3AF),
                  ),
                  SizedBox(width: cw(5.6)),
                  Text(
                    m.phone,
                    style: TextStyle(
                      fontSize: AppFontSize.f11,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Exp: ${m.expiryDate}',
                    style: TextStyle(
                      fontSize: AppFontSize.f10,
                      color: const Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared helper for delete confirmation (used by both desktop + mobile)
// ─────────────────────────────────────────────────────────────────────────────
class _MembersScreenHelper {
  static void confirmDelete(BuildContext context, Member member) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Member'),
        content: Text('Remove "${member.name}" permanently?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final error = await FirestoreService.instance.deleteMember(
                member.docId,
              );
              if (error != null && context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(error)));
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
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
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      label,
      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: color),
    ),
  );
}
