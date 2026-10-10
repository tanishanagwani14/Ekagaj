import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../config/backend_config.dart';
import '../models/reminder_record.dart';
import '../models/task_record.dart';

sealed class ReminderAlarmService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static var _ready = false;

  static const _channelId = 'ekagaj_reminder_alarms';
  static const _channelName = 'Ekagaj Reminder Alarms';
  static const _appChannelId = 'ekagaj_app_notifications';
  static const _appChannelName = 'Ekagaj Notifications';

  static final AndroidNotificationDetails _androidDetails = AndroidNotificationDetails(
    _channelId,
    _channelName,
    channelDescription: 'Audible alarms for tasks and reminders',
    importance: Importance.max,
    priority: Priority.max,
    playSound: true,
    enableVibration: true,
    visibility: NotificationVisibility.public,
    category: AndroidNotificationCategory.alarm,
    audioAttributesUsage: AudioAttributesUsage.alarm,
    fullScreenIntent: true,
    ticker: 'Ekagaj reminder',
  );

  static NotificationDetails get _details => NotificationDetails(android: _androidDetails);

  static const NotificationDetails _appDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      _appChannelId,
      _appChannelName,
      channelDescription: 'Real-time alerts from your team',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      visibility: NotificationVisibility.public,
      category: AndroidNotificationCategory.message,
    ),
  );

  static Future<void> init() async {
    if (_ready) return;

    tz_data.initializeTimeZones();
    try {
      final timezone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezone.identifier));
    } catch (e) {
      if (kDebugMode) debugPrint('Timezone fallback: $e');
      tz.setLocalLocation(tz.local);
    }

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: android);
    await _plugin.initialize(settings: initSettings);

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: 'Audible alarms for tasks and reminders',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        audioAttributesUsage: AudioAttributesUsage.alarm,
      ),
    );
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        _appChannelId,
        _appChannelName,
        description: 'Real-time alerts from your team',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      ),
    );
    await androidPlugin?.requestNotificationsPermission();
    await androidPlugin?.requestExactAlarmsPermission();

    _ready = true;
    if (kDebugMode) debugPrint('ReminderAlarmService ready');
  }

  static Future<void> showAppNotification({
    required int notificationId,
    required String title,
    required String body,
  }) async {
    if (!_ready) await init();
    await _plugin.show(
      id: notificationId,
      title: title,
      body: body,
      notificationDetails: _appDetails,
    );
  }

  static Future<void> showNow({
    required int notificationId,
    required String title,
    required String body,
  }) async {
    if (!_ready) await init();
    await _plugin.show(
      id: notificationId,
      title: title,
      body: body,
      notificationDetails: _details,
    );
  }

  static Future<bool> schedule({
    required int notificationId,
    required String title,
    required String body,
    required DateTime when,
  }) async {
    if (!_ready) await init();

    var target = when;
    if (!target.isAfter(DateTime.now())) {
      target = DateTime.now().add(const Duration(minutes: 1));
    }

    final scheduled = tz.TZDateTime.from(target, tz.local);

    try {
      await _plugin.zonedSchedule(
        id: notificationId,
        title: title,
        body: body,
        scheduledDate: scheduled,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        notificationDetails: _details,
      );
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('Exact alarm failed, trying inexact: $e');
      try {
        await _plugin.zonedSchedule(
          id: notificationId,
          title: title,
          body: body,
          scheduledDate: scheduled,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          notificationDetails: _details,
        );
        return true;
      } catch (e2) {
        if (kDebugMode) debugPrint('Schedule failed: $e2');
        return false;
      }
    }
  }

  static Future<void> cancel(int notificationId) async {
    if (!_ready) return;
    await _plugin.cancel(id: notificationId);
  }

  static int idFromString(String value) => value.hashCode.abs() % 2147483647;

  /// Re-schedule future reminders/tasks after app restart or login.
  static Future<void> syncPendingAlarms({required String userId}) async {
    if (!_ready) await init();
    if (!BackendConfig.useFirebase || userId.isEmpty) return;

    try {
      final reminders = await FirebaseFirestore.instance
          .collection('reminders')
          .where('userId', isEqualTo: userId)
          .get();

      for (final doc in reminders.docs) {
        final record = ReminderRecord.fromDoc(doc);
        final at = record.remindAt;
        if (at == null || !at.isAfter(DateTime.now())) continue;
        await schedule(
          notificationId: idFromString(doc.id),
          title: 'Ekagaj reminder',
          body: record.title,
          when: at,
        );
      }

      final tasks = await FirebaseFirestore.instance
          .collection('tasks')
          .where('status', isEqualTo: 'pending')
          .get();

      for (final doc in tasks.docs) {
        final task = TaskRecord.fromDoc(doc);
        final at = task.remindAt;
        if (at == null || !at.isAfter(DateTime.now())) continue;
        await schedule(
          notificationId: idFromString(doc.id),
          title: 'Task reminder',
          body: task.title,
          when: at,
        );
      }

      if (kDebugMode) debugPrint('Synced pending reminder alarms for $userId');
    } catch (e) {
      if (kDebugMode) debugPrint('Alarm sync failed: $e');
    }
  }
}
