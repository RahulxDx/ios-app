// ============================================================================
// FILE: user_role.dart
// DESCRIPTION: Data model and enum for user roles and permissions.
// ============================================================================
// PROJECT: Stellantis Dealer Hygiene App
// AUTHOR: Rohith U
// WEBSITE: https://www.stellantis.com/
// VERSION: 1.0.0
// ============================================================================
// COPYRIGHT: © 2026 STELLANTIS N.V. - INTERNAL USE ONLY
// ============================================================================

/// User roles available in the Stellantis app.
/// 
/// These roles determine the access level and features available to the user.
enum UserRole {
  /// Represents a user at a dealer facility level.
  dealerFacilities,
  /// Represents a manager at the Stellantis corporate level.
  stellantisManager,
}

/// Extensions on [UserRole] to provide utility methods.
extension UserRoleExtension on UserRole {
  // TODO: Add a method to check permissions (e.g., hasPermission(Permission p)).
  
  /// Returns a user-friendly display name for the role.
  String get displayName {
    switch (this) {
      case UserRole.dealerFacilities:
        return 'Dealer Facilities';
      case UserRole.stellantisManager:
        return 'Stellantis Manager';
    }
  }
}

// ============================================================================
// END OF FILE: user_role.dart
// ============================================================================
// AUTHOR: Rohith U
// WEBSITE: https://www.stellantis.com/
// ============================================================================

