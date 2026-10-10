import 'package:flutter/material.dart';

import '../routes/ek_routes.dart';
import '../theme/ek_colors.dart';
import '../theme/ek_theme_context.dart';

enum BottomNavItem { home, tasks, chat, attendance, profile }

class BottomNav extends StatelessWidget {
  const BottomNav({super.key, required this.active});

  final BottomNavItem active;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: context.ekNavBarSurface,
          border: Border(top: BorderSide(color: context.ekNavBarBorder)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _Item(
              icon: Icons.home_rounded,
              label: 'Home',
              isActive: active == BottomNavItem.home,
              onTap: () => _go(context, EkRoutes.home),
            ),
            _Item(
              icon: Icons.checklist_rounded,
              label: 'Tasks',
              isActive: active == BottomNavItem.tasks,
              onTap: () => _go(context, EkRoutes.tasks),
            ),
            _Item(
              icon: Icons.chat_bubble_outline_rounded,
              label: 'Chat',
              isActive: active == BottomNavItem.chat,
              onTap: () => _go(context, EkRoutes.chat),
            ),
            _Item(
              icon: Icons.calendar_month_rounded,
              label: 'Attendance',
              isActive: active == BottomNavItem.attendance,
              onTap: () => _go(context, EkRoutes.attendance),
            ),
            _Item(
              icon: Icons.person_rounded,
              label: 'Profile',
              isActive: active == BottomNavItem.profile,
              onTap: () => _go(context, EkRoutes.profile),
            ),
          ],
        ),
      ),
    );
  }

  void _go(BuildContext context, String route) {
    if (ModalRoute.of(context)?.settings.name == route) return;
    Navigator.of(context).pushReplacementNamed(route);
  }
}

class _Item extends StatelessWidget {
  const _Item({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final iconColor = isActive ? Colors.white : context.ekTextSecondary;
    final labelColor = isActive ? EkColors.purple600 : context.ekTextSecondary;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: isActive
                  ? const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [EkColors.blue500, EkColors.purple600],
                    )
                  : null,
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: labelColor,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
