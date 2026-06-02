import 'package:flutter/material.dart';

import '../../routes/ek_routes.dart';
import '../../theme/ek_colors.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/ek_badge.dart';
import '../../widgets/ek_card.dart';
import '../../widgets/gradient_header.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final todayTasks = const [
      _Task(id: 1, title: 'Review Q2 Report', time: '10:00 AM', priority: _Priority.high),
      _Task(id: 2, title: 'Team Standup Meeting', time: '11:30 AM', priority: _Priority.medium),
      _Task(id: 3, title: 'Client Follow-up Call', time: '2:00 PM', priority: _Priority.high),
    ];

    final actions = const [
      _QuickAction(label: 'Attendance', route: EkRoutes.attendance, icon: Icons.calendar_month_rounded, colors: [Color(0xFF4ADE80), Color(0xFF16A34A)]),
      _QuickAction(label: 'Tasks', route: EkRoutes.tasks, icon: Icons.check_circle_rounded, colors: [Color(0xFF60A5FA), Color(0xFF2563EB)]),
      _QuickAction(label: 'Follow-ups', route: EkRoutes.followUps, icon: Icons.access_time_rounded, colors: [Color(0xFFFB923C), Color(0xFFEA580C)]),
      _QuickAction(label: 'Reminders', route: EkRoutes.reminders, icon: Icons.notifications_rounded, colors: [Color(0xFFA78BFA), Color(0xFF7C3AED)]),
    ];

    return Scaffold(
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.zero,
            children: [
              GradientHeader(
                colors: const [EkColors.blue500, EkColors.purple600],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Good Morning',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.8),
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Sarah Anderson',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            _HeaderIconButton(
                              icon: Icons.notifications_none_rounded,
                              onTap: () => Navigator.of(context).pushNamed(EkRoutes.notifications),
                            ),
                            const SizedBox(width: 12),
                            _HeaderIconButton(
                              icon: Icons.settings_outlined,
                              onTap: () => Navigator.of(context).pushNamed(EkRoutes.settings),
                            ),
                          ],
                        ),
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
                              Text(
                                'Attendance Today',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.white.withValues(alpha: 0.8),
                                    ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '9:00 AM',
                                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const EkBadge(
                                'On Time',
                                background: Color(0x33FFFFFF),
                                foreground: Colors.white,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'May 7, 2026',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.white.withValues(alpha: 0.8),
                                    ),
                              ),
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
                    children: [
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: actions
                            .map(
                              (a) => _QuickActionButton(action: a),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Today's Tasks",
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: EkColors.gray800,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pushNamed(EkRoutes.tasks),
                            child: const Text('View All'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...todayTasks.map((t) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: EkCard(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF3E8FF),
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        child: const Icon(Icons.check_circle_rounded, color: EkColors.purple600),
                                      ),
                                      const SizedBox(width: 12),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(t.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: EkColors.gray800, fontWeight: FontWeight.w700)),
                                          const SizedBox(height: 2),
                                          Text(t.time, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: EkColors.gray500)),
                                        ],
                                      ),
                                    ],
                                  ),
                                  EkBadge(
                                    t.priority.name,
                                    variant: switch (t.priority) {
                                      _Priority.high => EkBadgeVariant.danger,
                                      _Priority.medium => EkBadgeVariant.warning,
                                      _Priority.low => EkBadgeVariant.info,
                                    },
                                  ),
                                ],
                              ),
                            ),
                          )),
                      const SizedBox(height: 12),
                      Text(
                        'Team Activity',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: EkColors.gray800,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 12),
                      EkCard(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.group_rounded, color: EkColors.purple600),
                                    const SizedBox(width: 8),
                                    Text('Active Team Members', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: EkColors.gray800, fontWeight: FontWeight.w700)),
                                  ],
                                ),
                                Text('12/15', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: EkColors.purple600, fontWeight: FontWeight.w800)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(999),
                              child: const LinearProgressIndicator(
                                value: 0.8,
                                minHeight: 8,
                                backgroundColor: EkColors.gray100,
                                valueColor: AlwaysStoppedAnimation(EkColors.purple600),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'This Week',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: EkColors.gray800,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: EkCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.check_circle_rounded, size: 16, color: Color(0xFF22C55E)),
                                      const SizedBox(width: 6),
                                      Text('Completed', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: EkColors.gray500)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text('28', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: EkColors.gray800, fontWeight: FontWeight.w800)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: EkCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.trending_up_rounded, size: 16, color: Color(0xFF3B82F6)),
                                      const SizedBox(width: 6),
                                      Text('Productivity', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: EkColors.gray500)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text('94%', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: EkColors.gray800, fontWeight: FontWeight.w800)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const Align(
            alignment: Alignment.bottomCenter,
            child: BottomNav(active: BottomNavItem.home),
          ),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.20),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, size: 20, color: Colors.white),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({required this.action});

  final _QuickAction action;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 74,
      child: GestureDetector(
        onTap: () => Navigator.of(context).pushNamed(action.route),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: action.colors,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(color: Color(0x22000000), blurRadius: 16, offset: Offset(0, 8)),
                ],
              ),
              child: Icon(action.icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              action.label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: EkColors.gray600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAction {
  const _QuickAction({
    required this.label,
    required this.route,
    required this.icon,
    required this.colors,
  });

  final String label;
  final String route;
  final IconData icon;
  final List<Color> colors;
}

class _Task {
  const _Task({required this.id, required this.title, required this.time, required this.priority});

  final int id;
  final String title;
  final String time;
  final _Priority priority;
}

enum _Priority { high, medium, low }

