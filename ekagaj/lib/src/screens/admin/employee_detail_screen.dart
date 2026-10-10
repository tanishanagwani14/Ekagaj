import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/attendance_record.dart';
import '../../models/employee_record.dart';
import '../../models/followup_record.dart';
import '../../models/reminder_record.dart';
import '../../models/task_record.dart';
import '../../services/app_session.dart';
import '../../services/attendance_repository.dart';
import '../../services/employee_repository.dart';
import '../../services/followup_repository.dart';
import '../../services/reminder_repository.dart';
import '../../services/task_repository.dart';
import '../../services/user_roles.dart';
import '../../theme/ek_colors.dart';
import '../../theme/ek_theme_context.dart';
import '../../widgets/ek_badge.dart';
import '../../widgets/ek_card.dart';
import '../../widgets/gradient_header.dart';

class EmployeeDetailScreen extends StatelessWidget {
  const EmployeeDetailScreen({super.key, required this.employee});

  final EmployeeRecord employee;

  List<AttendanceDayRecord> _currentMonthRecords(List<AttendanceDayRecord> history) {
    final prefix = DateFormat('yyyy-MM').format(DateTime.now());
    return history.where((r) => r.id.startsWith(prefix)).toList();
  }

  String _todayStatusLabel(AttendanceDayRecord? today) {
    if (today?.checkInAt == null) return 'Not checked in';
    if (today!.isCheckedIn) return 'Checked in';
    return 'Checked out';
  }

  @override
  Widget build(BuildContext context) {
    final profile = AppSession.profile.value;
    if (profile == null || !UserRoles.isAdminRole(profile.role)) {
      return Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_outline_rounded, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Admin access only',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final textPrimary = context.ekTextPrimary;
    final textSecondary = context.ekTextSecondary;

    return Scaffold(
      body: StreamBuilder<EmployeeRecord?>(
        stream: EmployeeRepository.watchEmployee(employee.id),
        initialData: employee,
        builder: (context, employeeSnap) {
          final e = employeeSnap.data ?? employee;

          return StreamBuilder<AttendanceDayRecord?>(
            stream: AttendanceRepository.watchToday(e.id),
            builder: (context, todaySnap) {
              final today = todaySnap.data;

              return StreamBuilder<List<AttendanceDayRecord>>(
                stream: AttendanceRepository.watchRecent(e.id),
                builder: (context, historySnap) {
                  final history = historySnap.data ?? const [];
                  final monthRecords = _currentMonthRecords(history);
                  final stats = MonthlyAttendanceStats.fromRecords(monthRecords);

                  return StreamBuilder<List<TaskRecord>>(
                    stream: TaskRepository.watchForEmployee(e),
                    builder: (context, tasksSnap) {
                      final tasks = tasksSnap.data ?? const [];
                      final pendingTasks = tasks.where((t) => t.isPending).toList();
                      final completedTasks = tasks.where((t) => !t.isPending).toList();

                      return StreamBuilder<List<ReminderRecord>>(
                        stream: ReminderRepository.watchForUser(e.id),
                        builder: (context, remindersSnap) {
                          final reminders = remindersSnap.data ?? const [];

                          return StreamBuilder<List<FollowUpRecord>>(
                            stream: FollowUpRepository.watchAll(),
                            builder: (context, followSnap) {
                              final followUps = (followSnap.data ?? const [])
                                  .where((f) => f.createdBy == e.id)
                                  .toList();

                              return ListView(
                                padding: EdgeInsets.zero,
                                children: [
                                  GradientHeader(
                                    colors: const [EkColors.indigo600, EkColors.purple600],
                                    bottomRadius: 40,
                                    padding: const EdgeInsets.fromLTRB(24, 56, 24, 32),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _BackButton(onTap: () => Navigator.of(context).pop()),
                                        const SizedBox(height: 16),
                                        Row(
                                          children: [
                                            _Avatar(letter: e.displayName.isNotEmpty ? e.displayName.characters.first : '?'),
                                            const SizedBox(width: 14),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    e.displayName,
                                                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                                          color: Colors.white,
                                                          fontWeight: FontWeight.w800,
                                                        ),
                                                  ),
                                                  if (e.username.isNotEmpty)
                                                    Text(
                                                      '@${e.username}',
                                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                            color: Colors.white.withValues(alpha: 0.85),
                                                          ),
                                                    ),
                                                  const SizedBox(height: 6),
                                                  EkBadge(
                                                    e.isOnLeave ? 'on leave' : 'active',
                                                    background: Colors.white.withValues(alpha: 0.22),
                                                    foreground: Colors.white,
                                                  ),
                                                ],
                                              ),
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
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Today · Live',
                                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                      color: Colors.white.withValues(alpha: 0.8),
                                                    ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                _todayStatusLabel(today),
                                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.w800,
                                                    ),
                                              ),
                                              const SizedBox(height: 12),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: _LiveTimeTile(
                                                      label: 'Check-in',
                                                      value: today?.formatTime(today.checkInAt) ?? '—',
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: _LiveTimeTile(
                                                      label: 'Check-out',
                                                      value: today?.formatTime(today.checkOutAt) ?? '—',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              if (today?.workedDuration != null) ...[
                                                const SizedBox(height: 10),
                                                Text(
                                                  'Hours today: ${today!.hoursLabel}',
                                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                        color: Colors.white.withValues(alpha: 0.85),
                                                      ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _SectionTitle('Profile'),
                                        const SizedBox(height: 12),
                                        EkCard(
                                          child: Column(
                                            children: [
                                              _InfoRow(label: 'Department', value: e.department),
                                              _InfoRow(label: 'Email', value: e.email.isEmpty ? '—' : e.email),
                                              _InfoRow(label: 'Role', value: e.role),
                                              _InfoRow(label: 'Tasks completed', value: '${completedTasks.length}'),
                                              _InfoRow(label: 'Reminders', value: '${reminders.length}', isLast: true),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 24),
                                        _SectionTitle('This Month'),
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            Expanded(child: _StatChip(label: 'Present', value: '${stats.present}', color: const Color(0xFF22C55E))),
                                            const SizedBox(width: 8),
                                            Expanded(child: _StatChip(label: 'Late', value: '${stats.late}', color: const Color(0xFFF97316))),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Expanded(child: _StatChip(label: 'Absent', value: '${stats.absent}', color: const Color(0xFFEF4444))),
                                            const SizedBox(width: 8),
                                            Expanded(child: _StatChip(label: 'Half day', value: '${stats.halfDay}', color: const Color(0xFF3B82F6))),
                                          ],
                                        ),
                                        const SizedBox(height: 24),
                                        _SectionTitle('Recent Check-in / Check-out'),
                                        const SizedBox(height: 12),
                                        if (history.isEmpty)
                                          EkCard(
                                            child: Text(
                                              'No attendance records yet.',
                                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: textSecondary),
                                            ),
                                          )
                                        else
                                          ...history.take(10).map(
                                                (r) => Padding(
                                                  padding: const EdgeInsets.only(bottom: 12),
                                                  child: EkCard(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Text(
                                                              r.displayDate,
                                                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                                    color: textPrimary,
                                                                    fontWeight: FontWeight.w700,
                                                                  ),
                                                            ),
                                                            EkBadge(r.status.label, variant: _badgeFor(r.status)),
                                                          ],
                                                        ),
                                                        const SizedBox(height: 10),
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Text('In: ${r.formatTime(r.checkInAt)}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: textSecondary)),
                                                            Text('Out: ${r.formatTime(r.checkOutAt)}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: textSecondary)),
                                                            Text(r.hoursLabel, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: textSecondary)),
                                                          ],
                                                        ),
                                                        if (r.checkInLat != null) ...[
                                                          const SizedBox(height: 8),
                                                          Text(
                                                            'GPS in: ${r.formatCoords(r.checkInLat, r.checkInLng)}',
                                                            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: textSecondary),
                                                          ),
                                                        ],
                                                        if (r.checkOutLat != null)
                                                          Text(
                                                            'GPS out: ${r.formatCoords(r.checkOutLat, r.checkOutLng)}',
                                                            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: textSecondary),
                                                          ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                        const SizedBox(height: 24),
                                        _SectionTitle('Tasks (${pendingTasks.length} pending)'),
                                        const SizedBox(height: 12),
                                        if (tasks.isEmpty)
                                          EkCard(
                                            child: Text(
                                              'No tasks assigned to this employee.',
                                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: textSecondary),
                                            ),
                                          )
                                        else
                                          ...tasks.take(8).map(
                                                (t) => Padding(
                                                  padding: const EdgeInsets.only(bottom: 12),
                                                  child: EkCard(
                                                    child: Row(
                                                      children: [
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Text(
                                                                t.title,
                                                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                                      color: textPrimary,
                                                                      fontWeight: FontWeight.w700,
                                                                    ),
                                                              ),
                                                              const SizedBox(height: 4),
                                                              Text(
                                                                'Due: ${t.dueDate}',
                                                                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: textSecondary),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        EkBadge(
                                                          t.isPending ? t.priority.label : 'done',
                                                          variant: t.isPending
                                                              ? switch (t.priority) {
                                                                  TaskPriority.high => EkBadgeVariant.danger,
                                                                  TaskPriority.medium => EkBadgeVariant.warning,
                                                                  TaskPriority.low => EkBadgeVariant.info,
                                                                }
                                                              : EkBadgeVariant.success,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                        if (followUps.isNotEmpty) ...[
                                          const SizedBox(height: 24),
                                          _SectionTitle('Follow-ups (${followUps.length})'),
                                          const SizedBox(height: 12),
                                          ...followUps.take(5).map(
                                                (f) => Padding(
                                                  padding: const EdgeInsets.only(bottom: 12),
                                                  child: EkCard(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          f.clientName,
                                                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                                color: textPrimary,
                                                                fontWeight: FontWeight.w700,
                                                              ),
                                                        ),
                                                        const SizedBox(height: 4),
                                                        Text(
                                                          'Next: ${f.nextFollowUp}',
                                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: textSecondary),
                                                        ),
                                                        const SizedBox(height: 6),
                                                        EkBadge(f.status.label, variant: EkBadgeVariant.primary),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

EkBadgeVariant _badgeFor(AttendanceStatus status) => switch (status) {
      AttendanceStatus.present => EkBadgeVariant.success,
      AttendanceStatus.late => EkBadgeVariant.warning,
      AttendanceStatus.halfDay => EkBadgeVariant.info,
      AttendanceStatus.absent => EkBadgeVariant.danger,
    };

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: context.ekTextPrimary,
            fontWeight: FontWeight.w700,
          ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});

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
        child: const Icon(Icons.arrow_back_rounded, size: 20, color: Colors.white),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.letter});

  final String letter;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: [Color(0xFF60A5FA), Color(0xFFA855F7)]),
      ),
      child: Center(
        child: Text(
          letter,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

class _LiveTimeTile extends StatelessWidget {
  const _LiveTimeTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white.withValues(alpha: 0.8))),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value, this.isLast = false});

  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.ekTextSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.ekTextPrimary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return EkCard(
      child: Row(
        children: [
          Container(
            width: 8,
            height: 32,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: context.ekTextSecondary)),
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: context.ekTextPrimary,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
