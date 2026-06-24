import os

filepath = r"c:\Users\CBT-KHI-LAP-RRauf\Desktop\Gym management app (1)\app\lib\screens\members_screen.dart"

with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Replace the entire builder block starting from "Consumer<GymProvider>" up to "phone ? _MobileList("
old_consumer = """            Expanded(
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
                                  )"""

new_consumer = """            Expanded(
              child: Consumer<MembersProvider>(
                builder: (context, state, child) {
                  return Card(
                    child: Padding(
                      padding: EdgeInsets.all(cw(11.2)),
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance.collection('members').snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB)));
                          }
                          if (snapshot.hasError) {
                            return const Center(child: Text('Error loading members'));
                          }

                          final allDocs = snapshot.data?.docs ?? [];
                          final List<Map<String, dynamic>> displayMembers = [];

                          for (var doc in allDocs) {
                            final data = Map<String, dynamic>.from(doc.data() as Map<String, dynamic>);
                            data['id'] = doc.id;
                            
                            // Real-time Overdue calculation
                            final dbStatus = data['status']?.toString() ?? 'Pending';
                            String realStatus = dbStatus;
                            if (dbStatus.toLowerCase() != 'deactivated') {
                              final plan = data['membership']?.toString().toLowerCase() ?? '';
                              final lastPayment = data['lastPaymentDate']?.toString();
                              if (lastPayment != null && lastPayment.isNotEmpty) {
                                final parsed = DateTime.tryParse(lastPayment);
                                if (parsed != null) {
                                  final days = DateTime.now().difference(parsed).inDays;
                                  if (plan.contains('monthly') && days > 30) {
                                    realStatus = 'Overdue';
                                  } else if ((plan.contains('yearly') || plan.contains('annual')) && days > 365) {
                                    realStatus = 'Overdue';
                                  }
                                }
                              }
                            }
                            data['realStatus'] = realStatus;

                            // Apply filters
                            final name = data['name']?.toString().toLowerCase() ?? '';
                            final email = data['email']?.toString().toLowerCase() ?? '';
                            final s = state.search.toLowerCase();
                            if (s.isNotEmpty && !name.contains(s) && !email.contains(s)) {
                              continue;
                            }
                            if (state.filterStatus != 'all' && realStatus.toLowerCase() != state.filterStatus.toLowerCase()) {
                              continue;
                            }
                            
                            displayMembers.add(data);
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(
                                txt: 'All Members (${displayMembers.length})',
                                fontSize: AppFontSize.f13,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF111827),
                              ),
                              SizedBox(height: ch(12.2)),
                              Expanded(
                                child: phone
                                    ? _MobileList(
                                        members: displayMembers,
                                        onDelete: (id) {},
                                        onEdit: (data) => print(data),
                                      )"""

content = content.replace(old_consumer, new_consumer)

# 2. Add ending braces for StreamBuilder
old_table_end = """                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),"""
new_table_end = """                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),"""
content = content.replace(old_table_end, new_table_end)

# 3. Replace rows generation in DataTable
old_rows_start = """                                        rows: filtered.map((m) {
                                          return DataRow(
                                            cells: [
                                              /// Gym Id
                                              DataCell(
                                                AppText(
                                                  txt: m.gymId,
                                                  fontSize: AppFontSize.f16,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),

                                              /// Member
                                              DataCell(
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    AppText(
                                                      txt: m.name,
                                                      fontSize: AppFontSize.f16,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                    SizedBox(height: ch(5)),
                                                    AppText(
                                                      txt:
                                                          'Joined ${m.joinDate}',
                                                      fontSize: AppFontSize.f13,
                                                      color: const Color(
                                                        0xFF9CA3AF,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              /// Contact
                                              DataCell(
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        const Icon(
                                                          Icons.email_outlined,
                                                        ),
                                                        const SizedBox(
                                                          width: 4,
                                                        ),
                                                        AppText(txt: m.email),
                                                      ],
                                                    ),
                                                    SizedBox(height: ch(5)),
                                                    Row(
                                                      children: [
                                                        const Icon(
                                                          Icons.phone_outlined,
                                                        ),
                                                        SizedBox(width: cw(4)),
                                                        AppText(txt: m.phone),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              /// Membership
                                              DataCell(
                                                _Chip(
                                                  label: m.membership,
                                                  color:
                                                      const Color(0xFF7C3AED),
                                                  bg: const Color(0xFFF5F3FF),
                                                ),
                                              ),

                                              /// Status
                                              DataCell(
                                                StatusBadge(status: m.status),
                                              ),

                                              /// Expiry
                                              // DataCell(
                                              //   AppText(txt: m.expiryDate),
                                              // ),

                                              /// Actions
                                              DataCell(
                                                Row(
                                                  children: [
                                                    IconButton(
                                                      icon: const Icon(
                                                        Icons.payments,
                                                      ),
                                                      onPressed: () {
                                                        _showPaymentDialog(
                                                          context,
                                                          m.id.toString(),
                                                          m, // This is Member, we will need to change this
                                                        );
                                                      },
                                                    ),
                                                    IconButton(
                                                      icon: const Icon(
                                                        Icons.edit_outlined,
                                                      ),
                                                      onPressed: () {
                                                        print(m);
                                                      },
                                                    ),
                                                    IconButton(
                                                      icon: const Icon(
                                                        Icons.delete_outline,
                                                      ),
                                                      onPressed: () {
                                                        gymProvider
                                                            .deleteMember(m.id);
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          );
                                        }).toList(),"""

new_rows_start = """                                        rows: displayMembers.map((m) {
                                          return DataRow(
                                            cells: [
                                              DataCell(AppText(txt: m['gymId']?.toString() ?? '', fontSize: AppFontSize.f16, fontWeight: FontWeight.w500)),
                                              DataCell(
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    AppText(txt: m['name']?.toString() ?? '', fontSize: AppFontSize.f16, fontWeight: FontWeight.w500),
                                                    SizedBox(height: ch(5)),
                                                    AppText(txt: 'Joined ${m['joinDate']?.toString() ?? ''}', fontSize: AppFontSize.f13, color: const Color(0xFF9CA3AF)),
                                                  ],
                                                ),
                                              ),
                                              DataCell(
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Row(children: [const Icon(Icons.email_outlined, size: 14), const SizedBox(width: 4), AppText(txt: m['email']?.toString() ?? '', fontSize: 13)]),
                                                    SizedBox(height: ch(5)),
                                                    Row(children: [const Icon(Icons.phone_outlined, size: 14), SizedBox(width: cw(4)), AppText(txt: m['phone']?.toString() ?? '', fontSize: 13)]),
                                                  ],
                                                ),
                                              ),
                                              DataCell(_Chip(label: m['membership']?.toString() ?? '', color: const Color(0xFF7C3AED), bg: const Color(0xFFF5F3FF))),
                                              DataCell(StatusBadge(status: m['realStatus']?.toString() ?? '')),
                                              DataCell(
                                                Row(
                                                  children: [
                                                    IconButton(
                                                      icon: const Icon(Icons.payments),
                                                      onPressed: () => _showPaymentDialog(context, m['id'].toString(), m),
                                                    ),
                                                    IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () => print(m)),
                                                    IconButton(icon: const Icon(Icons.delete_outline), onPressed: () {}),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          );
                                        }).toList(),"""

if old_rows_start in content:
    content = content.replace(old_rows_start, new_rows_start)
else:
    # Try alternate without .toString() on id
    alt_rows = old_rows_start.replace("m.id.toString()", "m.id").replace("m, // This is Member, we will need to change this", "m,")
    content = content.replace(alt_rows, new_rows_start)

# 4. _MobileList class signature and property access
old_mobile_list = """class _MobileList extends StatelessWidget {
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
                      m.name.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        color: const Color(0xFF2563EB),
                        fontWeight: FontWeight.w600,
                        fontSize: AppFontSize.f14,
                      ),
                    ),
                  ),
                  SizedBox(width: cw(11.2)),
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
                      color: Color(0xFF9CA3AF),
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
                      color: Color(0xFFEF4444),
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => onDelete(m.id),
                  ),
                ],
              ),
              SizedBox(height: ch(12.2)),
              Row(
                children: [
                  const Icon(
                    Icons.email_outlined,
                    size: 14,
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
                    ),
                  ),
                ],
              ),
              SizedBox(height: ch(6.5)),
              Row(
                children: [
                  const Icon(
                    Icons.phone_outlined,
                    size: 14,
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
}"""

new_mobile_list = """class _MobileList extends StatelessWidget {
  const _MobileList({
    required this.members,
    required this.onDelete,
    required this.onEdit,
  });
  final List<Map<String, dynamic>> members;
  final void Function(String) onDelete;
  final void Function(Map<String, dynamic>) onEdit;

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
        final name = m['name']?.toString() ?? '';
        final initial = name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '';
        
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
                      initial,
                      style: TextStyle(
                        color: const Color(0xFF2563EB),
                        fontWeight: FontWeight.w600,
                        fontSize: AppFontSize.f14,
                      ),
                    ),
                  ),
                  SizedBox(width: cw(11.2)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: AppFontSize.f15,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF111827),
                          ),
                        ),
                        Text(
                          m['membership']?.toString() ?? '',
                          style: TextStyle(
                            fontSize: AppFontSize.f11,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  StatusBadge(status: m['realStatus']?.toString() ?? ''),
                  IconButton(
                    icon: const Icon(
                      Icons.payments,
                      size: 18,
                      color: Color(0xFF10B981),
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      _showPaymentDialog(
                        context,
                        m['id'].toString(),
                        m,
                      );
                    },
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(
                      Icons.edit_outlined,
                      size: 18,
                      color: Color(0xFF9CA3AF),
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
                      color: Color(0xFFEF4444),
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => onDelete(m['id'].toString()),
                  ),
                ],
              ),
              SizedBox(height: ch(12.2)),
              Row(
                children: [
                  const Icon(
                    Icons.email_outlined,
                    size: 14,
                    color: Color(0xFF9CA3AF),
                  ),
                  SizedBox(width: cw(5.6)),
                  Expanded(
                    child: Text(
                      m['email']?.toString() ?? '',
                      style: TextStyle(
                        fontSize: AppFontSize.f11,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: ch(6.5)),
              Row(
                children: [
                  const Icon(
                    Icons.phone_outlined,
                    size: 14,
                    color: Color(0xFF9CA3AF),
                  ),
                  SizedBox(width: cw(5.6)),
                  Text(
                    m['phone']?.toString() ?? '',
                    style: TextStyle(
                      fontSize: AppFontSize.f11,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Exp: ${m['expiryDate']?.toString() ?? ''}',
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
}"""

content = content.replace(old_mobile_list, new_mobile_list)

# 5. Fix _showPaymentDialog
content = content.replace("""void _showPaymentDialog(
  BuildContext context,
  String docId,
  dynamic member,
) {""", """void _showPaymentDialog(
  BuildContext context,
  String docId,
  Map<String, dynamic> memberData,
) {""")

content = content.replace("""void _showPaymentDialog(
  BuildContext context,
  String docId,
  Member member,
) {""", """void _showPaymentDialog(
  BuildContext context,
  String docId,
  Map<String, dynamic> memberData,
) {""")

content = content.replace("final plan = member.membership;", "final plan = memberData['membership']?.toString() ?? '';")
content = content.replace("Text('Member: ${member.name}'),", "Text('Member: ${memberData[\"name\"] ?? \"\"}'),")
content = content.replace("Text('Gym ID: ${member.gymId}'),", "Text('Gym ID: ${memberData[\"gymId\"] ?? \"\"}'),")


# 6. Process action
old_process_action = """              final success = await provider.processPayment(
                docId: docId.toString(),
                memberData: {
                  'name': member.name,
                  'gymId': member.gymId,
                  'membership': member.membership,
                }, // Note: We need real memberData
                amount: amount,
                method: method,
              );

              if (success && ctx.mounted) {
                Navigator.pop(ctx);
                _showReceipt(context, member, amount, method);
              } else if (!success && ctx.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Payment failed. Please try again.'),
                  ),
                );
              }"""

new_process_action = """              final errorMsg = await provider.processPayment(
                docId: docId,
                memberData: memberData,
                amount: amount,
                method: method,
              );

              if (errorMsg == null && ctx.mounted) {
                Navigator.pop(ctx);
                _showReceipt(context, memberData, amount, method);
              } else if (errorMsg != null && ctx.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(errorMsg),
                    backgroundColor: Colors.red.shade600,
                  ),
                );
              }"""
if old_process_action in content:
    content = content.replace(old_process_action, new_process_action)
else:
    content = content.replace("""              final success = await provider.processPayment(
                docId: docId,
                memberData: {
                  'name': member.name,
                  'gymId': member.gymId,
                  'membership': member.membership,
                },
                amount: amount,
                method: method,
              );

              if (success && ctx.mounted) {
                Navigator.pop(ctx);
                _showReceipt(context, member, amount, method);
              } else if (!success && ctx.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Payment failed. Please try again.'),
                  ),
                );
              }""", new_process_action)

content = content.replace("""              final success = await provider.processPayment(
                docId: docId,
                memberData: {
                  'name': member.name,
                  'gymId': member.gymId,
                  'membership': member.membership,
                }, // Note: We need real memberData
                amount: amount,
                method: method,
              );

              if (success && ctx.mounted) {
                Navigator.pop(ctx);
                _showReceipt(context, member, amount, method);
              } else if (!success && ctx.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Payment failed. Please try again.'),
                  ),
                );
              }""", new_process_action)

content = content.replace("void _showReceipt(\n  BuildContext context,\n  Member member,", "void _showReceipt(\n  BuildContext context,\n  Map<String, dynamic> memberData,")
content = content.replace("void _showReceipt(\n  BuildContext context,\n  dynamic member,", "void _showReceipt(\n  BuildContext context,\n  Map<String, dynamic> memberData,")
content = content.replace("AppPrinter.printReceipt(\n                {\n                  'name': member.name,\n                  'gymId': member.gymId,\n                  'membership': member.membership,\n                },", "AppPrinter.printReceipt(\n                memberData,")


# Print out
with open(filepath, 'w', encoding='utf-8') as f:
    f.write(content)

print("done")
