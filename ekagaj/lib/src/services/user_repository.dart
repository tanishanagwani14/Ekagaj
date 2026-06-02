import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'user_roles.dart';

/// Firestore: `users/{uid}` — profile + role + password hash (see [PasswordHasher]).
/// Optional: `usernames/{normalizedUsername}` → `{ uid }` for uniqueness.
sealed class UserRepository {
  static const usersCollection = 'users';
  static const usernamesCollection = 'usernames';

  static String normalizeUsername(String username) {
    return username.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '');
  }

  static DocumentReference<Map<String, dynamic>> userDoc(String uid) {
    return FirebaseFirestore.instance.collection(usersCollection).doc(uid);
  }

  static DocumentReference<Map<String, dynamic>> usernameDoc(String normalizedUsername) {
    return FirebaseFirestore.instance.collection(usernamesCollection).doc(normalizedUsername);
  }

  static Future<DocumentSnapshot<Map<String, dynamic>>?> fetchCurrentUser() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return userDoc(uid).get();
  }

  static Future<bool> currentUserIsAdmin() async {
    try {
      final snap = await fetchCurrentUser();
      if (snap == null || !snap.exists) return false;
      return UserRoles.isAdminRole(snap.data()?['role']);
    } catch (_) {
      return false;
    }
  }
}
