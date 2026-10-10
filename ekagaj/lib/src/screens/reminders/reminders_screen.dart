import 'package:flutter/material.dart';

import '../../models/reminder_record.dart';
import '../../routes/ek_routes.dart';
import '../../services/app_session.dart';
import '../../services/reminder_repository.dart';
import '../../services/reminder_time_parser.dart';
import '../../theme/ek_colors.dart';
import '../../theme/ek_theme_context.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/ek_badge.dart';
import '../../widgets/ek_card.dart';
import '../../widgets/ek_fab.dart';
import '../../widgets/gradient_header.dart';

enum _ReminderWhen { today, upcoming }

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  Future<void> _showAddReminderDialog() async {
    final result = await showDialog<_AddReminderResult>(
      context: context,
      builder: (dialogContext) => _AddReminderDialog(hostContext: dialogContext),
    );

    if (result == null || !mounted) return;

    final userId = AppSession.profile.value?.id ?? '';
    final remindAt = parseReminderDateTime(
      timeLabel: result.time,
      dateLabel: result.date,
      defaultToday: result.when == _ReminderWhen.today,
    );

    try {
      await ReminderRepository.addReminder(
        userId: userId,
        title: result.title,
        timeLabel: result.time,
        category: result.category,
        priority: result.priority,
        isToday: result.when == _ReminderWhen.today,
        dateLabel: result.date,
        remindAt: remindAt,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            remindAt != null ? 'Reminder saved with alarm.' : 'Reminder saved.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save reminder: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textPrimary = context.ekTextPrimary;
    final textSecondary = context.ekTextSecondary;
    final userId = AppSession.profile.value?.id ?? '';

    return Scaffold(
      body: StreamBuilder<List<ReminderRecord>>(
        stream: ReminderRepository.watchForUser(userId),
        builder: (context, snap) {
          final all = snap.data ?? const [];
          final today = all.where((r) => r.isToday).toList();
          final upcoming = all.where((r) => !r.isToday).toList();

          if (snap.connectionState == ConnectionState.waiting && all.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return Stack(
        children: [
          ListView(
            padding: EdgeInsets.zero,
            children: [
              GradientHeader(
                colors: const [Color(0xFFA855F7), EkColors.pink500],
                bottomRadius: 40,
                padding: const EdgeInsets.fromLTRB(24, 56, 24, 32),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _IconHeaderButton(
                          icon: Icons.arrow_back_rounded,
                          onTap: () => Navigator.of(context).pushReplacementNamed(EkRoutes.home),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              'Reminders',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                        const SizedBox(width: 40),
                      ],
                    ),
                    const SizedBox(height: 20),
                    EkCard(
                      variant: EkCardVariant.gradient,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.30)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Today', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white.withValues(alpha: 0.8))),
                              const SizedBox(height: 6),
                              Text('${today.length}', style: Theme.of(context).textTheme.displaySmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('This Week', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white.withValues(alpha: 0.8))),
                              const SizedBox(height: 6),
                              Text('${today.length + upcoming.length}', style: Theme.of(context).textTheme.displaySmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Today',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                      const SizedBox(height: 12),
                      ...today.map((r) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: EkCard(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _TileIcon(bg: context.ekIconTileBg, fg: EkColors.purple600, icon: Icons.notifications_rounded),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                r.title,
                                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                      color: textPrimary,
                                                      fontWeight: FontWeight.w700,
                                                    ),
                                              ),
                                            ),
                                            EkBadge(r.priority.label, variant: _priorityBadge(r.priority)),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            Icon(Icons.access_time_rounded, size: 16, color: textSecondary),
                                            const SizedBox(width: 6),
                                            Text(r.timeLabel, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: textSecondary)),
                                            const SizedBox(width: 12),
                                            EkBadge(r.category, variant: EkBadgeVariant.primary),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )),
                      const SizedBox(height: 12),
                    Text(
                      'Upcoming',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                      const SizedBox(height: 12),
                      ...upcoming.map((r) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: EkCard(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _TileIcon(
                                    bg: context.isDark ? const Color(0xFF1E3A5F) : const Color(0xFFDBEAFE),
                                    fg: const Color(0xFF2563EB),
                                    icon: Icons.calendar_month_rounded,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                r.title,
                                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                      color: textPrimary,
                                                      fontWeight: FontWeight.w700,
                                                    ),
                                              ),
                                            ),
                                            EkBadge(r.priority.label, variant: _priorityBadge(r.priority)),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            Text(r.dateLabel ?? '', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: textSecondary)),
                                            const SizedBox(width: 12),
                                            Icon(Icons.access_time_rounded, size: 16, color: textSecondary),
                                            const SizedBox(width: 6),
                                            Text(r.timeLabel, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: textSecondary)),
                                            const SizedBox(width: 12),
                                            EkBadge(r.category, variant: EkBadgeVariant.primary),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ],
          ),
          EkFab(onPressed: _showAddReminderDialog),
          const Align(
            alignment: Alignment.bottomCenter,
            child: BottomNav(active: BottomNavItem.home),
          ),
        ],
      );
        },
      ),
    );
  }
}

EkBadgeVariant _priorityBadge(ReminderPriority priority) => switch (priority) {
      ReminderPriority.high => EkBadgeVariant.danger,
      ReminderPriority.medium => EkBadgeVariant.warning,
      ReminderPriority.low => EkBadgeVariant.info,
    };

class _AddReminderResult {
  const _AddReminderResult({
    required this.title,
    required this.time,
    required this.category,
    required this.priority,
    required this.when,
    this.date,
  });

  final String title;
  final String time;
  final String category;
  final ReminderPriority priority;
  final _ReminderWhen when;
  final String? date;
}

class _AddReminderDialog extends StatefulWidget {
  const _AddReminderDialog({required this.hostContext});

  final BuildContext hostContext;

  @override
  State<_AddReminderDialog> createState() => _AddReminderDialogState();
}

class _AddReminderDialogState extends State<_AddReminderDialog> {
  final _title = TextEditingController();
  final _time = TextEditingController();
  final _date = TextEditingController();
  final _category = TextEditingController();
  ReminderPriority _priority = ReminderPriority.medium;
  _ReminderWhen _when = _ReminderWhen.today;

  @override
  void dispose() {
    _title.dispose();
    _time.dispose();
    _date.dispose();
    _category.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _title.text.trim();
    final time = _time.text.trim();
    if (title.isEmpty || time.isEmpty) {
      ScaffoldMessenger.of(widget.hostContext).showSnackBar(
        const SnackBar(content: Text('Title and time are required.')),
      );
      return;
    }

    String? date;
    if (_when == _ReminderWhen.upcoming) {
      date = _date.text.trim();
      if (date.isEmpty) {
        ScaffoldMessenger.of(widget.hostContext).showSnackBar(
          const SnackBar(content: Text('Date is required for upcoming reminders.')),
        );
        return;
      }
    }

    final category = _category.text.trim().isEmpty ? 'General' : _category.text.trim();

    Navigator.of(context).pop(
      _AddReminderResult(
        title: title,
        time: time,
        category: category,
        priority: _priority,
        when: _when,
        date: date,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Reminder'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _title,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Title *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            SegmentedButton<_ReminderWhen>(
              segments: const [
                ButtonSegment(value: _ReminderWhen.today, label: Text('Today')),
                ButtonSegment(value: _ReminderWhen.upcoming, label: Text('Upcoming')),
              ],
              selected: {_when},
              onSelectionChanged: (selection) {
                if (selection.isEmpty) return;
                setState(() => _when = selection.first);
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _time,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Time *',
                hintText: 'e.g. 2:00 PM',
                border: OutlineInputBorder(),
              ),
            ),
            if (_when == _ReminderWhen.upcoming) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _date,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Date *',
                  hintText: 'e.g. Tomorrow',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
            const SizedBox(height: 12),
            TextField(
              controller: _category,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<ReminderPriority>(
              initialValue: _priority,
              decoration: const InputDecoration(
                labelText: 'Priority',
                border: OutlineInputBorder(),
              ),
              items: ReminderPriority.values
                  .map((p) => DropdownMenuItem(value: p, child: Text(p.label)))
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _priority = value);
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Add'),
        ),
      ],
    );
  }
}

class _IconHeaderButton extends StatelessWidget {
  const _IconHeaderButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.20),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, size: 20, color: Colors.white),
      ),
    );
  }
}

class _TileIcon extends StatelessWidget {
  const _TileIcon({required this.bg, required this.fg, required this.icon});

  final Color bg;
  final Color fg;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
      child: Icon(icon, color: fg, size: 22),
    );
  }
}

