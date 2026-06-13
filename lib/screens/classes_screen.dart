import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/gym_provider.dart';
import '../shared_widgets.dart';
import '../ui/helpers/app_layout_helper.dart';
import 'package:app/ui/helpers/font_size_helper.dart';


class ClassesState extends ChangeNotifier {
  String _search = '';
  String _filterCategory = 'all';

  String get search => _search;
  String get filterCategory => _filterCategory;

  void setSearch(String value) {
    _search = value;
    notifyListeners();
  }

  void setFilterCategory(String value) {
    _filterCategory = value;
    notifyListeners();
  }

  List<String> categories(List<GymClass> classes) =>
      ['all', ...{...classes.map((c) => c.category)}];

  List<GymClass> filtered(List<GymClass> classes) => classes.where((c) {
        final matchSearch = c.name.toLowerCase().contains(_search.toLowerCase()) ||
            c.trainer.toLowerCase().contains(_search.toLowerCase());
        final matchCat = _filterCategory == 'all' || c.category == _filterCategory;
        return matchSearch && matchCat;
      }).toList();
}

class ClassesScreen extends StatelessWidget {
  const ClassesScreen({super.key});

  void _showAddDialog(BuildContext context) {
    final provider = context.read<GymProvider>();
    final nameCtrl = TextEditingController();
    final trainerCtrl = TextEditingController();
    final scheduleCtrl = TextEditingController();
    final timeCtrl = TextEditingController();
    final capacityCtrl = TextEditingController();
    String category = 'Yoga';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Add New Class'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              customTf('Class Name', nameCtrl),
              const SizedBox(height: 12),
              customTf('Trainer', trainerCtrl),
              const SizedBox(height: 12),
              customTf('Schedule (e.g. Mon, Wed)', scheduleCtrl),
              const SizedBox(height: 12),
              customTf('Time (e.g. 7:00 AM)', timeCtrl),
              const SizedBox(height: 12),
              customTf('Capacity', capacityCtrl, type: TextInputType.number),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: category,
                decoration: customInputDecoration('Category'),
                items: ['Yoga', 'Cardio', 'Strength', 'Pilates', 'Boxing']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setS(() => category = v!),
              ),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                if (nameCtrl.text.isEmpty) return;
                provider.addClass(GymClass(
                  id: provider.classes.length + 1,
                  name: nameCtrl.text,
                  trainer: trainerCtrl.text,
                  schedule: scheduleCtrl.text,
                  time: timeCtrl.text,
                  capacity: int.tryParse(capacityCtrl.text) ?? 20,
                  enrolled: 0,
                  category: category,
                  status: 'Active',
                ));
                Navigator.pop(ctx);
              },
              child: const Text('Add Class'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ClassesState(),
      child: Consumer<ClassesState>(
        builder: (context, state, child) {
          final provider = context.watch<GymProvider>();
          final classes = provider.classes;
          final filtered = state.filtered(classes);
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
                  Text('Classes',
                      style: TextStyle(
                          fontSize: AppFontSize.f19,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF111827))),
                  Text('Manage class schedules and capacity',
                      style: TextStyle(fontSize: AppFontSize.f12, color: const Color(0xFF6B7280))),
                  SizedBox(height: ch(12.2)),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => _showAddDialog(context),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add Class'),
                      style: FilledButton.styleFrom(backgroundColor: const Color(0xFF2563EB)),
                    ),
                  ),
                ])
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Classes',
                          style: TextStyle(
                              fontSize: AppFontSize.f19,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF111827))),
                      Text('Manage class schedules and capacity',
                          style: TextStyle(fontSize: AppFontSize.f12, color: const Color(0xFF6B7280))),
                    ]),
                    FilledButton.icon(
                      onPressed: () => _showAddDialog(context),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add Class'),
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
                        decoration: customInputDecoration('Search classes...').copyWith(
                          prefixIcon: const Icon(Icons.search, size: 18, color: Color(0xFF9CA3AF)),
                        ),
                        onChanged: (v) => state.setSearch(v),
                      ),
                      SizedBox(height: ch(9.7)),
                      DropdownButtonFormField<String>(
                        initialValue: state.filterCategory,
                        isExpanded: true,
                        decoration: customInputDecoration('Category'),
                        items: state.categories(classes)
                            .map((c) => DropdownMenuItem(
                                value: c, child: Text(c == 'all' ? 'All Categories' : c)))
                            .toList(),
                        onChanged: (v) => state.setFilterCategory(v!),
                      ),
                    ])
                  : Row(children: [
                      Expanded(
                        child: TextField(
                          decoration: customInputDecoration('Search classes...').copyWith(
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
                          initialValue: state.filterCategory,
                          decoration: customInputDecoration('Category'),
                          items: state.categories(classes)
                              .map((c) => DropdownMenuItem(
                                  value: c, child: Text(c == 'all' ? 'All Categories' : c)))
                              .toList(),
                          onChanged: (v) => state.setFilterCategory(v!),
                        ),
                      ),
                    ]),
            ),
          ),

          SizedBox(height: ch(12.2)),

          Text('All Classes (${filtered.length})',
              style: TextStyle(
                  fontSize: AppFontSize.f13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF111827))),
          SizedBox(height: ch(9.7)),

          // ── Responsive grid: 1/2/3 cols ──────────────────────────────────
          LayoutBuilder(builder: (context, constraints) {
            final w = constraints.maxWidth;
            final crossAxis = w > 900 ? 3 : (w > 560 ? 2 : 1);
            final aspectRatio = w > 900 ? 1.8 : (w > 560 ? 1.7 : 1.9);
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxis,
                crossAxisSpacing: cw(7.5),
                mainAxisSpacing: ch(12.2),
                childAspectRatio: aspectRatio,
              ),
              itemCount: filtered.length,
              itemBuilder: (_, i) => _ClassCard(gymClass: filtered[i]),
            );
          }),

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
class _ClassCard extends StatelessWidget {
  const _ClassCard({required this.gymClass});
  final GymClass gymClass;

  @override
  Widget build(BuildContext context) {
    final pct = gymClass.enrolled / gymClass.capacity;
    final isFull = gymClass.status == 'Full';

    return Card(
      child: Padding(
        padding: EdgeInsets.all(cw(11.2)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(
              child: Text(gymClass.name,
                  style: TextStyle(
                      fontSize: AppFontSize.f13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF111827)),
                  overflow: TextOverflow.ellipsis),
            ),
            StatusBadge(status: isFull ? 'Full' : gymClass.status),
          ]),
          SizedBox(height: ch(6.5)),
          _infoRow(Icons.person_outline, gymClass.trainer),
          SizedBox(height: ch(4.1)),
          _infoRow(Icons.schedule_outlined, '${gymClass.schedule} · ${gymClass.time}'),
          SizedBox(height: ch(4.1)),
          _infoRow(Icons.category_outlined, gymClass.category),
          const Spacer(),
          Row(children: [
            Expanded(
              child: LinearProgressIndicator(
                value: pct.clamp(0.0, 1.0),
                backgroundColor: const Color(0xFFE5E7EB),
                color: isFull ? const Color(0xFFDC2626) : const Color(0xFF2563EB),
                borderRadius: BorderRadius.circular(4),
                minHeight: 6,
              ),
            ),
            SizedBox(width: cw(7.5)),
            Text('${gymClass.enrolled}/${gymClass.capacity}',
                style: TextStyle(fontSize: AppFontSize.f11, color: const Color(0xFF6B7280))),
          ]),
        ]),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) => Row(children: [
        Icon(icon, size: 13, color: const Color(0xFF9CA3AF)),
        const SizedBox(width: 6),
        Expanded(
            child: Text(text,
                style: TextStyle(fontSize: AppFontSize.f11, color: const Color(0xFF6B7280)),
                overflow: TextOverflow.ellipsis)),
      ]);
}
