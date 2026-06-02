sealed class UserRoles {
  static const admin = 'admin';
  static const employee = 'employee';

  static bool isAdminRole(Object? role) => role == admin;
}
