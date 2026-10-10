import 'package:flutter/material.dart';

import '../../models/notification_record.dart';
import '../../routes/ek_routes.dart';
import '../../services/app_session.dart';
import '../../services/notification_repository.dart';
import '../../theme/ek_colors.dart';
import '../../theme/ek_theme_context.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/ek_card.dart';
import '../../widgets/gradient_header.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  Future<void> _onNotificationTap(BuildContext context, NotificationRecord item) async {
    if (!item.read) {
      await NotificationRepository.markRead(item.id);
    }
    if (!context.mounted) return;
    Navigator.of(context).pushNamed(item.routePath);
  }

  Future<void> _markAllRead(String userId) async {
    await NotificationRepository.markAllRead(userId);
  }

  @override
  Widget build(BuildContext context) {
    final textPrimary = context.ekTextPrimary;
    final textSecondary = context.ekTextSecondary;
    final userId = AppSession.profile.value?.id ?? '';

    return Scaffold(
      body: StreamBuilder<List<NotificationRecord>>(
        stream: NotificationRepository.watchForUser(userId),
        builder: (context, snap) {
          final items = snap.data ?? const [];
          final unread = items.where((i) => !i.read).length;
          final loading = snap.connectionState == ConnectionState.waiting && items.isEmpty;

          return Stack(
            children: [
              ListView(
                padding: EdgeInsets.zero,
                children: [
                  GradientHeader(
                    colors: const [EkColors.blue500, EkColors.purple600],
                    bottomRadius: 0,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            _IconHeaderButton(
                              icon: Icons.arrow_back_rounded,
                              onTap: () => Navigator.of(context).pushReplacementNamed(EkRoutes.home),
                            ),
                            Expanded(
                              child: Center(
                                child: Text(
                                  'Notifications',
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
                        EkCard(
                          variant: EkCardVariant.gradient,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.30)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Unread',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: Colors.white.withValues(alpha: 0.8),
                                        ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '$unread',
                                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                        ),
                                  ),
                                ],
                              ),
                              if (unread > 0)
                                GestureDetector(
                                  onTap: () => _markAllRead(userId),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.25),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(color: Colors.white.withValues(alpha: 0.30)),
                                    ),
                                    child: Text(
                                      'Mark All Read',
                                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ),
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
                        children: [
                          const SizedBox(height: 8),
                          if (loading)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 48),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          else if (items.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 32),
                              child: EkCard(
                                child: Text(
                                  'No notifications yet. You will see task, chat, attendance, and reminder alerts here in real time.',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: textSecondary),
                                ),
                              ),
                            )
                          else
                            ...items.map(
                              (n) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: EkCard(
                                  onTap: () => _onNotificationTap(context, n),
                                  decoration: n.read
                                      ? null
                                      : BoxDecoration(
                                          color: context.ekCardSurface,
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(
                                            color: EkColors.purple600.withValues(alpha: context.isDark ? 0.85 : 1),
                                            width: 2,
                                          ),
                                        ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _NotifIcon(type: n.type),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    n.title,
                                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                          color: textPrimary,
                                                          fontWeight: FontWeight.w700,
                                                        ),
                                                  ),
                                                ),
                                                if (!n.read)
                                                  Container(
                                                    width: 8,
                                                    height: 8,
                                                    decoration: const BoxDecoration(
                                                      color: EkColors.purple600,
                                                      shape: BoxShape.circle,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              n.message,
                                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: textSecondary),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              n.timeAgo,
                                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                                    color: textSecondary.withValues(alpha: 0.85),
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(Icons.chevron_right_rounded, color: textSecondary, size: 22),
                                    ],
                                  ),
                                ),
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
                child: BottomNav(active: BottomNavItem.home),
              ),
            ],
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

class _NotifIcon extends StatelessWidget {
  const _NotifIcon({required this.type});

  final NotificationType type;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, icon) = _styleFor(type, context);
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
      child: Icon(icon, color: fg, size: 22),
    );
  }
}

(Color, Color, IconData) _styleFor(NotificationType type, BuildContext context) {
  if (context.isDark) {
    return switch (type) {
      NotificationType.task => (const Color(0xFF1E3A5F), const Color(0xFF60A5FA), Icons.check_circle_rounded),
      NotificationType.attendance => (const Color(0xFF14532D), const Color(0xFF4ADE80), Icons.access_time_rounded),
      NotificationType.chat => (const Color(0xFF312E81), const Color(0xFFA78BFA), Icons.chat_bubble_rounded),
      NotificationType.team => (const Color(0xFF431407), const Color(0xFFFB923C), Icons.group_rounded),
      NotificationType.reminder => (const Color(0xFF500724), EkColors.pink500, Icons.notifications_rounded),
    };
  }
  return switch (type) {
    NotificationType.task => (const Color(0xFFDBEAFE), const Color(0xFF2563EB), Icons.check_circle_rounded),
    NotificationType.attendance => (const Color(0xFFDCFCE7), const Color(0xFF16A34A), Icons.access_time_rounded),
    NotificationType.chat => (const Color(0xFFF3E8FF), EkColors.purple600, Icons.chat_bubble_rounded),
    NotificationType.team => (const Color(0xFFFFEDD5), const Color(0xFFEA580C), Icons.group_rounded),
    NotificationType.reminder => (const Color(0xFFFCE7F3), EkColors.pink500, Icons.notifications_rounded),
  };
}
