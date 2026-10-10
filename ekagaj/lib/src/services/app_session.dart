import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/user_profile.dart';
import 'notification_realtime_service.dart';
import 'user_repository.dart';
import 'user_roles.dart';

enum LoginPortal { admin, employee }

class AppSession {
  AppSession._();

  static final ValueNotifier<UserProfile?> profile = ValueNotifier(null);
  static final ValueNotifier<bool> authenticating = ValueNotifier(false);

  static Stream<User?> authStateChanges() => FirebaseAuth.instance.authStateChanges();

  static User? get firebaseUser => FirebaseAuth.instance.currentUser;

  static Future<void> restoreSession() async {
    final user = firebaseUser;
    if (user == null) {
      profile.value = null;
      return;
    }
    final loaded = await UserRepository.loadProfileForAuthUser(user);
    UserRepository.setCachedProfile(loaded);
    profile.value = loaded;
  }

  static Future<void> signIn({
    required String email,
    required String password,
    required LoginPortal portal,
  }) async {
    authenticating.value = true;
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final loaded = await UserRepository.loadProfileForAuthUser(credential.user!);
      if (loaded == null) {
        throw StateError(
          'No Ekagaj profile for this email. Tap "Create account" to finish setup, '
          'or ask your admin to add you first.',
        );
      }
      _assertPortalRole(loaded, portal);
      UserRepository.setCachedProfile(loaded);
      profile.value = loaded;
    } catch (e) {
      await FirebaseAuth.instance.signOut();
      UserRepository.setCachedProfile(null);
      profile.value = null;
      rethrow;
    } finally {
      authenticating.value = false;
    }
  }

  static Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
    required String username,
    required LoginPortal portal,
  }) async {
    authenticating.value = true;
    final normalizedEmail = email.trim().toLowerCase();
    UserCredential credential;
    var createdAuthUser = false;

    try {
      try {
        credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: normalizedEmail,
          password: password,
        );
        createdAuthUser = true;
      } on FirebaseAuthException catch (e) {
        if (e.code != 'email-already-in-use') rethrow;
        credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: normalizedEmail,
          password: password,
        );
      }

      if (portal == LoginPortal.admin) {
        await UserRepository.createAdminProfile(
          authUser: credential.user!,
          displayName: displayName,
          username: username,
        );
      } else {
        await UserRepository.linkEmployeeProfile(
          authUser: credential.user!,
          displayName: displayName,
          username: username,
        );
      }
      final loaded = await UserRepository.loadProfileForAuthUser(credential.user!);
      if (loaded == null) {
        throw StateError('Could not create your profile. Please try again.');
      }
      UserRepository.setCachedProfile(loaded);
      profile.value = loaded;
    } catch (e) {
      if (createdAuthUser) {
        await FirebaseAuth.instance.currentUser?.delete();
      } else {
        await FirebaseAuth.instance.signOut();
      }
      UserRepository.setCachedProfile(null);
      profile.value = null;
      rethrow;
    } finally {
      authenticating.value = false;
    }
  }

  static Future<void> signOut() async {
    await NotificationRealtimeService.stop();
    await FirebaseAuth.instance.signOut();
    UserRepository.setCachedProfile(null);
    profile.value = null;
  }

  static void _assertPortalRole(UserProfile loaded, LoginPortal portal) {
    final isAdmin = UserRoles.isAdminRole(loaded.role);
    if (portal == LoginPortal.admin && !isAdmin) {
      throw StateError('This account is not an admin. Use the Employee portal.');
    }
    if (portal == LoginPortal.employee && isAdmin) {
      throw StateError('Admin accounts must use the Admin portal.');
    }
  }
}
