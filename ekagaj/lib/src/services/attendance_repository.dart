import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

import '../config/backend_config.dart';
import '../models/attendance_record.dart';
import 'notification_repository.dart';

sealed class AttendanceRepository {
  static const _collection = 'attendance';

  static String _dayId(DateTime time) => DateFormat('yyyy-MM-dd').format(time);

  static Future<Position> currentPosition() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      throw StateError('Location services are disabled. Please turn on GPS.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw StateError('Location permission denied.');
    }
    if (permission == LocationPermission.deniedForever) {
      throw StateError('Location permission permanently denied. Enable it in settings.');
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 20),
      ),
    );
  }

  static DocumentReference<Map<String, dynamic>> _dayRef(String userId, String dayId) {
    return FirebaseFirestore.instance.collection(_collection).doc(userId).collection('days').doc(dayId);
  }

  static Stream<AttendanceDayRecord?> watchToday(String userId) {
    if (!BackendConfig.useFirebase || userId.isEmpty) {
      return Stream.value(null);
    }
    final dayId = _dayId(DateTime.now());
    return _dayRef(userId, dayId).snapshots().map((snap) {
      if (!snap.exists) return null;
      return AttendanceDayRecord.fromMap(dayId, snap.data() ?? {});
    });
  }

  static Stream<List<AttendanceDayRecord>> watchRecent(String userId, {int limit = 14}) {
    if (!BackendConfig.useFirebase || userId.isEmpty) {
      return Stream.value(const []);
    }

    return FirebaseFirestore.instance
        .collection(_collection)
        .doc(userId)
        .collection('days')
        .orderBy('checkInAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map((d) => AttendanceDayRecord.fromMap(d.id, d.data())).toList());
  }

  static Future<AttendanceDayRecord> checkIn(String userId) async {
    final now = DateTime.now();
    final position = await currentPosition();
    final dayId = _dayId(now);

    final record = AttendanceDayRecord(
      id: dayId,
      checkInAt: now,
      checkInLat: position.latitude,
      checkInLng: position.longitude,
    );

    if (BackendConfig.useFirebase && userId.isNotEmpty) {
      await _dayRef(userId, dayId).set({
        'checkInAt': Timestamp.fromDate(now),
        'checkInLat': position.latitude,
        'checkInLng': position.longitude,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await NotificationRepository.notifyAttendance(
        userId: userId,
        title: 'Checked In',
        message: 'You checked in at ${record.formatTime(now)}',
      );
    }

    return record;
  }

  static Future<AttendanceDayRecord> checkOut(String userId, AttendanceDayRecord existing) async {
    if (existing.checkInAt == null) {
      throw StateError('Check in before checking out.');
    }

    final now = DateTime.now();
    final position = await currentPosition();
    final dayId = existing.id;

    final updated = existing.copyWith(
      checkOutAt: now,
      checkOutLat: position.latitude,
      checkOutLng: position.longitude,
    );

    if (BackendConfig.useFirebase && userId.isNotEmpty) {
      await _dayRef(userId, dayId).set({
        'checkOutAt': Timestamp.fromDate(now),
        'checkOutLat': position.latitude,
        'checkOutLng': position.longitude,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await NotificationRepository.notifyAttendance(
        userId: userId,
        title: 'Checked Out',
        message: 'You checked out at ${updated.formatTime(now)}',
      );
    }

    return updated;
  }
}
