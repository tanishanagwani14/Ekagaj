import 'package:flutter/material.dart';

import '../../routes/ek_routes.dart';
import '../../services/app_session.dart';
import '../../services/user_roles.dart';
import '../../theme/ek_colors.dart';
import '../../theme/ek_theme_context.dart';
import '../../widgets/add_employee_dialog.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/ek_badge.dart';
import '../../widgets/ek_card.dart';
import '../../widgets/gradient_header.dart';
import '../settings/settings_detail_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _addingEmployee = false;

  static String _initials(String? name) {
    if (name == null || name.trim().isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    String ch(String s, int i) => s.isNotEmpty && i < s.length ? s[i].toUpperCase() : '';
    if (parts.length == 1) {
      final s = parts[0];
      return s.length >= 2 ? '${ch(s, 0)}${ch(s, 1)}' : ch(s, 0);
    }
    return '${ch(parts[0], 0)}${ch(parts[1], 0)}';
  }

  @override
  Widget build(BuildContext context) {
    final stats = const [
      _Stat(label: 'Tasks Completed', value: '142', icon: Icons.bar_chart_rounded),
      _Stat(label: 'Attendance', value: '95%', icon: Icons.bar_chart_rounded),
      _Stat(label: 'Active Days', value: '28', icon: Icons.bar_chart_rounded),
    ];

    return ValueListenableBuilder(
      valueListenable: AppSession.profile,
      builder: (context, profile, _) {
        final title = profile?.displayName ?? 'User';
        final subtitle = '@${profile?.username ?? 'user'}';
        final department = (profile == null || profile.department.trim().isEmpty)
            ? null
            : profile.department.trim();
        final isAdmin = UserRoles.isAdminRole(profile?.role);

        return Scaffold(
          body: _ProfileBody(
            stats: stats,
            title: title,
            subtitle: subtitle,
            department: department,
            isAdmin: isAdmin,
            initials: _initials(title),
            addingEmployee: _addingEmployee,
            onAddEmployee: isAdmin
                ? () async {
                    setState(() => _addingEmployee = true);
                    try {
                      await showAddEmployeeDialog(context);
                    } finally {
                      if (mounted) setState(() => _addingEmployee = false);
                    }
                  }
                : null,
          ),
        );
      },
    );
  }
}

Future<void> _confirmSignOut(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Sign out?'),
      content: const Text('You will return to the login screen.'),
      actions: [
        TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Cancel')),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          style: FilledButton.styleFrom(backgroundColor: const Color(0xFFDC2626)),
          child: const Text('Sign Out'),
        ),
      ],
    ),
  );
  if (confirmed == true && context.mounted) {
    await AppSession.signOut();
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody({
    required this.stats,
    required this.title,
    required this.subtitle,
    required this.department,
    required this.isAdmin,
    required this.initials,
    required this.addingEmployee,
    this.onAddEmployee,
  });

  final List<_Stat> stats;
  final String title;
  final String subtitle;
  final String? department;
  final bool isAdmin;
  final String initials;
  final bool addingEmployee;
  final VoidCallback? onAddEmployee;

  @override
  Widget build(BuildContext context) {
    final textPrimary = context.ekTextPrimary;
    final textSecondary = context.ekTextSecondary;

    final menu = <_MenuItem>[
      if (isAdmin) ...[
        _MenuItem(
          icon: Icons.person_add_alt_1_rounded,
          label: addingEmployee ? 'Adding Employee...' : 'Add Employee',
          iconColor: EkColors.blue500,
          onTap: addingEmployee ? null : onAddEmployee,
        ),
        const _MenuItem(
          icon: Icons.person_rounded,
          label: 'Admin Panel',
          route: EkRoutes.admin,
          badge: 'Admin',
          iconColor: EkColors.purple600,
        ),
      ],
      const _MenuItem(icon: Icons.settings_rounded, label: 'Settings', route: EkRoutes.settings, iconColor: EkColors.gray600),
      const _MenuItem(icon: Icons.notifications_rounded, label: 'Notifications', route: EkRoutes.notifications, iconColor: EkColors.gray600),
      _MenuItem(
        icon: Icons.shield_rounded,
        label: 'Privacy & Security',
        iconColor: EkColors.gray600,
        onTap: () => SettingsDetailScreen.openPrivacy(context),
      ),
      _MenuItem(
        icon: Icons.help_rounded,
        label: 'Help & Support',
        iconColor: EkColors.gray600,
        onTap: () => SettingsDetailScreen.openHelp(context),
      ),
      _MenuItem(
        icon: Icons.info_rounded,
        label: 'About',
        iconColor: EkColors.gray600,
        onTap: () => SettingsDetailScreen.openAbout(context),
      ),
      _MenuItem(
        icon: Icons.logout_rounded,
        label: 'Sign Out',
        iconColor: const Color(0xFFDC2626),
        onTap: () => _confirmSignOut(context),
      ),
    ];

    return Stack(
      children: [
        ListView(
          padding: EdgeInsets.zero,
          children: [
            GradientHeader(
              colors: const [EkColors.blue500, EkColors.purple600],
              bottomRadius: 40,
              padding: const EdgeInsets.fromLTRB(24, 56, 24, 48),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _IconHeaderButton(
                      icon: Icons.arrow_back_rounded,
                      onTap: () => Navigator.of(context).pushReplacementNamed(EkRoutes.home),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 4),
                    ),
                    child: Center(
                      child: Text(
                        initials,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white.withValues(alpha: 0.8)),
                  ),
                  if (department != null && department!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      department!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white.withValues(alpha: 0.75)),
                    ),
                  ],
                  const SizedBox(height: 10),
                  EkBadge(
                    isAdmin ? 'Admin' : 'Employee',
                    background: const Color(0x33FFFFFF),
                    foreground: Colors.white,
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
                      for (final s in stats) ...[
                        Expanded(child: _StatCard(stat: s)),
                        if (s != stats.last) const SizedBox(width: 12),
                      ],
                    ],
                  ),
                    const SizedBox(height: 20),
                    ...menu.map((m) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: EkCard(
                            onTap: m.onTap ??
                                (m.route != null
                                    ? () => Navigator.of(context).pushNamed(m.route!)
                                    : null),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: context.ekMutedSurface,
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Icon(m.icon, color: m.iconColor, size: 20),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      m.label,
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            color: textPrimary,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    if (m.badge != null) ...[
                                      EkBadge(m.badge!, variant: EkBadgeVariant.info),
                                      const SizedBox(width: 8),
                                    ],
                                    Icon(Icons.chevron_right_rounded, color: textSecondary),
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
          ],
        ),
        const Align(
          alignment: Alignment.bottomCenter,
          child: BottomNav(active: BottomNavItem.profile),
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

class _StatCard extends StatelessWidget {
  const _StatCard({required this.stat});

  final _Stat stat;

  @override
  Widget build(BuildContext context) {
    return EkCard(
      child: Column(
        children: [
          Icon(stat.icon, color: EkColors.purple600, size: 20),
          const SizedBox(height: 8),
          Text(
            stat.value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: context.ekTextPrimary,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            stat.label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: context.ekTextSecondary),
          ),
        ],
      ),
    );
  }
}

class _Stat {
  const _Stat({required this.label, required this.value, required this.icon});

  final String label;
  final String value;
  final IconData icon;
}

class _MenuItem {
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.iconColor,
    this.route,
    this.badge,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String? route;
  final Color iconColor;
  final String? badge;
  final VoidCallback? onTap;
}
