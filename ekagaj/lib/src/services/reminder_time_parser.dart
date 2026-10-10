import 'package:intl/intl.dart';

/// Best-effort parse of user-entered reminder times like "5:00 PM" or "17:30".
DateTime? parseReminderDateTime({
  required String timeLabel,
  String? dateLabel,
  bool defaultToday = true,
}) {
  final time = timeLabel.trim();
  if (time.isEmpty) return null;

  final now = DateTime.now();
  DateTime day = DateTime(now.year, now.month, now.day);

  final date = dateLabel?.trim().toLowerCase() ?? '';
  if (date.contains('tomorrow')) {
    day = day.add(const Duration(days: 1));
  } else if (!defaultToday && date.isNotEmpty) {
    final parsed = DateFormat('MMM d').parseLoose(date);
    day = DateTime(now.year, parsed.month, parsed.day);
  }

  final patterns = ['h:mm a', 'hh:mm a', 'H:mm', 'HH:mm'];
  for (final pattern in patterns) {
    try {
      final parsed = DateFormat(pattern).parseLoose(time);
      var result = DateTime(day.year, day.month, day.day, parsed.hour, parsed.minute);
      if (!result.isAfter(now)) {
        result = result.add(const Duration(days: 1));
      }
      return result;
    } catch (_) {}
  }
  return null;
}
