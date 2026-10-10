import 'package:flutter/material.dart';

import '../../routes/ek_routes.dart';
import '../../services/app_session.dart';
import '../../theme/app_preferences.dart';
import '../../theme/ek_colors.dart';
import '../../theme/ek_theme_context.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/ek_card.dart';
import '../../widgets/gradient_header.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final textSecondary = context.ekTextSecondary;

    final sections = <_Section>[
      _Section(
        title: 'General',
        items: [
          _SettingItem(
            icon: Icons.notifications_rounded,
            label: 'Notifications',
            value: notificationsEnabled,
            onChanged: (v) => setState(() => notificationsEnabled = v),
          ),
          _SettingItem(
            icon: Icons.dark_mode_rounded,
            label: 'Dark Mode',
            value: isDark,
            onChanged: (v) {
              AppPreferences.themeMode.value = v ? ThemeMode.dark : ThemeMode.light;
              setState(() {});
            },
          ),
        ],
      ),
    ];

    return Scaffold(
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.zero,
            children: [
              GradientHeader(
                colors: const [EkColors.blue500, EkColors.purple600],
                bottomRadius: 40,
                child: Row(
                  children: [
                    _IconHeaderButton(
                      icon: Icons.arrow_back_rounded,
                      onTap: () => Navigator.of(context).pushReplacementNamed(EkRoutes.profile),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'Settings',
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
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final section in sections) ...[
                      Padding(
                        padding: const EdgeInsets.only(left: 8, bottom: 10, top: 8),
                        child: Text(
                          section.title,
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: textSecondary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                      EkCard(
                        child: Column(
                          children: [
                            for (final item in section.items) ...[
                              _SettingRow(item: item),
                              if (item != section.items.last)
                                Divider(color: context.ekNavBarBorder, height: 1),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                    Text(
                      'Account',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: textSecondary,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 10),
                    EkCard(
                      onTap: () => _confirmSignOut(context),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.logout_rounded, size: 20, color: Color(0xFFDC2626)),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Sign Out',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: const Color(0xFFDC2626),
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ),
                    ),
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
      ),
    );
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

class _SettingRow extends StatelessWidget {
  const _SettingRow({required this.item});

  final _SettingItem item;

  @override
  Widget build(BuildContext context) {
    final textPrimary = context.ekTextPrimary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
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
                child: Icon(item.icon, size: 20, color: EkColors.purple600),
              ),
              const SizedBox(width: 12),
              Text(
                item.label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          _GradientSwitch(value: item.value, onChanged: item.onChanged),
        ],
      ),
    );
  }
}

class _GradientSwitch extends StatelessWidget {
  const _GradientSwitch({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final trackOff = context.ekProgressTrack;

    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 48,
        height: 28,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          gradient: value ? const LinearGradient(colors: [EkColors.blue500, EkColors.purple600]) : null,
          color: value ? null : trackOff,
        ),
        child: Align(
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          ),
        ),
      ),
    );
  }
}

class _Section {
  const _Section({required this.title, required this.items});

  final String title;
  final List<_SettingItem> items;
}

class _SettingItem {
  const _SettingItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
}
