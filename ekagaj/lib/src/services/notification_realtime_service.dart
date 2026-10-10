import 'dart:async';

import 'package:flutter/foundation.dart';

import '../config/backend_config.dart';
import '../models/notification_record.dart';
import 'notification_repository.dart';
import 'reminder_alarm_service.dart';

/// Listens to Firestore notifications and shows device alerts for new items.
sealed class NotificationRealtimeService {
  static StreamSubscription<List<NotificationRecord>>? _subscription;
  static final _seenIds = <String>{};
  static var _bootstrapped = false;

  static Future<void> start(String userId) async {
    await stop();
    if (!BackendConfig.useFirebase || userId.isEmpty) return;

    _subscription = NotificationRepository.watchForUser(userId).listen(
      (items) {
        if (!_bootstrapped) {
          _seenIds.addAll(items.map((i) => i.id));
          _bootstrapped = true;
          return;
        }

        for (final item in items) {
          if (item.read || _seenIds.contains(item.id)) continue;
          _seenIds.add(item.id);
          unawaited(
            ReminderAlarmService.showAppNotification(
              notificationId: ReminderAlarmService.idFromString(item.id),
              title: item.title,
              body: item.message,
            ),
          );
        }
      },
      onError: (Object e) {
        if (kDebugMode) debugPrint('Notification stream error: $e');
      },
    );
  }

  static Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
    _bootstrapped = false;
    _seenIds.clear();
  }
}
