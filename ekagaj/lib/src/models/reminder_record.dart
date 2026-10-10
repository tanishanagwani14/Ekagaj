import 'package:cloud_firestore/cloud_firestore.dart';

enum ReminderPriority { high, medium, low }

class ReminderRecord {
  const ReminderRecord({
    required this.id,
    required this.title,
    required this.timeLabel,
    required this.category,
    required this.priority,
    required this.isToday,
    this.dateLabel,
    this.remindAt,
    this.userId = '',
  });

  final String id;
  final String title;
  final String timeLabel;
  final String? dateLabel;
  final String category;
  final ReminderPriority priority;
  final bool isToday;
  final DateTime? remindAt;
  final String userId;

  factory ReminderRecord.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return ReminderRecord(
      id: doc.id,
      title: (data['title'] as String?)?.trim() ?? 'Reminder',
      timeLabel: (data['timeLabel'] as String?)?.trim() ?? '',
      dateLabel: (data['dateLabel'] as String?)?.trim(),
      category: (data['category'] as String?)?.trim() ?? 'General',
      priority: switch (data['priority']) {
        'high' => ReminderPriority.high,
        'low' => ReminderPriority.low,
        _ => ReminderPriority.medium,
      },
      isToday: data['isToday'] == true,
      remindAt: data['remindAt'] is Timestamp ? (data['remindAt'] as Timestamp).toDate() : null,
      userId: (data['userId'] as String?) ?? '',
    );
  }
}

extension ReminderPriorityX on ReminderPriority {
  String get label => name;
}
