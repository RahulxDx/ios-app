// ============================================================================
// FILE: feature_flags.dart
// DESCRIPTION: Simple feature toggles for enabling/disabling app flows.
// ============================================================================

/// FeatureFlags
///
/// Keep this dead-simple: flip booleans for temporary behavior.
class FeatureFlags {
  FeatureFlags._();

  /// TEMP: When true, app starts on dashboard (bypassing auth screens).
  /// Set to false for normal login/signup flow.
  ///
  /// Enable temporarily with:
  ///   flutter run --dart-define=BYPASS_AUTH=true
  static const bool bypassAuth = bool.fromEnvironment('BYPASS_AUTH', defaultValue: false);
}
