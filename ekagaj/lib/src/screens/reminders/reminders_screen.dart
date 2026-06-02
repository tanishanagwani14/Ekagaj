import 'package:flutter/material.dart';

import '../../routes/ek_routes.dart';
import '../../theme/ek_colors.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/ek_badge.dart';
import '../../widgets/ek_card.dart';
import '../../widgets/ek_fab.dart';
import '../../widgets/gradient_header.dart';

class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final today = const [
      _Reminder(id: 1, title: 'Team Standup Meeting', time: '11:30 AM', category: 'Meeting', priority: _Priority.high),
      _Reminder(id: 2, title: 'Submit Weekly Report', time: '5:00 PM', category: 'Work', priority: _Priority.medium),
      _Reminder(id: 3, title: 'Client Call - Acme Corp', time: '3:00 PM', category: 'Client', priority: _Priority.high),
    ];

    final upcoming = const [
      _UpcomingReminder(id: 4, title: 'Project Deadline', date: 'Tomorrow', time: '12:00 PM', category: 'Deadline', priority: _Priority.high),
      _UpcomingReminder(id: 5, title: 'Performance Review', date: 'May 9', time: '2:00 PM', category: 'HR', priority: _Priority.medium),
      _UpcomingReminder(id: 6, title: 'Team Building Event', date: 'May 10', time: '10:00 AM', category: 'Event', priority: _Priority.low),
    ];

    return Scaffold(
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.zero,
            children: [
              GradientHeader(
                colors: const [Color(0xFFA855F7), EkColors.pink500],
                bottomRadius: 0,
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
              Transform.translate(
                offset: const Offset(0, -24),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text('Today', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: EkColors.gray800, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),
                      ...today.map((r) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: EkCard(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _TileIcon(bg: const Color(0xFFF3E8FF), fg: EkColors.purple600, icon: Icons.notifications_rounded),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(child: Text(r.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: EkColors.gray800, fontWeight: FontWeight.w700))),
                                            EkBadge(r.priority.label, variant: r.priority.badge),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            const Icon(Icons.access_time_rounded, size: 16, color: EkColors.gray500),
                                            const SizedBox(width: 6),
                                            Text(r.time, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: EkColors.gray500)),
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
                      Text('Upcoming', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: EkColors.gray800, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),
                      ...upcoming.map((r) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: EkCard(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _TileIcon(bg: const Color(0xFFDBEAFE), fg: const Color(0xFF2563EB), icon: Icons.calendar_month_rounded),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(child: Text(r.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: EkColors.gray800, fontWeight: FontWeight.w700))),
                                            EkBadge(r.priority.label, variant: r.priority.badge),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            Text(r.date, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: EkColors.gray500)),
                                            const SizedBox(width: 12),
                                            const Icon(Icons.access_time_rounded, size: 16, color: EkColors.gray500),
                                            const SizedBox(width: 6),
                                            Text(r.time, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: EkColors.gray500)),
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
              ),
            ],
          ),
          EkFab(onPressed: () {}),
          const Align(
            alignment: Alignment.bottomCenter,
            child: BottomNav(active: BottomNavItem.home),
          ),
        ],
      ),
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

enum _Priority { high, medium, low }

extension on _Priority {
  String get label => switch (this) {
        _Priority.high => 'high',
        _Priority.medium => 'medium',
        _Priority.low => 'low',
      };

  EkBadgeVariant get badge => switch (this) {
        _Priority.high => EkBadgeVariant.danger,
        _Priority.medium => EkBadgeVariant.warning,
        _Priority.low => EkBadgeVariant.info,
      };
}

class _Reminder {
  const _Reminder({
    required this.id,
    required this.title,
    required this.time,
    required this.category,
    required this.priority,
  });

  final int id;
  final String title;
  final String time;
  final String category;
  final _Priority priority;
}

class _UpcomingReminder {
  const _UpcomingReminder({
    required this.id,
    required this.title,
    required this.date,
    required this.time,
    required this.category,
    required this.priority,
  });

  final int id;
  final String title;
  final String date;
  final String time;
  final String category;
  final _Priority priority;
}

