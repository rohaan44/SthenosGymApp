import 'package:app/models/models.dart';
import 'package:app/providers/gym_provider.dart';
import 'package:app/providers/members_provider.dart';
import 'package:app/shared_widgets.dart';
import 'package:app/ui/helpers/app_layout_helper.dart';
import 'package:app/ui/helpers/font_size_helper.dart';
import 'package:app/ui/routes/app_routes.dart';
import 'package:app/ui/utils/app_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MembersScreen extends StatelessWidget {
  const MembersScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GymProvider>();
    final filtered = provider.members;
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
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.addMemberScreen, // FIX 1: correct route
                          );
                        },
                        child: AppText(
                          txt: "Add Members",
                          fontSize: AppFontSize.f12,
                          color: const Color(0xFFFFFFFF),
                        ),
                      ),

                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () => Navigator.pushNamed(
                            context,
                            AppRoutes.addMemberScreen, // FIX 1: correct route
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
                          AppRoutes.addMemberScreen, // FIX 1: correct route
                        ),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add Members'),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                        ),
                      ),
                    ],
                  ),

            // ── Search / filter bar ─────────────────────────────────────────
            // FIX 2: Consumer<MembersProvider> with correct param order
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
                                    value: 'pending',
                                    child: AppText(txt: 'Pending'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'expired',
                                    child: AppText(txt: 'Expired'),
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
                                      value: 'pending',
                                      child: AppText(txt: 'Pending'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'expired',
                                      child: AppText(txt: 'Expired'),
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

            // ── Members table / card list ────────────────────────────────────
            // FIX 3: Consumer<GymProvider> with correct param order
            Expanded(
              child: Consumer<GymProvider>(
                builder: (context, gymProvider, child) {
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

                          // Phone → card list; Tablet/Desktop → DataTable
                          Expanded(
                            child: phone
                                ? _MobileList(
                                    members: filtered,
                                    onDelete: (id) =>
                                        gymProvider.deleteMember(id),
                                    // FIX 5: edit button on mobile
                                    onEdit: (m) => print(m),
                                  )
                                // FIX 4: vertical scroll wraps DataTable
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
                                              color: Color(0xFF6B7280),
                                            ),
                                          ),
                                          DataColumn(
                                            label: AppText(
                                              txt: 'Contact',
                                              fontSize: AppFontSize.f12,
                                              color: Color(0xFF6B7280),
                                            ),
                                          ),
                                          DataColumn(
                                            label: AppText(
                                              txt: 'Membership',
                                              fontSize: AppFontSize.f12,
                                              color: Color(0xFF6B7280),
                                            ),
                                          ),
                                          DataColumn(
                                            label: AppText(
                                              txt: 'Status',
                                              fontSize: AppFontSize.f12,
                                              color: Color(0xFF6B7280),
                                            ),
                                          ),
                                          DataColumn(
                                            label: AppText(
                                              txt: 'Expiry',
                                              fontSize: AppFontSize.f12,
                                              color: Color(0xFF6B7280),
                                            ),
                                          ),
                                          DataColumn(
                                            label: AppText(
                                              txt: 'Actions',
                                              fontSize: AppFontSize.f12,
                                              color: Color(0xFF6B7280),
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
                                                              AppFontSize.f16,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                        SizedBox(height: ch(5)),
                                                        AppText(
                                                          txt:
                                                              'Joined ${m.joinDate}',
                                                          fontSize:
                                                              AppFontSize.f13,
                                                          color: Color(
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
                                                              color: Color(
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
                                                              color: Color(
                                                                0xFF6B7280,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(height: ch(5)),
                                                        Row(
                                                          children: [
                                                            Icon(
                                                              Icons
                                                                  .phone_outlined,
                                                              size: cw(4),
                                                              color: Color(
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
                                                              color: Color(
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
                                                    StatusBadge(
                                                      status: m.status,
                                                    ),
                                                  ),
                                                  DataCell(
                                                    AppText(
                                                      txt: m.expiryDate,
                                                      fontSize: AppFontSize.f13,
                                                      color: const Color(
                                                        0xFF6B7280,
                                                      ),
                                                    ),
                                                  ),
                                                  // FIX 3: wired-up edit button
                                                  DataCell(
                                                    Row(
                                                      children: [
                                                        IconButton(
                                                          icon: const Icon(
                                                            Icons.edit_outlined,
                                                            size: 18,
                                                            color: Color(
                                                              0xFF2563EB,
                                                            ),
                                                          ),
                                                          onPressed: () {
                                                            print(m);
                                                          },
                                                          // _showEditDialog(
                                                          //     context, m),
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
                                                              gymProvider
                                                                  .deleteMember(
                                                                    m.id,
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
              ),
            ),
            SizedBox(height: ch(16.2)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _MobileList extends StatelessWidget {
  const _MobileList({
    required this.members,
    required this.onDelete,
    required this.onEdit, // FIX 5: edit callback
  });
  final List<Member> members;
  final void Function(int) onDelete;
  final void Function(Member) onEdit;

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
                      m.name[0],
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
                  StatusBadge(status: m.status),
                  // FIX 5: edit button on mobile card
                  IconButton(
                    icon: const Icon(
                      Icons.edit_outlined,
                      size: 18,
                      color: Color(0xFF2563EB),
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => onEdit(m),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      size: 18,
                      color: Color(0xFFDC2626),
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => onDelete(m.id),
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
