import 'package:flutter/material.dart';

import '../../routes/ek_routes.dart';
import '../../theme/ek_colors.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/ek_card.dart';
import '../../widgets/gradient_header.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late List<_NotificationItem> items = [
    _NotificationItem(id: 1, type: _Type.task, title: 'Task Assigned', message: "You have been assigned to 'Review Q2 Report'", time: '5 min ago', read: false),
    _NotificationItem(id: 2, type: _Type.attendance, title: 'Attendance Reminder', message: "Don't forget to check out today", time: '1 hour ago', read: false),
    _NotificationItem(id: 3, type: _Type.chat, title: 'New Message', message: 'John Smith sent you a message', time: '2 hours ago', read: false),
    _NotificationItem(id: 4, type: _Type.team, title: 'Team Update', message: 'Marketing Team posted an update', time: '3 hours ago', read: true),
    _NotificationItem(id: 5, type: _Type.reminder, title: 'Reminder', message: 'Team Standup Meeting at 11:30 AM', time: 'Yesterday', read: true),
    _NotificationItem(id: 6, type: _Type.task, title: 'Task Completed', message: "Emily Davis completed 'Client Presentation Prep'", time: 'Yesterday', read: true),
  ];

  @override
  Widget build(BuildContext context) {
    final unread = items.where((i) => !i.read).length;

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
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
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
                              Text('Unread', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white.withValues(alpha: 0.8))),
                              const SizedBox(height: 6),
                              Text('$unread', style: Theme.of(context).textTheme.displaySmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
                            ],
                          ),
                          GestureDetector(
                            onTap: () => setState(() {
                              items = [for (final i in items) i.copyWith(read: true)];
                            }),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.30)),
                              ),
                              child: Text(
                                'Mark All Read',
                                style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
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
                      ...items.map((n) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: EkCard(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: n.read ? null : Border.all(color: const Color(0xFFC4B5FD), width: 2),
                                boxShadow: const [
                                  BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, 4)),
                                ],
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
                                              child: Text(n.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: EkColors.gray800, fontWeight: FontWeight.w700)),
                                            ),
                                            if (!n.read)
                                              Container(
                                                width: 8,
                                                height: 8,
                                                decoration: const BoxDecoration(color: EkColors.purple600, shape: BoxShape.circle),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Text(n.message, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: EkColors.gray600)),
                                        const SizedBox(height: 8),
                                        Text(n.time, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: EkColors.gray400)),
                                      ],
                                    ),
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
            child: BottomNav(active: BottomNavItem.home),
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

class _NotifIcon extends StatelessWidget {
  const _NotifIcon({required this.type});

  final _Type type;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, icon) = type.style;
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
      child: Icon(icon, color: fg, size: 22),
    );
  }
}

class _NotificationItem {
  const _NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.time,
    required this.read,
  });

  final int id;
  final _Type type;
  final String title;
  final String message;
  final String time;
  final bool read;

  _NotificationItem copyWith({bool? read}) {
    return _NotificationItem(
      id: id,
      type: type,
      title: title,
      message: message,
      time: time,
      read: read ?? this.read,
    );
  }
}

enum _Type { task, attendance, chat, team, reminder }

extension on _Type {
  (Color, Color, IconData) get style => switch (this) {
        _Type.task => (const Color(0xFFDBEAFE), const Color(0xFF2563EB), Icons.check_circle_rounded),
        _Type.attendance => (const Color(0xFFDCFCE7), const Color(0xFF16A34A), Icons.access_time_rounded),
        _Type.chat => (const Color(0xFFF3E8FF), EkColors.purple600, Icons.chat_bubble_rounded),
        _Type.team => (const Color(0xFFFFEDD5), const Color(0xFFEA580C), Icons.group_rounded),
        _Type.reminder => (const Color(0xFFFCE7F3), EkColors.pink500, Icons.notifications_rounded),
      };
}

