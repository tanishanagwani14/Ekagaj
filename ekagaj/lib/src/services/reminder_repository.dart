import 'package:cloud_firestore/cloud_firestore.dart';

import '../config/backend_config.dart';
import '../models/reminder_record.dart';
import 'notification_repository.dart';
import 'reminder_alarm_service.dart';

sealed class ReminderRepository {
  static const _collection = 'reminders';

  static Stream<List<ReminderRecord>> watchForUser(String userId) {
    if (!BackendConfig.useFirebase || userId.isEmpty) return Stream.value(const []);

    return FirebaseFirestore.instance
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(ReminderRecord.fromDoc).toList());
  }

  static Future<ReminderRecord> addReminder({
    required String userId,
    required String title,
    required String timeLabel,
    required String category,
    required ReminderPriority priority,
    required bool isToday,
    String? dateLabel,
    DateTime? remindAt,
  }) async {
    final ref = FirebaseFirestore.instance.collection(_collection).doc();
    await ref.set({
      'userId': userId,
      'title': title.trim(),
      'timeLabel': timeLabel.trim(),
      'dateLabel': dateLabel?.trim(),
      'category': category.trim(),
      'priority': priority.label,
      'isToday': isToday,
      'remindAt': remindAt != null ? Timestamp.fromDate(remindAt) : FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    if (remindAt != null) {
      final notifId = ReminderAlarmService.idFromString(ref.id);
      final scheduled = await ReminderAlarmService.schedule(
        notificationId: notifId,
        title: 'Ekagaj reminder',
        body: title.trim(),
        when: remindAt,
      );
      if (!scheduled) {
        await ReminderAlarmService.showNow(
          notificationId: notifId + 1,
          title: 'Allow alarms in settings',
          body: 'Could not schedule alarm for ${title.trim()}. Enable notifications and alarms for Ekagaj.',
        );
      }
    }

    if (userId.isNotEmpty) {
      await NotificationRepository.notifyReminder(
        userId: userId,
        title: 'Reminder Saved',
        message: remindAt != null
            ? "'${title.trim()}' scheduled for $timeLabel"
            : "'${title.trim()}' saved",
      );
    }

    final snap = await ref.get();
    return ReminderRecord.fromDoc(snap);
  }
}
