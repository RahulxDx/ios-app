// ============================================================================
// FILE: role_card.dart
// DESCRIPTION: Selectable card component for displaying user role options.
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

/// A card widget for displaying and selecting user roles.
/// 
/// This widget creates a visually distinct card with:
/// - Icon representation of the role
/// - Role title text
/// - Selection state visual feedback
/// - Tap interaction handling
/// 
/// The card changes appearance when selected:
/// - Border width increases from 2px to 3px
/// - Background color changes to light blue tint
/// - Font weight becomes bolder
/// 
/// This component is typically used in role selection screens
/// where users need to choose their account type or access level.
/// 
/// Usage Example:
/// ```dart
/// RoleCard(
///   title: 'Dealer Staff',
///   icon: Icons.store,
///   isSelected: selectedRole == 'dealer',
///   onTap: () => selectRole('dealer'),
/// )
/// ```
/// 
/// TODO: Add animation for selection state changes
/// TODO: Support custom color schemes
/// TODO: Add badge/indicator for recommended roles
class RoleCard extends StatelessWidget {
  /// Display text for the role
  final String title;
  
  /// Icon representing the role visually
  final IconData icon;
  
  /// Callback invoked when card is tapped
  final VoidCallback? onTap;
  
  /// Whether this card is currently selected
  final bool isSelected;

  const RoleCard({
    super.key,
    required this.title,
    required this.icon,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          // Background color changes when selected
          // Selected: Light blue tint, Unselected: White
          color: isSelected
              ? AppColors.actionBlue.withValues(alpha: 0.1)
              : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.actionBlue,
            // Border becomes thicker when selected (3px vs 2px)
            width: isSelected ? 3 : 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ===============================================================
            // ROLE ICON
            // ===============================================================
            // Always displayed in action blue color
            Icon(
              icon,
              color: AppColors.actionBlue,
              size: 32,
            ),
            const SizedBox(height: 8),
            
            // ===============================================================
            // ROLE TITLE
            // ===============================================================
            // Text with dynamic font weight based on selection
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: AppTextStyles.cardTitle.copyWith(
                  // Bolder text when selected for emphasis
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// END OF FILE: role_card.dart
// ============================================================================
// AUTHOR: Rohith U
// WEBSITE: https://www.stellantis.com/
// ============================================================================
