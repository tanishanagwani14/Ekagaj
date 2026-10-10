import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../routes/ek_routes.dart';
import '../../models/attendance_record.dart';
import '../../models/task_record.dart';
import '../../services/attendance_repository.dart';
import '../../models/user_profile.dart';
import '../../services/app_session.dart';
import '../../services/notification_repository.dart';
import '../../services/task_repository.dart';
import '../../services/user_repository.dart';
import '../../theme/ek_colors.dart';
import '../../theme/ek_theme_context.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/ek_badge.dart';
import '../../widgets/ek_card.dart';
import '../../widgets/gradient_header.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    if (AppSession.profile.value == null && AppSession.firebaseUser != null) {
      AppSession.restoreSession();
    }
  }

  String _greetingLabel(UserProfile? profile) {
    if (profile != null) return profile.greetingUsername;
    final email = AppSession.firebaseUser?.email;
    if (email != null && email.contains('@')) {
      return '@${email.split('@').first}';
    }
    return 'User';
  }

  @override
  Widget build(BuildContext context) {
    final textPrimary = context.ekTextPrimary;
    final textSecondary = context.ekTextSecondary;

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
                        Expanded(
                          child: ValueListenableBuilder(
                            valueListenable: AppSession.profile,
                            builder: (context, profile, _) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    UserRepository.timeBasedGreeting(),
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: Colors.white.withValues(alpha: 0.8),
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _greetingLabel(profile),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        ValueListenableBuilder(
                          valueListenable: AppSession.profile,
                          builder: (context, profile, _) {
                            final userId = profile?.id ?? '';
                            return Row(
                              children: [
                                StreamBuilder<int>(
                                  stream: NotificationRepository.watchUnreadCount(userId),
                                  builder: (context, snap) {
                                    final unread = snap.data ?? 0;
                                    return _HeaderIconButton(
                                      icon: Icons.notifications_none_rounded,
                                      badgeCount: unread,
                                      onTap: () => Navigator.of(context).pushNamed(EkRoutes.notifications),
                                    );
                                  },
                                ),
                                const SizedBox(width: 12),
                                _HeaderIconButton(
                                  icon: Icons.settings_outlined,
                                  onTap: () => Navigator.of(context).pushNamed(EkRoutes.settings),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ValueListenableBuilder(
                      valueListenable: AppSession.profile,
                      builder: (context, profile, _) {
                        final userId = profile?.id ?? '';
                        return StreamBuilder<AttendanceDayRecord?>(
                          stream: AttendanceRepository.watchToday(userId),
                          builder: (context, snap) {
                            final today = snap.data;
                            final checkIn = today?.checkInAt;
                            final timeLabel = checkIn != null
                                ? today!.formatTime(checkIn)
                                : '—';
                            final statusLabel = checkIn == null
                                ? 'Not checked in'
                                : today!.isCheckedIn
                                    ? 'Checked In'
                                    : 'Checked Out';
                            final dateLabel = DateFormat('MMM d, yyyy').format(DateTime.now());

                            return EkCard(
                              variant: EkCardVariant.gradient,
                              onTap: () => Navigator.of(context).pushNamed(EkRoutes.attendance),
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
                                        'Check-in Time',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: Colors.white.withValues(alpha: 0.8),
                                            ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        timeLabel,
                                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w800,
                                            ),
                                      ),
                                      if (checkIn == null) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          'Tap to check in with GPS',
                                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                                color: Colors.white.withValues(alpha: 0.75),
                                              ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      EkBadge(
                                        statusLabel,
                                        background: const Color(0x33FFFFFF),
                                        foreground: Colors.white,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        dateLabel,
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: Colors.white.withValues(alpha: 0.8),
                                            ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        for (var i = 0; i < actions.length; i++) ...[
                          Expanded(child: _QuickActionButton(action: actions[i])),
                          if (i < actions.length - 1) const SizedBox(width: 8),
                        ],
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Today's Tasks",
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pushNamed(EkRoutes.tasks),
                          child: Text('View All', style: TextStyle(color: EkColors.purple600)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    StreamBuilder<List<TaskRecord>>(
                      stream: TaskRepository.watchPending(limit: 5),
                      builder: (context, snap) {
                        final todayTasks = snap.data ?? const [];
                        if (todayTasks.isEmpty) {
                          return EkCard(
                            child: Text(
                              'No pending tasks. Add one from the Tasks tab.',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: textSecondary),
                            ),
                          );
                        }
                        return Column(
                          children: todayTasks.map(
                            (t) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: EkCard(
                                onTap: () => Navigator.of(context).pushNamed(EkRoutes.tasks),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: context.ekIconTileBg,
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: const Icon(Icons.check_circle_rounded, color: EkColors.purple600),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            t.title,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                  color: textPrimary,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            t.dueDate,
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: textSecondary),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    EkBadge(
                                      t.priority.label,
                                      variant: switch (t.priority) {
                                        TaskPriority.high => EkBadgeVariant.danger,
                                        TaskPriority.medium => EkBadgeVariant.warning,
                                        TaskPriority.low => EkBadgeVariant.info,
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ).toList(),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Team Activity',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 12),
                    EkCard(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.group_rounded, color: EkColors.purple600),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Active Team Members',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: textPrimary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '12/15',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      color: EkColors.purple600,
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              value: 0.8,
                              minHeight: 8,
                              backgroundColor: context.ekProgressTrack,
                              valueColor: const AlwaysStoppedAnimation(EkColors.purple600),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'This Week',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: textPrimary,
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
                                    Text(
                                      'Completed',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: textSecondary),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '28',
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                        color: textPrimary,
                                        fontWeight: FontWeight.w800,
                                      ),
                                ),
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
                                    Text(
                                      'Productivity',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: textSecondary),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '94%',
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                        color: textPrimary,
                                        fontWeight: FontWeight.w800,
                                      ),
                                ),
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
  const _HeaderIconButton({
    required this.icon,
    required this.onTap,
    this.badgeCount = 0,
  });

  final IconData icon;
  final VoidCallback onTap;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, size: 20, color: Colors.white),
          ),
          if (badgeCount > 0)
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: EkColors.pink500,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: Text(
                  badgeCount > 9 ? '9+' : '$badgeCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({required this.action});

  final _QuickAction action;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(action.route),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: action.colors,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: context.isDark ? Colors.black54 : const Color(0x22000000),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(action.icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            action.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: context.ekTextSecondary),
            textAlign: TextAlign.center,
          ),
        ],
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

