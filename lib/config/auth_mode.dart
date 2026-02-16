// ============================================================================
// FILE: auth_mode.dart
// DESCRIPTION: Basic switch for enabling/disabling backend authentication.
// ============================================================================

/// AuthMode
///
/// If [useBackendAuth] is false, login uses only local test users.
class AuthMode {
  AuthMode._();

  /// TEMP: Disable backend auth during development.
  /// Enable later with:
  ///   flutter run --dart-define=USE_BACKEND_AUTH=true
  static const bool useBackendAuth = bool.fromEnvironment('USE_BACKEND_AUTH', defaultValue: false);
}

