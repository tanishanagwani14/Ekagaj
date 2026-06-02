import 'package:flutter/material.dart';

import '../../routes/ek_routes.dart';
import '../../theme/ek_colors.dart';
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
  bool darkModeEnabled = false;

  @override
  Widget build(BuildContext context) {
    final sections = <_Section>[
      _Section(
        title: 'General',
        items: [
          _SettingItem.toggle(
            icon: Icons.notifications_rounded,
            label: 'Notifications',
            value: notificationsEnabled,
            onChanged: (v) => setState(() => notificationsEnabled = v),
          ),
          _SettingItem.toggle(
            icon: Icons.dark_mode_rounded,
            label: 'Dark Mode',
            value: darkModeEnabled,
            onChanged: (v) => setState(() => darkModeEnabled = v),
          ),
        ],
      ),
      const _Section(
        title: 'Privacy & Security',
        items: [
          _SettingItem.link(icon: Icons.lock_rounded, label: 'Privacy Settings'),
        ],
      ),
      const _Section(
        title: 'Support',
        items: [
          _SettingItem.link(icon: Icons.help_rounded, label: 'Help Center'),
          _SettingItem.link(icon: Icons.info_rounded, label: 'About', value: 'Version 1.0.0'),
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
                bottomRadius: 0,
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
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    const SizedBox(width: 40),
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
                      for (final section in sections) ...[
                        Padding(
                          padding: const EdgeInsets.only(left: 8, bottom: 10),
                          child: Text(section.title, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: EkColors.gray500, fontWeight: FontWeight.w700)),
                        ),
                        EkCard(
                          child: Column(
                            children: [
                              for (final item in section.items) ...[
                                _SettingRow(item: item),
                                if (item != section.items.last) Divider(color: EkColors.gray100, height: 1),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
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

class _SettingRow extends StatelessWidget {
  const _SettingRow({required this.item});

  final _SettingItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
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
                child: Icon(item.icon, size: 20, color: EkColors.gray600),
              ),
              const SizedBox(width: 12),
              Text(item.label, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: EkColors.gray800, fontWeight: FontWeight.w700)),
            ],
          ),
          if (item.type == _SettingType.toggle)
            _GradientSwitch(value: item.toggleValue ?? false, onChanged: item.onChanged!)
          else
            Row(
              children: [
                if (item.linkValue != null) ...[
                  Text(item.linkValue!, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: EkColors.gray500)),
                  const SizedBox(width: 8),
                ],
                const Icon(Icons.chevron_right_rounded, color: EkColors.gray400),
              ],
            ),
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
          color: value ? null : const Color(0xFFD1D5DB),
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

enum _SettingType { toggle, link }

class _SettingItem {
  const _SettingItem._({
    required this.icon,
    required this.label,
    required this.type,
    this.toggleValue,
    this.linkValue,
    this.onChanged,
  });

  const _SettingItem.toggle({
    required IconData icon,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) : this._(icon: icon, label: label, type: _SettingType.toggle, toggleValue: value, onChanged: onChanged);

  const _SettingItem.link({
    required IconData icon,
    required String label,
    String? value,
  }) : this._(icon: icon, label: label, type: _SettingType.link, linkValue: value);

  final IconData icon;
  final String label;
  final _SettingType type;
  final bool? toggleValue;
  final String? linkValue;
  final ValueChanged<bool>? onChanged;
}

