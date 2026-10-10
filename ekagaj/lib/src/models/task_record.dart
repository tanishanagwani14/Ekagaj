import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

enum TaskPriority { high, medium, low }

enum TaskStatus { pending, completed }

class TaskRecord {
  const TaskRecord({
    required this.id,
    required this.title,
    required this.assignedTo,
    required this.dueDate,
    required this.priority,
    required this.category,
    required this.status,
    this.completedAt,
    this.remindAt,
    this.createdBy = '',
  });

  final String id;
  final String title;
  final String assignedTo;
  final String dueDate;
  final TaskPriority priority;
  final String category;
  final TaskStatus status;
  final DateTime? completedAt;
  final DateTime? remindAt;
  final String createdBy;

  bool get isPending => status == TaskStatus.pending;

  String get completedDateLabel {
    if (completedAt == null) return 'Just now';
    return DateFormat('MMM d, h:mm a').format(completedAt!);
  }

  factory TaskRecord.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return TaskRecord(
      id: doc.id,
      title: (data['title'] as String?)?.trim() ?? 'Task',
      assignedTo: (data['assignedTo'] as String?)?.trim() ?? 'Unassigned',
      dueDate: (data['dueDate'] as String?)?.trim() ?? 'No due date',
      priority: TaskRecord._priorityFrom(data['priority']),
      category: (data['category'] as String?)?.trim() ?? 'General',
      status: (data['status'] as String?) == 'completed' ? TaskStatus.completed : TaskStatus.pending,
      completedAt: _readTime(data['completedAt']),
      remindAt: _readTime(data['remindAt']),
      createdBy: (data['createdBy'] as String?) ?? '',
    );
  }

  static TaskPriority _priorityFrom(dynamic value) {
    return switch (value) {
      'high' => TaskPriority.high,
      'low' => TaskPriority.low,
      _ => TaskPriority.medium,
    };
  }

  static DateTime? _readTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    return null;
  }
}

extension TaskPriorityX on TaskPriority {
  String get label => name;
  String get storage => name;
}
