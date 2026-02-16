// ============================================================================
// FILE: stellantis_logo.dart
// DESCRIPTION: Reusable Stellantis logo widget with fallback text rendering.
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

/// A reusable widget for displaying the Stellantis logo.
/// 
/// This widget handles:
/// - Loading and displaying the Stellantis logo image
/// - Fallback to text if image fails to load
/// - Configurable size through height parameter
/// - Optional container padding
/// 
/// Features:
/// - Graceful error handling with text fallback
/// - Flexible sizing options
/// - Optional padding wrapper
/// - Asset path management
/// 
/// The widget attempts to load the logo from assets, and if it fails
/// (missing file, corrupted image, etc.), it displays "STELLANTIS" as
/// styled text instead.
/// 
/// Usage Example:
/// ```dart
/// // Simple usage
/// StellantisLogo(height: 50)
/// 
/// // With padding container
/// StellantisLogo(height: 42, withContainer: true)
/// ```
/// 
/// TODO: Support different logo variants (light/dark theme)
/// TODO: Add loading shimmer while image loads
/// TODO: Support SVG format for better scaling
class StellantisLogo extends StatelessWidget {
  /// Height of the logo (width scales proportionally)
  final double height;
  
  /// Whether to wrap the logo in a padded container
  final bool withContainer;

  const StellantisLogo({
    super.key,
    this.height = 42,
    this.withContainer = false,
  });

  @override
  Widget build(BuildContext context) {
    // ===================================================================
    // LOGO IMAGE WITH FALLBACK
    // ===================================================================
    // Attempts to load image asset, falls back to text on error
    final logo = Image.asset(
      'assets/images/stellantis_logo.png',
      height: height,
      fit: BoxFit.contain,
      
      // Error handler for when image fails to load
      // Shows branded text as fallback
      errorBuilder: (context, error, stackTrace) {
        return Text(
          'STELLANTIS',
          style: AppTextStyles.h2.copyWith(
            color: AppColors.brandNavy,
          ),
        );
      },
    );

    // ===================================================================
    // CONDITIONAL CONTAINER WRAPPER
    // ===================================================================
    // Adds padding if requested, otherwise returns logo directly
    if (withContainer) {
      return Container(
        padding: const EdgeInsets.all(14),
        child: logo,
      );
    }

    return logo;
  }
}

// ============================================================================
// END OF FILE: stellantis_logo.dart
// ============================================================================
// AUTHOR: Rohith U
// WEBSITE: https://www.stellantis.com/
// ============================================================================
