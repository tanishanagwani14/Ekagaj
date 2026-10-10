import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../config/backend_config.dart';
import '../models/employee_record.dart';
import 'employee_auth_service.dart';
import 'user_repository.dart';
import 'user_roles.dart';

sealed class EmployeeRepository {
  static final List<EmployeeRecord> _localEmployees = [];
  static final _localController = StreamController<List<EmployeeRecord>>.broadcast();

  static Stream<EmployeeRecord?> watchEmployee(String userId) {
    if (!BackendConfig.useFirebase || userId.isEmpty) {
      return Stream.value(null);
    }
    return FirebaseFirestore.instance
        .collection(UserRepository.usersCollection)
        .doc(userId)
        .snapshots()
        .map((snap) => snap.exists ? EmployeeRecord.fromMap(snap.id, snap.data()!) : null);
  }

  static Stream<List<EmployeeRecord>> watchEmployees() {
    if (!BackendConfig.useFirebase) {
      _localController.add(List.unmodifiable(_localEmployees));
      return _localController.stream;
    }
    return FirebaseFirestore.instance.collection(UserRepository.usersCollection).snapshots().map((snap) {
      final list = snap.docs.map((d) => EmployeeRecord.fromMap(d.id, d.data())).toList();
      list.sort((a, b) => b.displayName.compareTo(a.displayName));
      return list;
    });
  }

  static EmployeeOrgStats statsFrom(List<EmployeeRecord> employees) {
    final staff = employees.where((e) => !UserRoles.isAdminRole(e.role)).toList();
    final total = staff.length;
    final onLeave = staff.where((e) => e.isOnLeave).length;
    final activeToday = total - onLeave;
    return EmployeeOrgStats(total: total, activeToday: activeToday, onLeave: onLeave);
  }

  static List<DepartmentSummary> departmentsFrom(List<EmployeeRecord> employees) {
    final staff = employees.where((e) => !UserRoles.isAdminRole(e.role)).toList();
    final counts = <String, int>{};
    final activeCounts = <String, int>{};
    for (final e in staff) {
      final dept = e.department.isEmpty ? 'General' : e.department;
      counts[dept] = (counts[dept] ?? 0) + 1;
      if (!e.isOnLeave) {
        activeCounts[dept] = (activeCounts[dept] ?? 0) + 1;
      }
    }
    if (counts.isEmpty) return const [];

    return counts.entries.map((entry) {
      final total = entry.value;
      final active = activeCounts[entry.key] ?? 0;
      final productivity = total == 0 ? 0 : ((active / total) * 100).round();
      return DepartmentSummary(
        department: entry.key,
        employees: total,
        productivity: productivity,
      );
    }).toList()
      ..sort((a, b) => b.employees.compareTo(a.employees));
  }

  static void _notifyLocal() {
    _localController.add(List.unmodifiable(_localEmployees));
  }

  static Future<void> addEmployee({
    required String username,
    required String displayName,
    required String department,
    required String email,
    required String password,
    String role = UserRoles.employee,
  }) async {
    final normalized = UserRepository.normalizeUsername(username);
    if (normalized.isEmpty) {
      throw ArgumentError('Username is required.');
    }
    if (!UserRepository.isValidUsername(username)) {
      throw ArgumentError(
        'Username must be 2–60 characters: letters, numbers, dots, dashes, or underscores.',
      );
    }
    if (displayName.trim().isEmpty) {
      throw ArgumentError('Full name is required.');
    }
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail.isEmpty || !normalizedEmail.contains('@')) {
      throw ArgumentError('A valid work email is required.');
    }
    if (password.length < 6) {
      throw ArgumentError('Password must be at least 6 characters.');
    }

    if (!BackendConfig.useFirebase) {
      if (_localEmployees.any((e) => UserRepository.normalizeUsername(e.username) == normalized)) {
        throw StateError('Username is already taken.');
      }
      final record = EmployeeRecord(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        displayName: displayName.trim(),
        department: department.trim().isEmpty ? 'General' : department.trim(),
        username: username.trim(),
        email: normalizedEmail,
        role: role,
        status: 'active',
      );
      _localEmployees.insert(0, record);
      _notifyLocal();
      return;
    }

    final existingEmail = await UserRepository.userDocByEmail(normalizedEmail);
    if (existingEmail != null) {
      throw StateError('An employee with this email already exists.');
    }

    final userRef = UserRepository.newUserDoc();
    final uid = userRef.id;
    final nameRef = UserRepository.usernameDoc(normalized);

    await FirebaseFirestore.instance.runTransaction((txn) async {
      final taken = await txn.get(nameRef);
      if (taken.exists) {
        throw StateError('Username is already taken.');
      }
      txn.set(nameRef, {'uid': uid});
      txn.set(userRef, {
        'uid': uid,
        'email': normalizedEmail,
        'username': username.trim(),
        'usernameNormalized': normalized,
        'displayName': displayName.trim(),
        'department': department.trim().isEmpty ? 'General' : department.trim(),
        'role': role,
        'status': 'active',
        'attendance': '—',
        'tasksCompleted': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });

    await EmployeeAuthService.createLoginForEmployee(
      email: normalizedEmail,
      password: password,
    );
  }
}
