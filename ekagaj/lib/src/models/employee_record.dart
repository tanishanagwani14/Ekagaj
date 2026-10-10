class EmployeeRecord {
  const EmployeeRecord({
    required this.id,
    required this.displayName,
    required this.department,
    required this.username,
    required this.role,
    required this.status,
    this.email = '',
    this.attendance = '—',
    this.tasksCompleted = 0,
  });

  final String id;
  final String displayName;
  final String department;
  final String username;
  final String role;
  final String status;
  final String email;
  final String attendance;
  final int tasksCompleted;

  bool get isOnLeave => status == 'leave';

  factory EmployeeRecord.fromMap(String id, Map<String, dynamic> data) {
    return EmployeeRecord(
      id: id,
      displayName: (data['displayName'] as String?)?.trim().isNotEmpty == true
          ? (data['displayName'] as String).trim()
          : (data['username'] as String?)?.trim() ?? 'Employee',
      department: (data['department'] as String?)?.trim() ?? 'General',
      username: (data['username'] as String?)?.trim() ?? '',
      email: (data['email'] as String?)?.trim().toLowerCase() ?? '',
      role: (data['role'] as String?)?.trim() ?? 'employee',
      status: (data['status'] as String?)?.trim() ?? 'active',
      attendance: (data['attendance'] as String?)?.trim() ?? '—',
      tasksCompleted: (data['tasksCompleted'] as num?)?.toInt() ?? 0,
    );
  }
}

class EmployeeOrgStats {
  const EmployeeOrgStats({
    required this.total,
    required this.activeToday,
    required this.onLeave,
  });

  final int total;
  final int activeToday;
  final int onLeave;
}

class DepartmentSummary {
  const DepartmentSummary({
    required this.department,
    required this.employees,
    required this.productivity,
  });

  final String department;
  final int employees;
  final int productivity;
}
