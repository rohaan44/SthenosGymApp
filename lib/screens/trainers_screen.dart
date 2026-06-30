import 'package:app/ui/utils/app_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/gym_provider.dart';
import '../shared_widgets.dart';
import '../ui/helpers/app_layout_helper.dart';
import 'package:app/ui/helpers/font_size_helper.dart';

class TrainersState extends ChangeNotifier {
  String _search = '';

  String get search => _search;

  void setSearch(String value) {
    _search = value;
    notifyListeners();
  }

  List<Trainer> filtered(List<Trainer> trainers) => trainers
      .where(
        (t) =>
            t.name.toLowerCase().contains(_search.toLowerCase()) ||
            t.specialization.toLowerCase().contains(_search.toLowerCase()),
      )
      .toList();
}

class TrainersScreen extends StatelessWidget {
  const TrainersScreen({super.key});

  void _showAddDialog(BuildContext context) {
    final provider = context.read<GymProvider>();
    final nameCtrl = TextEditingController();
    final specCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: AppText(
          txt: 'Add New Trainer',
          fontSize: AppFontSize.f13,
          fontWeight: FontWeight.w500,
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              customTf('Full Name', nameCtrl),
              const SizedBox(height: 12),
              customTf('Specialization', specCtrl),
              const SizedBox(height: 12),
              customTf('Email', emailCtrl),
              const SizedBox(height: 12),
              customTf('Phone', phoneCtrl),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (nameCtrl.text.isEmpty) return;
              provider.addTrainer(
                Trainer(
                  id: provider.trainers.length + 1,
                  name: nameCtrl.text,
                  specialization: specCtrl.text,
                  email: emailCtrl.text,
                  phone: phoneCtrl.text,
                  rating: 5.0,
                  classes: 0,
                  status: 'Active',
                  joinDate: 'Jun 2026',
                ),
              );
              Navigator.pop(ctx);
            },
            child: const Text('Add Trainer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TrainersState(),
      child: Builder(
        builder: (context) {
          final phone = isPhone(context);

          return Scaffold(
            backgroundColor: const Color(0xFFF9FAFB),
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
                            Text(
                              'Trainers',
                              style: TextStyle(
                                fontSize: AppFontSize.f19,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF111827),
                              ),
                            ),
                            Text(
                              'Manage your fitness trainers',
                              style: TextStyle(
                                fontSize: AppFontSize.f12,
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                            SizedBox(height: ch(12.2)),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                onPressed: () => _showAddDialog(context),
                                icon: const Icon(Icons.add, size: 18),
                                label: const Text('Add Trainer'),
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
                                Text(
                                  'Trainers',
                                  style: TextStyle(
                                    fontSize: AppFontSize.f19,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF111827),
                                  ),
                                ),
                                Text(
                                  'Manage your fitness trainers',
                                  style: TextStyle(
                                    fontSize: AppFontSize.f12,
                                    color: const Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                            FilledButton.icon(
                              onPressed: () => _showAddDialog(context),
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('Add Trainer'),
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF2563EB),
                              ),
                            ),
                          ],
                        ),

                  SizedBox(height: ch(16.2)),

                  Consumer<TrainersState>(
                    builder: (context, state, child) {
                      final provider = context.watch<GymProvider>();
                      final filtered = state.filtered(provider.trainers);
                      
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Search ────────────────────────────────────────────────────────
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(cw(11.2)),
                      child: TextField(
                        decoration:
                            customInputDecoration(
                              label: 'Search trainers...',
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
                  ),

                  SizedBox(height: ch(12.2)),

                  Text(
                    'All Trainers (${filtered.length})',
                    style: TextStyle(
                      fontSize: AppFontSize.f13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  SizedBox(height: ch(9.7)),

                  // ── Responsive grid: 1/2/3 cols ──────────────────────────────────
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final w = constraints.maxWidth;
                      final crossAxis = w > 900 ? 3 : (w > 560 ? 2 : 1);
                      final aspectRatio = w > 900 ? 2.0 : (w > 560 ? 1.9 : 2.1);
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
                        itemBuilder: (_, i) => _TrainerCard(
                          trainer: filtered[i],
                          onDelete: () => context
                              .read<GymProvider>()
                              .deleteTrainer(filtered[i].id),
                        ),
                      );
                    },
                  ),

                          SizedBox(height: ch(16.2)),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _TrainerCard extends StatelessWidget {
  const _TrainerCard({required this.trainer, required this.onDelete});
  final Trainer trainer;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(cw(11.2)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: cw(15.0).clamp(18.0, 26.0),
                  backgroundColor: const Color(0xFFEFF6FF),
                  child: Text(
                    trainer.name[0],
                    style: TextStyle(
                      fontSize: AppFontSize.f17,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2563EB),
                    ),
                  ),
                ),
                SizedBox(width: cw(7.5)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trainer.name,
                        style: TextStyle(
                          fontSize: AppFontSize.f15,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF111827),
                        ),
                      ),
                      Text(
                        trainer.specialization,
                        style: TextStyle(
                          fontSize: AppFontSize.f11,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                StatusBadge(status: trainer.status),
              ],
            ),
            SizedBox(height: ch(8.1)),
            Row(
              children: [
                _infoChip(
                  Icons.star,
                  '${trainer.rating}',
                  const Color(0xFFFBBF24),
                ),
                SizedBox(width: cw(7.5)),
                _infoChip(
                  Icons.calendar_today_outlined,
                  '${trainer.classes} classes',
                  const Color(0xFF6B7280),
                ),
              ],
            ),
            SizedBox(height: ch(6.5)),
            _infoRow(Icons.email_outlined, trainer.email),
            SizedBox(height: ch(3.2)),
            _infoRow(Icons.phone_outlined, trainer.phone),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Since ${trainer.joinDate}',
                  style: TextStyle(
                    fontSize: AppFontSize.f9,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: Color(0xFFDC2626),
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String text, Color color) => Row(
    children: [
      Icon(icon, size: 14, color: color),
      const SizedBox(width: 4),
      Text(
        text,
        style: TextStyle(
          fontSize: AppFontSize.f11,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    ],
  );

  Widget _infoRow(IconData icon, String text) => Row(
    children: [
      Icon(icon, size: 13, color: const Color(0xFF9CA3AF)),
      const SizedBox(width: 6),
      Expanded(
        child: Text(
          text,
          style: TextStyle(
            fontSize: AppFontSize.f11,
            color: const Color(0xFF6B7280),
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );
}
