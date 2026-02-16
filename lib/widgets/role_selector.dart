// ============================================================================
// FILE: role_selector.dart
// DESCRIPTION: Role selection widget allowing users to choose between Dealer and Manager roles.
// ============================================================================
// PROJECT: Stellantis Dealer Hygiene App
// AUTHOR: Rohith U
// WEBSITE: https://www.stellantis.com/
// VERSION: 1.0.0
// ============================================================================
// COPYRIGHT: © 2026 STELLANTIS N.V. - INTERNAL USE ONLY
// ============================================================================

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../models/user_role.dart';

/// A reusable role selector widget for choosing user roles.
/// 
/// Displays two role options side-by-side:
/// - Dealer Facilities: For facility staff performing audits
/// - Stellantis Manager: For managers reviewing audit results
/// 
/// Features:
/// - Visual selection feedback with border and background color changes
/// - Icon-based representation for each role
/// - Responsive layout that adapts to screen width
/// - Accessibility-friendly tap targets
/// 
/// The widget is stateless and relies on parent state management
/// through the [onChanged] callback.
/// 
/// TODO: Add animation when switching between roles
/// TODO: Support custom role configurations
/// TODO: Add accessibility labels for screen readers
class RoleSelector extends StatelessWidget {
  /// The currently selected role
  final UserRole selectedRole;
  
  /// Callback function invoked when role selection changes
  final void Function(UserRole?) onChanged;

  const RoleSelector({
    super.key,
    required this.selectedRole,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // ===============================================================
        // DEALER FACILITIES ROLE OPTION
        // ===============================================================
        // Left option for dealer/facility staff members
        Expanded(
          child: _buildRoleOption(
            UserRole.dealerFacilities,
            'Dealer Facilities',
            Icons.store_mall_directory,
          ),
        ),
        const SizedBox(width: 12),
        
        // ===============================================================
        // STELLANTIS MANAGER ROLE OPTION
        // ===============================================================
        // Right option for Stellantis management personnel
        Expanded(
          child: _buildRoleOption(
            UserRole.stellantisManager,
            'Stellantis Manager',
            Icons.badge,
          ),
        ),
      ],
    );
  }

  /// Builds an individual role option card.
  /// 
  /// Creates a tappable card with:
  /// - Icon representing the role
  /// - Label text
  /// - Visual feedback for selected state
  /// 
  /// The selected state changes:
  /// - Border: 2px action blue vs 1px neutral
  /// - Background: Light blue tint vs white
  /// - Icon/Text color: Action blue vs neutral grey
  /// - Font weight: Bold vs normal
  /// 
  /// Parameters:
  /// - [role]: The UserRole enum value this option represents
  /// - [label]: Display text for the role
  /// - [icon]: IconData to display above the label
  /// 
  /// Returns: A tappable Container with role information
  /// 
  /// TODO: Add haptic feedback on selection
  /// TODO: Add subtle animation for state transitions
  Widget _buildRoleOption(UserRole role, String label, IconData icon) {
    // Determine if this option is currently selected
    final isSelected = selectedRole == role;
    
    return InkWell(
      onTap: () => onChanged(role),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          // Background color changes when selected
          color: isSelected ? AppColors.actionBlue.withValues(alpha: 0.1) : AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            // Border color and width change when selected
            color: isSelected ? AppColors.actionBlue : AppColors.borderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Role icon with dynamic color
            Icon(
              icon,
              color: isSelected ? AppColors.actionBlue : AppColors.neutralGrey,
              size: 28,
            ),
            const SizedBox(height: 6),
            
            // Role label with dynamic styling
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyRegular.copyWith(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.actionBlue : AppColors.neutralGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// END OF FILE: role_selector.dart
// ============================================================================
// AUTHOR: Rohith U
// WEBSITE: https://www.stellantis.com/
// ============================================================================
