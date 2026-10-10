import 'package:flutter/material.dart';

import '../../models/employee_record.dart';
import '../../routes/ek_routes.dart';
import '../../services/employee_repository.dart';
import '../../services/user_roles.dart';
import '../../theme/ek_colors.dart';
import '../../theme/ek_theme_context.dart';
import '../../widgets/add_employee_dialog.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/ek_badge.dart';
import '../../widgets/ek_card.dart';
import '../../widgets/gradient_header.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  bool _creating = false;

  Future<void> _onAddEmployee() async {
    if (_creating) return;
    setState(() => _creating = true);
    try {
      await showAddEmployeeDialog(context);
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          StreamBuilder<List<EmployeeRecord>>(
            stream: EmployeeRepository.watchEmployees(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final textPrimary = context.ekTextPrimary;
              final textSecondary = context.ekTextSecondary;

              final employees = snapshot.data ?? const <EmployeeRecord>[];
              final staff = employees.where((e) => !UserRoles.isAdminRole(e.role)).toList();
              final stats = EmployeeRepository.statsFrom(employees);
              final depts = EmployeeRepository.departmentsFrom(employees);

              final orgStats = [
                _OrgStat(label: 'Total Employees', value: '${stats.total}', icon: Icons.group_rounded),
                _OrgStat(label: 'Active Today', value: '${stats.activeToday}', icon: Icons.trending_up_rounded),
                _OrgStat(label: 'On Leave', value: '${stats.onLeave}', icon: Icons.calendar_month_rounded),
              ];

              return ListView(
                padding: EdgeInsets.zero,
                children: [
                  GradientHeader(
                    colors: const [EkColors.indigo600, EkColors.purple600],
                    bottomRadius: 40,
                    padding: const EdgeInsets.fromLTRB(24, 56, 24, 40),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            _IconHeaderButton(
                              icon: Icons.arrow_back_rounded,
                              onTap: () => Navigator.of(context).pushReplacementNamed(EkRoutes.profile),
                            ),
                            Expanded(
                              child: Center(
                                child: Text(
                                  'Admin Panel',
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 40),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            for (final s in orgStats) ...[
                              Expanded(
                                child: EkCard(
                                  variant: EkCardVariant.gradient,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.18),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.white.withValues(alpha: 0.30)),
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(s.icon, color: Colors.white, size: 20),
                                      const SizedBox(height: 8),
                                      Text(
                                        s.value,
                                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w800,
                                            ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        s.label,
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                              color: Colors.white.withValues(alpha: 0.8),
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (s != orgStats.last) const SizedBox(width: 12),
                            ],
                          ],
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
                          'Department Analytics',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 12),
                        if (depts.isEmpty)
                          EkCard(
                            child: Text(
                              'No departments yet. Add employees to see analytics.',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: textSecondary),
                            ),
                          )
                        else
                          ...depts.map(
                            (d) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: EkCard(
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              d.department,
                                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                    color: textPrimary,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              '${d.employees} employees',
                                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: textSecondary),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              '${d.productivity}%',
                                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                                    color: EkColors.purple600,
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                            ),
                                            Text(
                                              'Active rate',
                                              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: textSecondary),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(999),
                                      child: LinearProgressIndicator(
                                        value: d.productivity / 100.0,
                                        minHeight: 8,
                                        backgroundColor: EkColors.gray100,
                                        valueColor: const AlwaysStoppedAnimation(EkColors.purple600),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Employee Management',
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      color: textPrimary,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Flexible(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerRight,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(colors: [EkColors.blue500, EkColors.purple600]),
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: const [
                                      BoxShadow(color: Color(0x4D7C3AED), blurRadius: 18, offset: Offset(0, 10)),
                                    ],
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(14),
                                      onTap: _creating ? null : _onAddEmployee,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.person_add_alt_1_rounded, color: Colors.white, size: 18),
                                            const SizedBox(width: 8),
                                            Text(
                                              _creating ? 'Adding...' : 'Add Employee',
                                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (staff.isEmpty)
                          EkCard(
                            child: Column(
                              children: [
                                Icon(Icons.people_outline_rounded, size: 48, color: EkColors.gray400),
                                const SizedBox(height: 12),
                                Text(
                                  'No employees yet',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: textPrimary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Tap Add Employee to save someone to the database.',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: textSecondary),
                                ),
                              ],
                            ),
                          )
                        else
                          ...staff.map(
                            (e) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: EkCard(
                                onTap: () => Navigator.of(context).pushNamed(
                                  EkRoutes.adminEmployeeDetail,
                                  arguments: e,
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Row(
                                            children: [
                                              _Avatar(
                                                letter: e.displayName.isNotEmpty
                                                    ? e.displayName.characters.first
                                                    : '?',
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      e.displayName,
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                            color: textPrimary,
                                                            fontWeight: FontWeight.w700,
                                                          ),
                                                    ),
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      e.department,
                                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                            color: textSecondary,
                                                          ),
                                                    ),
                                                    if (e.username.isNotEmpty)
                                                      Text(
                                                        '@${e.username}',
                                                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                                              color: EkColors.gray400,
                                                            ),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        EkBadge(
                                          e.isOnLeave ? 'leave' : 'active',
                                          variant: e.isOnLeave ? EkBadgeVariant.warning : EkBadgeVariant.success,
                                        ),
                                        const SizedBox(width: 4),
                                        Icon(Icons.chevron_right_rounded, color: textSecondary),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(child: _MiniMetric(label: 'Attendance', value: e.attendance)),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: _MiniMetric(label: 'Tasks Done', value: '${e.tasksCompleted}'),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'Tap to view live check-in, tasks & details',
                                      style: Theme.of(context).textTheme.labelSmall?.copyWith(color: EkColors.purple600),
                                    ),
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
          ),
          const Align(
            alignment: Alignment.bottomCenter,
            child: BottomNav(active: BottomNavItem.profile),
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

class _Avatar extends StatelessWidget {
  const _Avatar({required this.letter});

  final String letter;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: [Color(0xFF60A5FA), Color(0xFFA855F7)]),
      ),
      child: Center(
        child: Text(
          letter,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  const _MiniMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: context.ekMutedSurface, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: context.ekTextSecondary)),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: context.ekTextPrimary,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _OrgStat {
  const _OrgStat({required this.label, required this.value, required this.icon});

  final String label;
  final String value;
  final IconData icon;
}
