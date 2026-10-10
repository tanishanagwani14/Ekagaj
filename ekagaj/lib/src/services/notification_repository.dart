import 'package:cloud_firestore/cloud_firestore.dart';

import '../config/backend_config.dart';
import '../models/notification_record.dart';
import '../routes/ek_routes.dart';
import 'user_repository.dart';

sealed class NotificationRepository {
  static const _collection = 'notifications';

  static Stream<List<NotificationRecord>> watchForUser(String userId) {
    if (!BackendConfig.useFirebase || userId.isEmpty) {
      return Stream.value(const []);
    }

    return FirebaseFirestore.instance
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snap) {
      final items = snap.docs.map(NotificationRecord.fromDoc).toList();
      items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return items;
    });
  }

  static Stream<int> watchUnreadCount(String userId) {
    return watchForUser(userId).map((items) => items.where((i) => !i.read).length);
  }

  static Future<void> create({
    required String userId,
    required NotificationType type,
    required String title,
    required String message,
    String? route,
  }) async {
    if (!BackendConfig.useFirebase || userId.isEmpty) return;

    await FirebaseFirestore.instance.collection(_collection).add({
      'userId': userId,
      'type': NotificationRecord.typeStorage(type),
      'title': title.trim(),
      'message': message.trim(),
      if (route != null && route.isNotEmpty) 'route': route,
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> markRead(String notificationId) async {
    if (!BackendConfig.useFirebase || notificationId.isEmpty) return;
    await FirebaseFirestore.instance.collection(_collection).doc(notificationId).update({
      'read': true,
    });
  }

  static Future<void> markAllRead(String userId) async {
    if (!BackendConfig.useFirebase || userId.isEmpty) return;

    final snap = await FirebaseFirestore.instance
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .where('read', isEqualTo: false)
        .get();

    if (snap.docs.isEmpty) return;

    final batch = FirebaseFirestore.instance.batch();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'read': true});
    }
    await batch.commit();
  }

  static Future<void> notifyTaskAssigned({
    required String assigneeUserId,
    required String taskTitle,
    required String assignedByName,
  }) async {
    await create(
      userId: assigneeUserId,
      type: NotificationType.task,
      title: 'Task Assigned',
      message: "$assignedByName assigned you '$taskTitle'",
      route: EkRoutes.tasks,
    );
  }

  static Future<void> notifyTaskCompleted({
    required String recipientUserId,
    required String taskTitle,
    required String completedByName,
  }) async {
    await create(
      userId: recipientUserId,
      type: NotificationType.task,
      title: 'Task Completed',
      message: "$completedByName completed '$taskTitle'",
      route: EkRoutes.tasks,
    );
  }

  static Future<void> notifyChatMessage({
    required String recipientUserId,
    required String senderName,
    required String preview,
  }) async {
    await create(
      userId: recipientUserId,
      type: NotificationType.chat,
      title: 'New Message',
      message: '$senderName: $preview',
      route: EkRoutes.chat,
    );
  }

  static Future<void> notifyAttendance({
    required String userId,
    required String title,
    required String message,
  }) async {
    await create(
      userId: userId,
      type: NotificationType.attendance,
      title: title,
      message: message,
      route: EkRoutes.attendance,
    );
  }

  static Future<void> notifyReminder({
    required String userId,
    required String title,
    required String message,
  }) async {
    await create(
      userId: userId,
      type: NotificationType.reminder,
      title: title,
      message: message,
      route: EkRoutes.reminders,
    );
  }

  static Future<void> notifyFollowUp({
    required String recipientUserId,
    required String clientName,
    required String createdByName,
  }) async {
    await create(
      userId: recipientUserId,
      type: NotificationType.team,
      title: 'New Follow-up',
      message: "$createdByName added follow-up for $clientName",
      route: EkRoutes.followUps,
    );
  }

  static Future<String?> resolveUserIdByAssigneeLabel(String label) async {
    if (!BackendConfig.useFirebase) return null;
    final trimmed = label.trim().toLowerCase();
    if (trimmed.isEmpty || trimmed == 'unassigned') return null;

    final snap = await FirebaseFirestore.instance.collection(UserRepository.usersCollection).get();
    for (final doc in snap.docs) {
      final data = doc.data();
      final name = (data['displayName'] as String?)?.trim().toLowerCase() ?? '';
      final username = (data['username'] as String?)?.trim().toLowerCase() ?? '';
      if (name == trimmed || username == trimmed || '@$username' == trimmed) {
        return doc.id;
      }
    }
    return null;
  }

  static Future<void> notifyTeamExcept({
    required String exceptUserId,
    required NotificationType type,
    required String title,
    required String message,
    String? route,
  }) async {
    if (!BackendConfig.useFirebase) return;

    final snap = await FirebaseFirestore.instance
        .collection(UserRepository.usersCollection)
        .where('status', isEqualTo: 'active')
        .get();

    final batch = FirebaseFirestore.instance.batch();
    var count = 0;
    for (final doc in snap.docs) {
      if (doc.id == exceptUserId) continue;
      final ref = FirebaseFirestore.instance.collection(_collection).doc();
      batch.set(ref, {
        'userId': doc.id,
        'type': NotificationRecord.typeStorage(type),
        'title': title.trim(),
        'message': message.trim(),
        if (route != null && route.isNotEmpty) 'route': route,
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
      count++;
      if (count >= 400) break;
    }
    if (count > 0) await batch.commit();
  }
}
