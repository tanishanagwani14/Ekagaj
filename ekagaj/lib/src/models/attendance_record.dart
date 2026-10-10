import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

enum AttendanceStatus { present, late, absent, halfDay }

class AttendanceDayRecord {
  const AttendanceDayRecord({
    required this.id,
    this.checkInAt,
    this.checkInLat,
    this.checkInLng,
    this.checkOutAt,
    this.checkOutLat,
    this.checkOutLng,
  });

  final String id;
  final DateTime? checkInAt;
  final double? checkInLat;
  final double? checkInLng;
  final DateTime? checkOutAt;
  final double? checkOutLat;
  final double? checkOutLng;

  bool get isCheckedIn => checkInAt != null && checkOutAt == null;

  Duration? get workedDuration {
    if (checkInAt == null || checkOutAt == null) return null;
    return checkOutAt!.difference(checkInAt!);
  }

  AttendanceStatus get status {
    if (checkInAt == null) return AttendanceStatus.absent;
    final inHour = checkInAt!.hour;
    final inMinute = checkInAt!.minute;
    if (inHour > 9 || (inHour == 9 && inMinute > 15)) return AttendanceStatus.late;
    final worked = workedDuration;
    if (worked != null && worked.inHours < 6) return AttendanceStatus.halfDay;
    return AttendanceStatus.present;
  }

  String get displayDate {
    try {
      final parsed = DateFormat('yyyy-MM-dd').parse(id);
      return DateFormat('MMM d, yyyy').format(parsed);
    } catch (_) {
      return id;
    }
  }

  String formatTime(DateTime? time) {
    if (time == null) return '—';
    return DateFormat.jm().format(time);
  }

  String formatCoords(double? lat, double? lng) {
    if (lat == null || lng == null) return '—';
    return '${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}';
  }

  String get hoursLabel {
    final worked = workedDuration;
    if (worked == null) return '—';
    final h = worked.inHours;
    final m = worked.inMinutes.remainder(60);
    return '${h}h ${m}m';
  }

  factory AttendanceDayRecord.fromMap(String id, Map<String, dynamic> data) {
    DateTime? readTime(dynamic value) {
      if (value is Timestamp) return value.toDate();
      return null;
    }

    double? readDouble(dynamic value) => value is num ? value.toDouble() : null;

    return AttendanceDayRecord(
      id: id,
      checkInAt: readTime(data['checkInAt']),
      checkInLat: readDouble(data['checkInLat']),
      checkInLng: readDouble(data['checkInLng']),
      checkOutAt: readTime(data['checkOutAt']),
      checkOutLat: readDouble(data['checkOutLat']),
      checkOutLng: readDouble(data['checkOutLng']),
    );
  }

  AttendanceDayRecord copyWith({
    DateTime? checkInAt,
    double? checkInLat,
    double? checkInLng,
    DateTime? checkOutAt,
    double? checkOutLat,
    double? checkOutLng,
  }) {
    return AttendanceDayRecord(
      id: id,
      checkInAt: checkInAt ?? this.checkInAt,
      checkInLat: checkInLat ?? this.checkInLat,
      checkInLng: checkInLng ?? this.checkInLng,
      checkOutAt: checkOutAt ?? this.checkOutAt,
      checkOutLat: checkOutLat ?? this.checkOutLat,
      checkOutLng: checkOutLng ?? this.checkOutLng,
    );
  }
}

extension AttendanceStatusX on AttendanceStatus {
  String get label => switch (this) {
        AttendanceStatus.present => 'present',
        AttendanceStatus.late => 'late',
        AttendanceStatus.absent => 'absent',
        AttendanceStatus.halfDay => 'half-day',
      };
}

class MonthlyAttendanceStats {
  const MonthlyAttendanceStats({
    required this.present,
    required this.late,
    required this.absent,
    required this.halfDay,
  });

  final int present;
  final int late;
  final int absent;
  final int halfDay;

  static MonthlyAttendanceStats fromRecords(List<AttendanceDayRecord> records) {
    var present = 0;
    var late = 0;
    var absent = 0;
    var halfDay = 0;

    for (final record in records) {
      switch (record.status) {
        case AttendanceStatus.present:
          present++;
        case AttendanceStatus.late:
          late++;
        case AttendanceStatus.absent:
          absent++;
        case AttendanceStatus.halfDay:
          halfDay++;
      }
    }

    return MonthlyAttendanceStats(
      present: present,
      late: late,
      absent: absent,
      halfDay: halfDay,
    );
  }
}
