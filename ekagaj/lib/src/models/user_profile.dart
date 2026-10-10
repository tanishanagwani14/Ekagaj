import '../services/user_roles.dart';

class UserProfile {
  const UserProfile({
    required this.id,
    required this.displayName,
    required this.username,
    required this.email,
    required this.department,
    required this.role,
    this.status = 'active',
  });

  final String id;
  final String displayName;
  final String username;
  final String email;
  final String department;
  final String role;
  final String status;

  bool get isAdmin => UserRoles.isAdminRole(role);

  /// Name shown under the time-based greeting on Home (e.g. @rahul).
  String get greetingUsername {
    final handle = username.trim();
    if (handle.isNotEmpty) return '@$handle';
    final name = displayName.trim();
    if (name.isNotEmpty) return name;
    return 'User';
  }

  factory UserProfile.fromMap(String id, Map<String, dynamic> data) {
    return UserProfile(
      id: id,
      displayName: (data['displayName'] as String?)?.trim().isNotEmpty == true
          ? (data['displayName'] as String).trim()
          : (data['username'] as String?)?.trim() ?? 'User',
      username: (data['username'] as String?)?.trim() ?? '',
      email: (data['email'] as String?)?.trim().toLowerCase() ?? '',
      department: (data['department'] as String?)?.trim().isNotEmpty == true
          ? (data['department'] as String).trim()
          : 'General',
      role: (data['role'] as String?)?.trim() ?? UserRoles.employee,
      status: (data['status'] as String?)?.trim() ?? 'active',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'displayName': displayName,
      'username': username,
      'email': email,
      'department': department,
      'role': role,
      'status': status,
    };
  }
}
