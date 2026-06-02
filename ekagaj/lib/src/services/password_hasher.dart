import 'package:bcrypt/bcrypt.dart';

/// Stores passwords as bcrypt hashes in Firestore — never store plaintext passwords.
sealed class PasswordHasher {
  static String hash(String plainPassword) {
    return BCrypt.hashpw(plainPassword, BCrypt.gensalt());
  }

  static bool matches(String plainPassword, String storedHash) {
    return BCrypt.checkpw(plainPassword, storedHash);
  }
}
