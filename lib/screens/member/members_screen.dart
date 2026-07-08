import 'package:app/models/models.dart';
import 'package:app/providers/members/members_provider.dart';
import 'package:app/service/firestore_service.dart';
import 'package:app/service/printer_service.dart';
import 'package:app/shared_widgets.dart';
import 'package:app/ui/helpers/app_layout_helper.dart';
import 'package:app/ui/helpers/color_helper.dart';
import 'package:app/ui/helpers/font_size_helper.dart';
import 'package:app/ui/routes/app_routes.dart';
import 'package:app/ui/utils/app_primary_button.dart';
import 'package:app/ui/utils/app_text.dart';
import 'package:app/ui/utils/primary_textfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

// Helper: navigate to payment history for a member

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
                      ),
                      SizedBox(height: ch(8)),
                      AppText(
                        txt: "Manage Members",
                        fontSize: AppFontSize.f15,
                        fontWeight: FontWeight.w500,
                        // color: const Color(0xFF6B7280),
                        color: const Color(0xFF6B7280),
                      ),
                      SizedBox(height: ch(12.2)),
                      AppButton(
                        height: ch(40),
                        onPressed: () => Navigator.pushNamed(
                          context,
                          AppRoutes.addMemberScreen,
                        ),
                        text: "+ Add Members",
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
                          ),
                          SizedBox(height: ch(8)),
                          AppText(
                            txt: "Manage Members",
                            fontSize: AppFontSize.f15,
                            fontWeight: FontWeight.w500,
                            // color: const Color(0xFF6B7280),
                            color: const Color(0xFF6B7280),
                          ),
                        ],
                      ),

                      ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: 160,
                          minWidth: 120,
                        ),
                        child: AppButton(
                          height: 44,
                          onPressed: () => Navigator.pushNamed(
                            context,
                            AppRoutes.addMemberScreen,
                          ),
                          text: "+ Add Members",
                          fontSize: AppFontSize.f15,
                        ),
                      ),
                    ],
                  ),

            SizedBox(height: ch(20)),

            // ── Search / filter bar — driven by MembersProvider UI state ────
            Consumer<MembersProvider>(
              builder: (context, state, child) {
                return Card(
                  child: Padding(
                    padding: EdgeInsets.all(cw(11.2)),
                    child: phone
                        ? Column(
                            children: [
                              primaryTextField(
                                hintText: "Search members here ...",
                                prefixIcon: const Icon(CupertinoIcons.person),
                                // controller: state.nameController,
                                onChanged: (v) => state.setSearch(v),
                              ),

                              SizedBox(height: ch(16)),
                              DropdownButtonFormField<String>(
                                initialValue: state.filterStatus,
                                isExpanded: true,
                                dropdownColor: AppColor.red,
                                decoration: customInputDecoration(
                                  label: 'Status',
                                ),
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
                                child: primaryTextField(
                                  hintText: "Search members here ...",
                                  prefixIcon: const Icon(CupertinoIcons.person),
                                  // controller: state.nameController,
                                  onChanged: (v) => state.setSearch(v),
                                ),
                              ),
                              SizedBox(width: cw(7.5)),
                              SizedBox(
                                width: cw(80),
                                child: DropdownButtonFormField<String>(
                                  initialValue: state.filterStatus,
                                  dropdownColor: AppColor.red,
                                  decoration: customInputDecoration(
                                    label: 'Status',
                                  ),
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
                              child: CircularProgressIndicator(
                                color: AppColor.cFFFFFF,
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
                                fontSize: AppFontSize.f15,
                                fontWeight: FontWeight.w600,
                              ),
                              SizedBox(height: ch(16)),
                              Expanded(
                                child: (phone || screenWidth(context) < 950)
                                    ? _MobileList(members: filtered)
                                    : SingleChildScrollView(
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: DataTable(
                                            showCheckboxColumn: false,

                                            headingRowColor:
                                                WidgetStateProperty.all(
                                                  Color(0xFF790600),
                                                ),
                                            columns: [
                                              DataColumn(
                                                label: AppText(
                                                  txt: 'Gym Id',
                                                  fontSize: 12,
                                                  color: AppColor.cFFFFFF,
                                                ),
                                              ),
                                              DataColumn(
                                                label: AppText(
                                                  txt: 'Member',
                                                  fontSize: 12,
                                                  color: AppColor.cFFFFFF,
                                                ),
                                              ),
                                              DataColumn(
                                                label: AppText(
                                                  txt: 'Contact',
                                                  fontSize: AppFontSize.f12,
                                                  color: AppColor.cFFFFFF,
                                                ),
                                              ),
                                              DataColumn(
                                                label: AppText(
                                                  txt: 'Membership',
                                                  fontSize: AppFontSize.f12,
                                                  color: AppColor.cFFFFFF,
                                                ),
                                              ),
                                              DataColumn(
                                                label: AppText(
                                                  txt: 'Status',
                                                  fontSize: AppFontSize.f12,
                                                  color: AppColor.cFFFFFF,
                                                ),
                                              ),
                                              DataColumn(
                                                label: AppText(
                                                  txt: 'Expiry',
                                                  fontSize: AppFontSize.f12,
                                                  color: AppColor.cFFFFFF,
                                                ),
                                              ),
                                              DataColumn(
                                                label: AppText(
                                                  txt: 'Actions',
                                                  fontSize: AppFontSize.f12,
                                                  color: AppColor.cFFFFFF,
                                                ),
                                              ),
                                            ],
                                            rows: filtered
                                                .map(
                                                  (m) => DataRow(
                                                    // Tap anywhere on the row → open payment history
                                                    // onSelectChanged: (_) =>
                                                    //     _openPaymentHistory(
                                                    //       context,
                                                    //       m,
                                                    //     ),
                                                    cells: [
                                                      DataCell(
                                                        AppText(
                                                          txt: m.id.toString(),
                                                          color:
                                                              AppColor.cFFFFFF,
                                                          fontSize:
                                                              AppFontSize.f12,
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
                                                                  color: AppColor
                                                                      .cFFFFFF,
                                                                ),
                                                                const SizedBox(
                                                                  width: 4,
                                                                ),
                                                                AppText(
                                                                  txt: m.email,
                                                                  fontSize:
                                                                      AppFontSize
                                                                          .f15,
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
                                                          color: AppColor.blue2,
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
                                                                Icons.payments,
                                                                size: 18,
                                                                color: Color(
                                                                  0xFF7C3AED,
                                                                ),
                                                              ),
                                                              tooltip:
                                                                  'Collect Payment',
                                                              onPressed: () =>
                                                                  MembersScreenHelper.showPaymentDialog(
                                                                    context,
                                                                    m,
                                                                  ),

                                                              // showPaymentDialog(
                                                              //   context,
                                                              //   m,
                                                              // ),
                                                            ),
                                                            IconButton(
                                                              tooltip:
                                                                  'Edit details?',

                                                              icon: const Icon(
                                                                Icons
                                                                    .edit_outlined,
                                                                size: 18,
                                                                color: AppColor
                                                                    .blue2,
                                                              ),
                                                              onPressed: () {
                                                                context
                                                                    .read<
                                                                      MembersProvider
                                                                    >()
                                                                    .setMemberData({
                                                                      "members":
                                                                          m,
                                                                    });

                                                                Navigator.pushNamed(
                                                                  context,
                                                                  AppRoutes
                                                                      .editMemberScreen,
                                                                );
                                                                // Edit member — wire to edit screen

                                                                debugPrint(
                                                                  'Edit ${m.docId}',
                                                                );
                                                              },
                                                            ),
                                                            IconButton(
                                                              tooltip:
                                                                  'Delete member?',

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
                                                            // Print Receipt - only for Active (paid) members
                                                            if (!FirestoreService.isOverdueByDate(
                                                                  m,
                                                                ) &&
                                                                m.status.toLowerCase() ==
                                                                    'active')
                                                              IconButton(
                                                                tooltip:
                                                                    'Print Receipt',
                                                                icon: const Icon(
                                                                  Icons
                                                                      .receipt_long_outlined,
                                                                  size: 18,
                                                                  color: Color(
                                                                    0xFF16A34A,
                                                                  ),
                                                                ),
                                                                onPressed: () =>
                                                                    _printLatestReceipt(
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

          AppButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final error = await FirestoreService.instance.deleteMember(
                member.docId,
              );
              if (error != null && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Color(0xFF790600),
                    content: Text(error),
                  ),
                );
              }
            },
            width: cw(30),

            text: "Delete",
          ),
          // FilledButton(
          //   style: FilledButton.styleFrom(
          //     backgroundColor: const Color(0xFFDC2626),
          //   ),
          //   onPressed: () async {
          //     Navigator.pop(ctx);
          //     final error = await FirestoreService.instance.deleteMember(
          //       member.docId,
          //     );
          //     if (error != null && context.mounted) {
          //       ScaffoldMessenger.of(
          //         context,
          //       ).showSnackBar(SnackBar(content: Text(error)));
          //     }
          //   },
          //   child: const Text('Delete'),
          // ),
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

        return GestureDetector(
          // Tap anywhere on the card → open payment history
          // onTap: () => _openPaymentHistory(context, m),
          child: Container(
            margin: EdgeInsets.only(bottom: ch(9.7)),
            padding: EdgeInsets.all(cw(11.2)),
            decoration: BoxDecoration(
              color: AppColor.c151515,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: cw(16.9).clamp(16.0, 22.0),
                      backgroundColor: const Color(0xFFEFF6FF),
                      backgroundImage:
                          (m.profileImageUrl != null &&
                              m.profileImageUrl!.isNotEmpty)
                          ? NetworkImage(m.profileImageUrl!)
                          : null,
                      child:
                          (m.profileImageUrl == null ||
                              m.profileImageUrl!.isEmpty)
                          ? AppText(
                              txt: m.name.isNotEmpty ? m.name[0] : '?',
                              color: const Color(0xFF2563EB),
                              fontWeight: FontWeight.w600,
                              fontSize: AppFontSize.f15,
                            )
                          : null,
                    ),
                    SizedBox(width: cw(7.5)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AppText(
                            txt: m.name,
                            fontSize: AppFontSize.f16,
                            fontWeight: FontWeight.w600,
                            color: AppColor.cFFFFFF,
                          ),

                          AppText(
                            txt: m.membership,

                            fontSize: AppFontSize.f12,
                            color: AppColor.themeGrey,
                          ),
                        ],
                      ),
                    ),
                    StatusBadge(status: displayStatus),
                    // const SizedBox(width: 4),
                    // History button
                    PopupMenuButton<String>(
                      color: AppColor.white,
                      iconColor: AppColor.white,
                      tooltip: 'Actions',
                      icon: const Icon(Icons.more_vert),
                      onSelected: (value) {
                        switch (value) {
                          case 'payment':
                            MembersScreenHelper.showPaymentDialog(context, m);
                            break;
                          case 'edit':
                            context.read<MembersProvider>().setMemberData({
                              "members": m,
                            });

                            Navigator.pushNamed(
                              context,
                              AppRoutes.editMemberScreen,
                            );
                            break;

                          case 'delete':
                            MembersScreenHelper.confirmDelete(context, m);
                            break;

                          case 'receipt':
                            _printLatestReceipt(context, m);
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'payment',
                          child: Row(
                            children: [
                              Icon(
                                Icons.payments,
                                size: 18,
                                color: Color(0xFF7C3AED),
                              ),
                              SizedBox(width: 10),
                              Text('Collect Payment'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 18, color: AppColor.blue2),
                              SizedBox(width: 10),
                              Text('Edit Member'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_outline,
                                size: 18,
                                color: Color(0xFFDC2626),
                              ),
                              SizedBox(width: 10),
                              Text('Delete Member'),
                            ],
                          ),
                        ),

                        // Show only for active (paid) members
                        if (!FirestoreService.isOverdueByDate(m) &&
                            m.status.toLowerCase() == 'active')
                          const PopupMenuItem(
                            value: 'receipt',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.receipt_long_outlined,
                                  size: 18,
                                  color: Color(0xFF16A34A),
                                ),
                                SizedBox(width: 10),
                                Text('Print Receipt'),
                              ],
                            ),
                          ),
                      ],
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
                // Tap hint
                SizedBox(height: ch(6)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Icon(
                      Icons.touch_app_outlined,
                      size: 11,
                      color: Color(0xFFD1D5DB),
                    ),
                    SizedBox(width: cw(3)),
                    const Text(
                      'Tap to view payment history',
                      style: TextStyle(fontSize: 10, color: Color(0xFFD1D5DB)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared helper for delete confirmation (used by both desktop + mobile)
// ─────────────────────────────────────────────────────────────────────────────
class MembersScreenHelper {
  static void showPaymentDialog(
    BuildContext context,
    Member member, {
    String? paymentDocIdToUpdate,
  }) {
    String selectedMethod = 'Cash';
    final amountController = TextEditingController();
    bool isProcessing = false;

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Collect Payment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Member: ${member.name}'),
              const SizedBox(height: 16),

              TextField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                maxLength: 5,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],

                decoration: InputDecoration(
                  counterText: "",

                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                  prefix: Padding(
                    padding: EdgeInsets.only(right: 5.0),
                    child: Text("Rs"),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: selectedMethod,
                decoration: const InputDecoration(
                  labelText: 'Payment Method',
                  border: OutlineInputBorder(),
                ),
                items: ['Cash', 'Bank Transfer']
                    .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                    .toList(),
                onChanged: (v) => setState(() => selectedMethod = v!),
              ),
            ],
          ),

          actions: [
            TextButton(
              onPressed: isProcessing ? null : () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: isProcessing
                  ? null
                  : () async {
                      final amountStr = amountController.text.trim();
                      if (amountStr.isEmpty) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          const SnackBar(content: Text('Plz Enter Amount')),
                        );
                      }
                      final amount = double.tryParse(amountStr);
                      if (amount == null || amount <= 0) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          const SnackBar(content: Text('Enter a valid amount')),
                        );
                        return;
                      }

                      setState(() => isProcessing = true);

                      final error = await FirestoreService.instance
                          .processPayment(
                            member: member,
                            method: selectedMethod,
                            amount: amount,
                            paymentDocIdToUpdate: paymentDocIdToUpdate,
                          );

                      if (error != null) {
                        if (ctx.mounted) {
                          Navigator.pop(ctx); // close dialog first
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: AppText(txt: error),
                              backgroundColor: const Color(0xFFDC2626),
                              duration: const Duration(seconds: 5),
                            ),
                          );
                        }
                      } else {
                        // Print receipt
                        try {
                          final memberData = {
                            'name': member.name,
                            'gymId': member.id,
                            'membership': member.membership,
                            'expiryDate': member.expiryDate,
                            "phone": member.phone,
                          };
                          await AppPrinter.printReceipt(
                            memberData,
                            amount,
                            selectedMethod,
                          );
                        } catch (e) {
                          debugPrint('Printing error: $e');
                        }
                        if (ctx.mounted) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            const SnackBar(
                              content: Text('Payment recorded successfully'),
                            ),
                          );
                        }
                      }
                    },
              child: isProcessing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Confirm'),
            ),
          ],
        ),
      ),
    );
  }

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

class _DashedDivider extends StatelessWidget {
  const _DashedDivider();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final boxWidth = constraints.constrainWidth();
          const dashWidth = 4.0;
          const dashHeight = 1.0;
          final dashCount = (boxWidth / (2 * dashWidth)).floor();
          return Flex(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            direction: Axis.horizontal,
            children: List.generate(dashCount, (_) {
              return const SizedBox(
                width: dashWidth,
                height: dashHeight,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: Colors.black),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}

class ReceiptPreviewDialog extends StatelessWidget {
  final Member member;
  final double amount;
  final String selectedMethod;

  const ReceiptPreviewDialog({
    Key? key,
    required this.member,
    required this.amount,
    required this.selectedMethod,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final formattedDate =
        "${now.month.toString().padLeft(2, '0')}/${now.day.toString().padLeft(2, '0')}/${now.year}";
    int displayHour = now.hour % 12;
    if (displayHour == 0) displayHour = 12;
    final period = now.hour >= 12 ? 'PM' : 'AM';
    final formattedTime =
        "${displayHour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')} $period";

    String expiryDate = member.expiryDate;
    if (expiryDate.contains('T')) {
      expiryDate = expiryDate.split('T')[0];
    }
    if (expiryDate.contains('-')) {
      final parts = expiryDate.split('-');
      if (parts.length == 3) {
        expiryDate = "${parts[1]}/${parts[2]}/${parts[0]}";
      }
    }

    final planRaw = member.membership;
    final planName = planRaw.split('-')[0].trim().toUpperCase();
    final itemLine = "MEMBERSHIP $planName";

    String paymentType = selectedMethod.toUpperCase();
    String cardRow = '';
    if (paymentType.contains('CREDIT') || paymentType.contains('CARD')) {
      paymentType = 'VISA';
      cardRow = '****2222';
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        width: 350,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Receipt Content
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/receipt_logo.png',
                    height: ch(80),
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.fitness_center,
                      size: ch(80),
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: ch(12)),
                  Text(
                    'STHENOS GYM',
                    style: TextStyle(
                      fontSize: AppFontSize.f16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    '+92310-0006947',
                    style: TextStyle(
                      fontSize: AppFontSize.f12,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: ch(16)),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'DATE: $formattedDate',
                        style: TextStyle(
                          fontSize: AppFontSize.f12,
                          color: Colors.black,
                          fontFamily: 'Courier',
                        ),
                      ),
                      Text(
                        'TIME: $formattedTime',
                        style: TextStyle(
                          fontSize: AppFontSize.f12,
                          color: Colors.black,
                          fontFamily: 'Courier',
                        ),
                      ),
                    ],
                  ),

                  const _DashedDivider(),

                  Text(
                    'MEMBER: ${member.name}',
                    style: TextStyle(
                      fontSize: AppFontSize.f12,
                      color: Colors.black,
                      fontFamily: 'Courier',
                    ),
                  ),
                  Text(
                    'MEMBER ID: ${member.id}',
                    style: TextStyle(
                      fontSize: AppFontSize.f12,
                      color: Colors.black,
                      fontFamily: 'Courier',
                    ),
                  ),
                  Text(
                    'MEMBERSHIP: ${member.membership}',
                    style: TextStyle(
                      fontSize: AppFontSize.f12,
                      color: Colors.black,
                      fontFamily: 'Courier',
                    ),
                  ),

                  const _DashedDivider(),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        itemLine,
                        style: TextStyle(
                          fontSize: AppFontSize.f12,
                          color: Colors.black,
                          fontFamily: 'Courier',
                        ),
                      ),
                      Text(
                        'Rs ${amount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: AppFontSize.f12,
                          color: Colors.black,
                          fontFamily: 'Courier',
                        ),
                      ),
                    ],
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Divider(
                      color: Colors.black,
                      height: 1,
                      thickness: 1,
                    ),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'TOTAL',
                        style: TextStyle(
                          fontSize: AppFontSize.f16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontFamily: 'Courier',
                        ),
                      ),
                      Text(
                        'Rs ${amount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: AppFontSize.f16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontFamily: 'Courier',
                        ),
                      ),
                    ],
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'PAYMENT',
                        style: TextStyle(
                          fontSize: AppFontSize.f12,
                          color: Colors.black,
                          fontFamily: 'Courier',
                        ),
                      ),
                      Text(
                        paymentType,
                        style: TextStyle(
                          fontSize: AppFontSize.f12,
                          color: Colors.black,
                          fontFamily: 'Courier',
                        ),
                      ),
                    ],
                  ),
                  if (cardRow.isNotEmpty)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'CARD #',
                          style: TextStyle(
                            fontSize: AppFontSize.f12,
                            color: Colors.black,
                            fontFamily: 'Courier',
                          ),
                        ),
                        Text(
                          cardRow,
                          style: TextStyle(
                            fontSize: AppFontSize.f12,
                            color: Colors.black,
                            fontFamily: 'Courier',
                          ),
                        ),
                      ],
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'AMOUNT',
                        style: TextStyle(
                          fontSize: AppFontSize.f12,
                          color: Colors.black,
                          fontFamily: 'Courier',
                        ),
                      ),
                      Text(
                        'Rs: ${amount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: AppFontSize.f12,
                          color: Colors.black,
                          fontFamily: 'Courier',
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: ch(16)),
                  Text(
                    'MEMBERSHIP VALID THRU: $expiryDate',
                    style: TextStyle(
                      fontSize: AppFontSize.f12,
                      color: Colors.black,
                      fontFamily: 'Courier',
                    ),
                  ),
                  SizedBox(height: ch(16)),
                  const Text(
                    'KEEP PUSHING YOUR LIMITS!',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const Text(
                    'Near Ayesha Masjid Opposite Chaska Unit # 6\nLatifabad Hyderabad',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 10, color: Colors.black),
                  ),
                ],
              ),
            ),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Color(0xFF4B5563)),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                  ),
                  onPressed: () => Navigator.pop(context, true),
                  icon: const Icon(Icons.print, size: 18),
                  label: const Text('Print & Save'),
                ),
              ],
            ),

            SizedBox(height: ch(16)),
          ],
        ),
      ),
    );
  }
}

// void _openPaymentHistory(BuildContext context, Member member) {
//   Navigator.pushNamed(
//     context,
//     AppRoutes.memberPaymentHistory,
//     arguments: member,
//   );
// }

/// Fetches the latest paid payment for a member and shows the receipt dialog.
Future<void> _printLatestReceipt(BuildContext context, Member member) async {
  // Show loading spinner while fetching
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) =>
        const Center(child: CircularProgressIndicator(color: Colors.white)),
  );

  try {
    final snap = await FirebaseFirestore.instance
        .collection('payments')
        .where('memberId', isEqualTo: member.docId)
        .where('status', isEqualTo: 'Paid')
        .get();

    if (context.mounted) Navigator.pop(context); // dismiss spinner

    if (snap.docs.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No paid payment found for this member.'),
          ),
        );
      }
      return;
    }

    // Pick the most recently paid payment (by timestamp or date)
    final docs = snap.docs
        .map((d) => Payment.fromFirestore(d.data(), d.id))
        .toList();
    docs.sort((a, b) {
      final ta = a.timestamp;
      final tb = b.timestamp;
      if (ta == null && tb == null) return 0;
      if (ta == null) return 1;
      if (tb == null) return -1;
      return tb.compareTo(ta);
    });
    final latestPayment = docs.first;

    if (context.mounted) {
      final printConfirmed = await showDialog<bool>(
        context: context,
        builder: (_) => ReceiptPreviewDialog(
          member: member,
          amount: latestPayment.amount,
          selectedMethod: latestPayment.method,
        ),
      );

      if (printConfirmed == true) {
        try {
          final memberData = {
            'name': member.name,
            'gymId': member.id,
            'membership': member.membership,
            'expiryDate': member.expiryDate,
          };
          await AppPrinter.printReceipt(
            memberData,
            latestPayment.amount,
            latestPayment.method,
          );
        } catch (e) {
          debugPrint('Printing error: $e');
        }
      }
    }
  } catch (e) {
    if (context.mounted) Navigator.pop(context);
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching receipt: $e')));
    }
  }
}
