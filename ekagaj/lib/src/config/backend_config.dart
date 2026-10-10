import 'dev_flags.dart';

sealed class BackendConfig {
  /// Firestore + Firebase Core (unless [DevFlags.forceLocalBackend]).
  static bool get useFirebase => !DevFlags.forceLocalBackend;
}
