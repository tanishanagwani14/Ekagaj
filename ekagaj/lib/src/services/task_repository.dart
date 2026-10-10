import 'package:cloud_firestore/cloud_firestore.dart';

import '../config/backend_config.dart';
import '../models/employee_record.dart';
import '../models/task_record.dart';
import 'notification_repository.dart';
import 'reminder_alarm_service.dart';
import 'user_repository.dart';

sealed class TaskRepository {
  static const _collection = 'tasks';

  static Stream<List<TaskRecord>> watchAll() {
    if (!BackendConfig.useFirebase) return Stream.value(const []);

    return FirebaseFirestore.instance
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(TaskRecord.fromDoc).toList());
  }

  static Stream<List<TaskRecord>> watchPending({int limit = 5}) {
    return watchAll().map((tasks) => tasks.where((t) => t.isPending).take(limit).toList());
  }

  static Stream<List<TaskRecord>> watchForEmployee(EmployeeRecord employee) {
    return watchAll().map((tasks) {
      final name = employee.displayName.trim().toLowerCase();
      final handle = employee.username.trim().toLowerCase();
      return tasks.where((t) {
        final assigned = t.assignedTo.trim().toLowerCase();
        return assigned == name || assigned == handle || assigned == '@$handle';
      }).toList();
    });
  }

  static Future<TaskRecord> addTask({
    required String title,
    required String assignedTo,
    required String dueDate,
    required String category,
    required TaskPriority priority,
    required String createdBy,
    DateTime? remindAt,
  }) async {
    final ref = FirebaseFirestore.instance.collection(_collection).doc();
    await ref.set({
      'title': title.trim(),
      'assignedTo': assignedTo.trim(),
      'dueDate': dueDate.trim(),
      'category': category.trim(),
      'priority': priority.storage,
      'status': 'pending',
      'createdBy': createdBy,
      'createdAt': FieldValue.serverTimestamp(),
      if (remindAt != null) 'remindAt': Timestamp.fromDate(remindAt),
    });

    if (remindAt != null) {
      final notifId = ReminderAlarmService.idFromString(ref.id);
      final scheduled = await ReminderAlarmService.schedule(
        notificationId: notifId,
        title: 'Task reminder',
        body: title.trim(),
        when: remindAt,
      );
      if (!scheduled) {
        await ReminderAlarmService.showNow(
          notificationId: notifId + 1,
          title: 'Allow alarms in settings',
          body: 'Could not schedule task alarm for ${title.trim()}. Enable notifications and alarms for Ekagaj.',
        );
      }
    }

    if (createdBy.isNotEmpty) {
      final assigneeId = await NotificationRepository.resolveUserIdByAssigneeLabel(assignedTo);
      if (assigneeId != null && assigneeId != createdBy) {
        final assignerName = await _displayNameFor(createdBy);
        await NotificationRepository.notifyTaskAssigned(
          assigneeUserId: assigneeId,
          taskTitle: title.trim(),
          assignedByName: assignerName,
        );
      }
    }

    final snap = await ref.get();
    return TaskRecord.fromDoc(snap);
  }

  static Future<void> markComplete({
    required String taskId,
    required String completedByUserId,
    required String completedByName,
  }) async {
    final ref = FirebaseFirestore.instance.collection(_collection).doc(taskId);
    final before = await ref.get();
    final task = before.exists ? TaskRecord.fromDoc(before) : null;

    await ref.update({
      'status': 'completed',
      'completedAt': FieldValue.serverTimestamp(),
    });
    await ReminderAlarmService.cancel(ReminderAlarmService.idFromString(taskId));

    if (task != null &&
        task.createdBy.isNotEmpty &&
        task.createdBy != completedByUserId) {
      await NotificationRepository.notifyTaskCompleted(
        recipientUserId: task.createdBy,
        taskTitle: task.title,
        completedByName: completedByName,
      );
    }
  }

  static Future<String> _displayNameFor(String userId) async {
    final doc = await FirebaseFirestore.instance
        .collection(UserRepository.usersCollection)
        .doc(userId)
        .get();
    return (doc.data()?['displayName'] as String?)?.trim() ?? 'Someone';
  }

  static Future<void> markPending(String taskId) async {
    await FirebaseFirestore.instance.collection(_collection).doc(taskId).update({
      'status': 'pending',
      'completedAt': FieldValue.delete(),
    });
  }
}
