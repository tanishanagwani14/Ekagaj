import 'package:flutter/material.dart';

import '../../routes/ek_routes.dart';
import '../../services/admin_employee_service.dart';
import '../../services/user_repository.dart';
import '../../theme/ek_colors.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureAdmin());
  }

  Future<void> _ensureAdmin() async {
    final ok = await UserRepository.currentUserIsAdmin();
    if (!mounted) return;
    if (ok) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('You do not have administrator access.')),
    );
    Navigator.of(context).pushReplacementNamed(EkRoutes.profile);
  }

  Future<void> _showAddEmployeeDialog(BuildContext context) async {
    final username = TextEditingController();
    final password = TextEditingController();
    final name = TextEditingController();
    final dept = TextEditingController();

    try {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Add Employee'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: name,
                    decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: dept,
                    decoration: const InputDecoration(labelText: 'Department', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: username,
                    decoration: const InputDecoration(labelText: 'Username', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: password,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
              FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Create')),
            ],
          );
        },
      );

      if (confirmed != true) return;

      if (!mounted) return;
      // ignore: use_build_context_synchronously
      final messenger = ScaffoldMessenger.of(context);

      setState(() => _creating = true);
      await AdminEmployeeService.createEmployee(
        username: username.text,
        password: password.text,
        displayName: name.text,
        department: dept.text,
      );
      if (!mounted) return;
      messenger.showSnackBar(const SnackBar(content: Text('Employee created.')));
    } catch (e) {
      if (!mounted) return;
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to create employee: $e')));
    } finally {
      username.dispose();
      password.dispose();
      name.dispose();
      dept.dispose();
      if (mounted) setState(() => _creating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final orgStats = const [
      _OrgStat(label: 'Total Employees', value: '48', icon: Icons.group_rounded),
      _OrgStat(label: 'Active Today', value: '42', icon: Icons.trending_up_rounded),
      _OrgStat(label: 'On Leave', value: '6', icon: Icons.calendar_month_rounded),
    ];

    final employees = const [
      _Employee(id: 1, name: 'John Smith', department: 'Engineering', status: _EmpStatus.active, attendance: '95%', tasksCompleted: 28),
      _Employee(id: 2, name: 'Emily Davis', department: 'Marketing', status: _EmpStatus.active, attendance: '98%', tasksCompleted: 34),
      _Employee(id: 3, name: 'Michael Brown', department: 'Sales', status: _EmpStatus.leave, attendance: '92%', tasksCompleted: 22),
      _Employee(id: 4, name: 'Lisa Chen', department: 'Design', status: _EmpStatus.active, attendance: '97%', tasksCompleted: 31),
    ];

    final depts = const [
      _Dept(department: 'Engineering', employees: 15, productivity: 94),
      _Dept(department: 'Marketing', employees: 10, productivity: 91),
      _Dept(department: 'Sales', employees: 12, productivity: 88),
      _Dept(department: 'Design', employees: 8, productivity: 96),
      _Dept(department: 'HR', employees: 3, productivity: 92),
    ];

    return Scaffold(
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.zero,
            children: [
              GradientHeader(
                colors: const [EkColors.indigo600, EkColors.purple600],
                bottomRadius: 0,
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
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
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
                                  Text(s.value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
                                  const SizedBox(height: 2),
                                  Text(s.label, textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white.withValues(alpha: 0.8))),
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
              Transform.translate(
                offset: const Offset(0, -24),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text('Department Analytics', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: EkColors.gray800, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),
                      ...depts.map((d) => Padding(
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
                                          Text(d.department, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: EkColors.gray800, fontWeight: FontWeight.w700)),
                                          const SizedBox(height: 2),
                                          Text('${d.employees} employees', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: EkColors.gray500)),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text('${d.productivity}%', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: EkColors.purple600, fontWeight: FontWeight.w800)),
                                          Text('Productivity', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: EkColors.gray500)),
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
                          )),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Employee Management',
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: EkColors.gray800, fontWeight: FontWeight.w700),
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
                                    onTap: _creating ? null : () => _showAddEmployeeDialog(context),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.person_add_alt_1_rounded, color: Colors.white, size: 18),
                                          const SizedBox(width: 8),
                                          Text(
                                            _creating ? 'Adding...' : 'Add Employee',
                                            style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
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
                      ...employees.map((e) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: EkCard(
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          _Avatar(letter: e.name.characters.first),
                                          const SizedBox(width: 12),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(e.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: EkColors.gray800, fontWeight: FontWeight.w700)),
                                              const SizedBox(height: 2),
                                              Text(e.department, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: EkColors.gray500)),
                                            ],
                                          ),
                                        ],
                                      ),
                                      EkBadge(e.status.label, variant: e.status.badge),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(child: _MiniMetric(label: 'Attendance', value: e.attendance)),
                                      const SizedBox(width: 12),
                                      Expanded(child: _MiniMetric(label: 'Tasks Done', value: '${e.tasksCompleted}')),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _SoftAdminAction(
                                          icon: Icons.lock_reset_rounded,
                                          label: 'Reset Password',
                                          bg: const Color(0xFFF5F3FF),
                                          fg: EkColors.purple600,
                                          onTap: () => _showResetPasswordDialog(context, employeeName: e.name),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          )),
                      const SizedBox(height: 12),
                      EkCard(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('This Month Overview', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: EkColors.gray800, fontWeight: FontWeight.w700)),
                                const Icon(Icons.bar_chart_rounded, color: EkColors.purple600),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(child: _OverviewMetric(label: 'Total Tasks', value: '1,247', valueColor: EkColors.gray800)),
                                const SizedBox(width: 12),
                                Expanded(child: _OverviewMetric(label: 'Completed', value: '1,089', valueColor: const Color(0xFF16A34A))),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(child: _OverviewMetric(label: 'Avg Attendance', value: '94.5%', valueColor: EkColors.gray800)),
                                const SizedBox(width: 12),
                                Expanded(child: _OverviewMetric(label: 'Team Score', value: 'A+', valueColor: EkColors.purple600)),
                              ],
                            ),
                          ],
                        ),
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
      decoration: BoxDecoration(color: EkColors.gray50, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: EkColors.gray500)),
          const SizedBox(height: 4),
          Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: EkColors.gray800, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

Future<void> _showResetPasswordDialog(BuildContext context, {required String employeeName}) async {
  final controller = TextEditingController();
  try {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Reset Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Employee: $employeeName'),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  } finally {
    controller.dispose();
  }
}

class _SoftAdminAction extends StatelessWidget {
  const _SoftAdminAction({
    required this.icon,
    required this.label,
    required this.bg,
    required this.fg,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color bg;
  final Color fg;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: fg),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(color: fg, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OverviewMetric extends StatelessWidget {
  const _OverviewMetric({required this.label, required this.value, required this.valueColor});

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: EkColors.gray500)),
        const SizedBox(height: 6),
        Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: valueColor, fontWeight: FontWeight.w800)),
      ],
    );
  }
}

class _OrgStat {
  const _OrgStat({required this.label, required this.value, required this.icon});

  final String label;
  final String value;
  final IconData icon;
}

class _Employee {
  const _Employee({
    required this.id,
    required this.name,
    required this.department,
    required this.status,
    required this.attendance,
    required this.tasksCompleted,
  });

  final int id;
  final String name;
  final String department;
  final _EmpStatus status;
  final String attendance;
  final int tasksCompleted;
}

enum _EmpStatus { active, leave }

extension on _EmpStatus {
  String get label => switch (this) {
        _EmpStatus.active => 'active',
        _EmpStatus.leave => 'leave',
      };

  EkBadgeVariant get badge => switch (this) {
        _EmpStatus.active => EkBadgeVariant.success,
        _EmpStatus.leave => EkBadgeVariant.warning,
      };
}

class _Dept {
  const _Dept({required this.department, required this.employees, required this.productivity});

  final String department;
  final int employees;
  final int productivity;
}

