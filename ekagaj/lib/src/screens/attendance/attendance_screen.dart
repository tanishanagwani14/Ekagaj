import 'package:flutter/material.dart';

import '../../routes/ek_routes.dart';
import '../../theme/ek_colors.dart';
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
  bool checkedIn = true;

  @override
  Widget build(BuildContext context) {
    final history = const [
      _AttendanceRecord(date: 'May 7, 2026', checkIn: '9:00 AM', checkOut: '6:15 PM', status: _AttendanceStatus.present, hours: '9h 15m'),
      _AttendanceRecord(date: 'May 6, 2026', checkIn: '8:55 AM', checkOut: '6:00 PM', status: _AttendanceStatus.present, hours: '9h 5m'),
      _AttendanceRecord(date: 'May 5, 2026', checkIn: '9:10 AM', checkOut: '6:20 PM', status: _AttendanceStatus.late, hours: '9h 10m'),
      _AttendanceRecord(date: 'May 4, 2026', checkIn: '-', checkOut: '-', status: _AttendanceStatus.absent, hours: '-'),
      _AttendanceRecord(date: 'May 3, 2026', checkIn: '9:00 AM', checkOut: '2:00 PM', status: _AttendanceStatus.halfDay, hours: '5h'),
    ];

    const stats = _MonthlyStats(present: 18, late: 2, absent: 1, halfDay: 1);

    return Scaffold(
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.zero,
            children: [
              GradientHeader(
                colors: const [EkColors.blue500, EkColors.purple600],
                bottomRadius: 0,
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
                            child: const Icon(Icons.access_time_rounded, color: Colors.white, size: 36),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            checkedIn ? 'Checked In at' : 'Check In Now',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            checkedIn ? '9:00 AM' : '--:--',
                            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          const SizedBox(height: 16),
                          GradientButton(
                            variant: GradientButtonVariant.secondary,
                            fullWidth: true,
                            onPressed: () => setState(() => checkedIn = !checkedIn),
                            child: Text(checkedIn ? 'Check Out' : 'Check In'),
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
                      Text(
                        'Monthly Overview',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: EkColors.gray800,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _StatCard(icon: Icons.check_circle_rounded, iconColor: const Color(0xFF22C55E), label: 'Present', value: '${stats.present}')),
                          const SizedBox(width: 12),
                          Expanded(child: _StatCard(icon: Icons.access_time_rounded, iconColor: const Color(0xFFF97316), label: 'Late', value: '${stats.late}')),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _StatCard(icon: Icons.cancel_rounded, iconColor: const Color(0xFFEF4444), label: 'Absent', value: '${stats.absent}')),
                          const SizedBox(width: 12),
                          Expanded(child: _StatCard(icon: Icons.calendar_month_rounded, iconColor: const Color(0xFF3B82F6), label: 'Half Day', value: '${stats.halfDay}')),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Recent History',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: EkColors.gray800,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 12),
                      ...history.map((r) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: EkCard(
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(r.date, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: EkColors.gray800, fontWeight: FontWeight.w700)),
                                      EkBadge(r.status.label, variant: r.status.badgeVariant),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('In: ${r.checkIn}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: EkColors.gray500)),
                                      Text('Out: ${r.checkOut}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: EkColors.gray500)),
                                      Text(r.hours, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: EkColors.gray500)),
                                    ],
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
          const Align(
            alignment: Alignment.bottomCenter,
            child: BottomNav(active: BottomNavItem.attendance),
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
    return EkCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 6),
              Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: EkColors.gray500)),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: EkColors.gray800, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _AttendanceRecord {
  const _AttendanceRecord({
    required this.date,
    required this.checkIn,
    required this.checkOut,
    required this.status,
    required this.hours,
  });

  final String date;
  final String checkIn;
  final String checkOut;
  final _AttendanceStatus status;
  final String hours;
}

class _MonthlyStats {
  const _MonthlyStats({required this.present, required this.late, required this.absent, required this.halfDay});

  final int present;
  final int late;
  final int absent;
  final int halfDay;
}

enum _AttendanceStatus { present, late, absent, halfDay }

extension on _AttendanceStatus {
  String get label => switch (this) {
        _AttendanceStatus.present => 'present',
        _AttendanceStatus.late => 'late',
        _AttendanceStatus.absent => 'absent',
        _AttendanceStatus.halfDay => 'half-day',
      };

  EkBadgeVariant get badgeVariant => switch (this) {
        _AttendanceStatus.present => EkBadgeVariant.success,
        _AttendanceStatus.late => EkBadgeVariant.warning,
        _AttendanceStatus.halfDay => EkBadgeVariant.info,
        _AttendanceStatus.absent => EkBadgeVariant.danger,
      };
}

