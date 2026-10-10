import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../config/backend_config.dart';
import '../../models/attendance_record.dart';
import '../../routes/ek_routes.dart';
import '../../services/app_session.dart';
import '../../services/attendance_repository.dart';
import '../../theme/ek_colors.dart';
import '../../theme/ek_theme_context.dart';
import '../../widgets/auth_gate.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/ek_badge.dart';
import '../../widgets/ek_card.dart';
import '../../widgets/gradient_button.dart';
import '../../widgets/gradient_header.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  bool _busy = false;
  AttendanceDayRecord? _localToday;
  final List<AttendanceDayRecord> _localHistory = [];

  String get _userId => AppSession.profile.value?.id ?? '';

  AttendanceDayRecord? _effectiveToday(AttendanceDayRecord? remote) {
    if (BackendConfig.useFirebase) return remote;
    return _localToday ?? remote;
  }

  List<AttendanceDayRecord> _effectiveHistory(List<AttendanceDayRecord> remote) {
    if (BackendConfig.useFirebase) return remote;
    if (_localHistory.isEmpty) return remote;
    final merged = <String, AttendanceDayRecord>{};
    for (final r in remote) {
      merged[r.id] = r;
    }
    for (final r in _localHistory) {
      merged[r.id] = r;
    }
    return merged.values.toList()..sort((a, b) => b.id.compareTo(a.id));
  }

  List<AttendanceDayRecord> _currentMonthRecords(List<AttendanceDayRecord> history) {
    final now = DateTime.now();
    final prefix = DateFormat('yyyy-MM').format(now);
    return history.where((r) => r.id.startsWith(prefix)).toList();
  }

  Future<void> _toggleCheck(AttendanceDayRecord? today) async {
    if (_busy) return;

    setState(() => _busy = true);
    try {
      if (today?.isCheckedIn == true) {
        final updated = await AttendanceRepository.checkOut(_userId, today!);
        if (!BackendConfig.useFirebase) {
          setState(() {
            _localToday = updated;
            _upsertLocalHistory(updated);
          });
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Checked out at ${updated.formatTime(updated.checkOutAt)}')),
          );
        }
      } else if (today?.checkOutAt != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You already checked out today.')),
          );
        }
      } else {
        final record = await AttendanceRepository.checkIn(_userId);
        if (!BackendConfig.useFirebase) {
          setState(() => _localToday = record);
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Checked in at ${record.formatTime(record.checkInAt)}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('StateError: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _upsertLocalHistory(AttendanceDayRecord record) {
    final index = _localHistory.indexWhere((r) => r.id == record.id);
    if (index >= 0) {
      _localHistory[index] = record;
    } else {
      _localHistory.insert(0, record);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textPrimary = context.ekTextPrimary;
    final textSecondary = context.ekTextSecondary;

    return ValueListenableBuilder(
      valueListenable: AppSession.profile,
      builder: (context, profile, _) {
        if (profile == null) {
          return const SessionSignInPrompt(
            title: 'Sign in for Attendance',
            message:
                'Check-in needs a signed-in account. Tap below to open the login page.',
          );
        }

        final userId = profile.id;

        return Scaffold(
          body: Stack(
            children: [
              StreamBuilder<AttendanceDayRecord?>(
                stream: AttendanceRepository.watchToday(userId),
                builder: (context, todaySnap) {
                  final today = _effectiveToday(todaySnap.data);
                  final checkedIn = today?.isCheckedIn == true;
                  final checkedOut = today?.checkOutAt != null;

                  return StreamBuilder<List<AttendanceDayRecord>>(
                    stream: AttendanceRepository.watchRecent(userId),
                    builder: (context, historySnap) {
                      final history = _effectiveHistory(historySnap.data ?? const []);
                      final monthRecords = _currentMonthRecords(history);
                      final stats = MonthlyAttendanceStats.fromRecords(monthRecords);

                      return ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          GradientHeader(
                            colors: const [EkColors.blue500, EkColors.purple600],
                            bottomRadius: 40,
                            padding: const EdgeInsets.fromLTRB(24, 56, 24, 32),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _BackButton(
                                  onTap: () => Navigator.of(context).pushReplacementNamed(EkRoutes.home),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Attendance',
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                                const SizedBox(height: 16),
                                EkCard(
                                  variant: EkCardVariant.gradient,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.18),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.white.withValues(alpha: 0.30)),
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.25),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          checkedIn ? Icons.location_on_rounded : Icons.access_time_rounded,
                                          color: Colors.white,
                                          size: 36,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        checkedOut
                                            ? 'Checked Out'
                                            : checkedIn
                                                ? 'Checked In at'
                                                : 'Check In Now',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: Colors.white.withValues(alpha: 0.8),
                                            ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        checkedIn || checkedOut
                                            ? today!.formatTime(checkedOut ? today.checkOutAt : today.checkInAt)
                                            : '--:--',
                                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w800,
                                            ),
                                      ),
                                      if (today != null && (today.checkInLat != null || today.checkOutLat != null)) ...[
                                        const SizedBox(height: 12),
                                        _LocationRow(
                                          label: 'Check-in',
                                          time: today.formatTime(today.checkInAt),
                                          coords: today.formatCoords(today.checkInLat, today.checkInLng),
                                        ),
                                        if (today.checkOutAt != null) ...[
                                          const SizedBox(height: 8),
                                          _LocationRow(
                                            label: 'Check-out',
                                            time: today.formatTime(today.checkOutAt),
                                            coords: today.formatCoords(today.checkOutLat, today.checkOutLng),
                                          ),
                                        ],
                                      ],
                                      const SizedBox(height: 16),
                                      GradientButton(
                                        variant: GradientButtonVariant.secondary,
                                        fullWidth: true,
                                        onPressed: (_busy || checkedOut) ? null : () => _toggleCheck(today),
                                        child: _busy
                                            ? const SizedBox(
                                                width: 22,
                                                height: 22,
                                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                              )
                                            : Text(checkedIn ? 'Check Out' : 'Check In'),
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
                                  'Monthly Overview',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        color: textPrimary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _StatCard(
                                        icon: Icons.check_circle_rounded,
                                        iconColor: const Color(0xFF22C55E),
                                        label: 'Present',
                                        value: '${stats.present}',
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _StatCard(
                                        icon: Icons.access_time_rounded,
                                        iconColor: const Color(0xFFF97316),
                                        label: 'Late',
                                        value: '${stats.late}',
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _StatCard(
                                        icon: Icons.cancel_rounded,
                                        iconColor: const Color(0xFFEF4444),
                                        label: 'Absent',
                                        value: '${stats.absent}',
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _StatCard(
                                        icon: Icons.calendar_month_rounded,
                                        iconColor: const Color(0xFF3B82F6),
                                        label: 'Half Day',
                                        value: '${stats.halfDay}',
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  'Recent History',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        color: textPrimary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                                const SizedBox(height: 12),
                                if (history.isEmpty)
                                  EkCard(
                                    child: Text(
                                      'No attendance records yet. Tap Check In to record your first entry with GPS.',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: textSecondary),
                                    ),
                                  )
                                else
                                  ...history.map(
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
                                                Text(
                                                  'In: ${r.formatTime(r.checkInAt)}',
                                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: textSecondary),
                                                ),
                                                Text(
                                                  'Out: ${r.formatTime(r.checkOutAt)}',
                                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: textSecondary),
                                                ),
                                                Text(
                                                  r.hoursLabel,
                                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: textSecondary),
                                                ),
                                              ],
                                            ),
                                            if (r.checkInLat != null || r.checkOutLat != null) ...[
                                              const SizedBox(height: 8),
                                              Text(
                                                'In GPS: ${r.formatCoords(r.checkInLat, r.checkInLng)}',
                                                style: Theme.of(context).textTheme.labelSmall?.copyWith(color: textSecondary),
                                              ),
                                              if (r.checkOutLat != null)
                                                Text(
                                                  'Out GPS: ${r.formatCoords(r.checkOutLat, r.checkOutLng)}',
                                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(color: textSecondary),
                                                ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 120),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              const Align(
                alignment: Alignment.bottomCenter,
                child: BottomNav(active: BottomNavItem.attendance),
              ),
            ],
          ),
        );
      },
    );
  }
}

EkBadgeVariant _badgeFor(AttendanceStatus status) => switch (status) {
      AttendanceStatus.present => EkBadgeVariant.success,
      AttendanceStatus.late => EkBadgeVariant.warning,
      AttendanceStatus.halfDay => EkBadgeVariant.info,
      AttendanceStatus.absent => EkBadgeVariant.danger,
    };

class _LocationRow extends StatelessWidget {
  const _LocationRow({
    required this.label,
    required this.time,
    required this.coords,
  });

  final String label;
  final String time;
  final String coords;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label · $time',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            coords,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.75),
                ),
          ),
        ],
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
        child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textPrimary = context.ekTextPrimary;
    final textSecondary = context.ekTextSecondary;

    return EkCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 6),
              Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: textSecondary)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: textPrimary,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}
