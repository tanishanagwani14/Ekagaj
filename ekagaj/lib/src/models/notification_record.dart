import 'package:cloud_firestore/cloud_firestore.dart';

import '../routes/ek_routes.dart';

enum NotificationType { task, attendance, chat, team, reminder }

class NotificationRecord {
  const NotificationRecord({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    required this.read,
    required this.createdAt,
    this.route,
  });

  final String id;
  final String userId;
  final NotificationType type;
  final String title;
  final String message;
  final bool read;
  final DateTime createdAt;
  final String? route;

  String get routePath => route ?? _defaultRoute;

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${createdAt.month}/${createdAt.day}/${createdAt.year}';
  }

  String get _defaultRoute => switch (type) {
        NotificationType.task => EkRoutes.tasks,
        NotificationType.attendance => EkRoutes.attendance,
        NotificationType.chat => EkRoutes.chat,
        NotificationType.reminder => EkRoutes.reminders,
        NotificationType.team => EkRoutes.followUps,
      };

  factory NotificationRecord.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return NotificationRecord(
      id: doc.id,
      userId: (data['userId'] as String?) ?? '',
      type: _typeFrom(data['type']),
      title: (data['title'] as String?)?.trim() ?? 'Notification',
      message: (data['message'] as String?)?.trim() ?? '',
      read: data['read'] == true,
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      route: (data['route'] as String?)?.trim(),
    );
  }

  static NotificationType _typeFrom(dynamic value) {
    return switch (value) {
      'attendance' => NotificationType.attendance,
      'chat' => NotificationType.chat,
      'team' => NotificationType.team,
      'reminder' => NotificationType.reminder,
      _ => NotificationType.task,
    };
  }

  static String typeStorage(NotificationType type) => switch (type) {
        NotificationType.task => 'task',
        NotificationType.attendance => 'attendance',
        NotificationType.chat => 'chat',
        NotificationType.team => 'team',
        NotificationType.reminder => 'reminder',
      };
}
