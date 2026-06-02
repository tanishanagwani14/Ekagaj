import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../routes/ek_routes.dart';
import '../../services/user_repository.dart';
import '../../services/user_roles.dart';
import '../../theme/ek_colors.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/ek_badge.dart';
import '../../widgets/ek_card.dart';
import '../../widgets/gradient_header.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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

    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, authSnap) {
          final firebaseUser = authSnap.data;
          if (authSnap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (firebaseUser == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed(EkRoutes.login);
              }
            });
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }

          return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: UserRepository.userDoc(firebaseUser.uid).snapshots(),
            builder: (context, userSnap) {
              if (userSnap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final data = userSnap.data?.data();
              final displayName = (data?['displayName'] as String?)?.trim();
              final username = (data?['username'] as String?)?.trim();
              final department = (data?['department'] as String?)?.trim();
              final isAdmin = UserRoles.isAdminRole(data?['role']);
              final title = (displayName != null && displayName.isNotEmpty) ? displayName : (username ?? 'Member');
              final subtitle = username != null && username.isNotEmpty ? '@$username' : firebaseUser.uid;

              final menu = <_MenuItem>[
                if (isAdmin)
                  const _MenuItem(
                    icon: Icons.person_rounded,
                    label: 'Admin Panel',
                    route: EkRoutes.admin,
                    badge: 'Admin',
                    iconColor: EkColors.purple600,
                  ),
                const _MenuItem(icon: Icons.settings_rounded, label: 'Settings', route: EkRoutes.settings, iconColor: EkColors.gray600),
                const _MenuItem(icon: Icons.notifications_rounded, label: 'Notifications', route: EkRoutes.notifications, iconColor: EkColors.gray600),
                const _MenuItem(icon: Icons.shield_rounded, label: 'Privacy & Security', route: EkRoutes.settings, iconColor: EkColors.gray600),
                const _MenuItem(icon: Icons.help_rounded, label: 'Help & Support', route: EkRoutes.settings, iconColor: EkColors.gray600),
              ];

              return Stack(
                children: [
                  ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      GradientHeader(
                        colors: const [EkColors.blue500, EkColors.purple600],
                        bottomRadius: 0,
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
                                  _initials(title),
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
                            if (department != null && department.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                department,
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
                      Transform.translate(
                        offset: const Offset(0, -32),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
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
                                      onTap: () => Navigator.of(context).pushNamed(m.route),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                width: 40,
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  color: EkColors.gray100,
                                                  borderRadius: BorderRadius.circular(14),
                                                ),
                                                child: Icon(m.icon, color: m.iconColor, size: 20),
                                              ),
                                              const SizedBox(width: 12),
                                              Text(
                                                m.label,
                                                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: EkColors.gray800, fontWeight: FontWeight.w700),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              if (m.badge != null) ...[
                                                EkBadge(m.badge!, variant: EkBadgeVariant.info),
                                                const SizedBox(width: 8),
                                              ],
                                              const Icon(Icons.chevron_right_rounded, color: EkColors.gray400),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  )),
                              EkCard(
                                onTap: () async {
                                  await FirebaseAuth.instance.signOut();
                                  if (context.mounted) {
                                    Navigator.of(context).pushReplacementNamed(EkRoutes.login);
                                  }
                                },
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: const Color(0xFFFFE4E6), width: 2),
                                  boxShadow: const [
                                    BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, 4)),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.logout_rounded, color: Color(0xFFDC2626), size: 20),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Log Out',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(color: const Color(0xFFDC2626), fontWeight: FontWeight.w800),
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
              );
            },
          );
        },
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
          Text(stat.value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: EkColors.gray800, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(stat.label, textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: EkColors.gray500)),
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
    required this.route,
    required this.iconColor,
    this.badge,
  });

  final IconData icon;
  final String label;
  final String route;
  final Color iconColor;
  final String? badge;
}
