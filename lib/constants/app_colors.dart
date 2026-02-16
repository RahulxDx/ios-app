// ============================================================================
// FILE: app_colors.dart
// DESCRIPTION: Application-wide color constants for the Stellantis Dealer
//              Hygiene App. This file defines the design system colors used
//              throughout the application for consistent branding and UI.
// ============================================================================
// PROJECT: Stellantis Dealer Hygiene App
// AUTHOR: Rahul Raja
// WEBSITE: https://www.stellantis.com/
// VERSION: 2.4.0
// ============================================================================
// COPYRIGHT: © 2026 STELLANTIS N.V. - INTERNAL USE ONLY
// ============================================================================

import 'package:flutter/material.dart';

/// AppColors - Design System Colors for Stellantis App
///
/// This class provides a centralized location for all color definitions used
/// throughout the application. It ensures consistent branding and makes it easy
/// to update colors across the entire app.
///
/// Usage:
/// ```dart
/// Container(
///   color: AppColors.brandNavy,
///   child: Text('Hello', style: TextStyle(color: AppColors.white)),
/// )
/// ```
class AppColors {
  /// Private constructor to prevent instantiation
  AppColors._();

  // ========== BRAND COLORS ==========

  /// Primary brand navy color - Used for headers, primary buttons, and branding
  /// Hex: #1D327D - RGB: (29, 50, 125)
  static const Color brandNavy = Color(0xFF1D327D);

  /// Action color (previously action blue) - Now aligned to brand navy.
  /// Use for interactive elements, links, and call-to-actions.
  /// Hex: #003874 - RGB: (0, 56, 116)
  static const Color actionBlue = Color(0xFF003874);

  // ========== NEUTRAL COLORS ==========

  /// Neutral grey color - Used for secondary text, labels, and icons
  /// Hex: #6C757D - RGB: (108, 117, 125)
  static const Color neutralGrey = Color(0xFF6C757D);

  /// Light grey color - Used for disabled text, placeholders, and subtle elements
  /// Hex: #ADB5BD - RGB: (173, 181, 189)
  static const Color lightGrey = Color(0xFFADB5BD);

  /// Border color - Used for input borders, dividers, and card outlines
  /// Hex: #DEE2E6 - RGB: (222, 226, 230)
  static const Color borderColor = Color(0xFFDEE2E6);

  /// Background grey color - Used for screen backgrounds and surface colors
  /// Hex: #F8F9FA - RGB: (248, 249, 250)
  static const Color backgroundGrey = Color(0xFFF8F9FA);

  /// Soft surface grey - good for pills, chips, subtle highlights
  /// Hex: #EEF2F6
  static const Color softGrey = Color(0xFFEEF2F6);

  // ========== FUNCTIONAL COLORS ==========

  /// Pure white color - Used for cards, containers, and text on dark backgrounds
  static const Color white = Colors.white;

  /// Transparent color - Used for invisible overlays and backgrounds
  static const Color transparent = Colors.transparent;
}

// ============================================================================
// END OF FILE: app_colors.dart
// ============================================================================
// AUTHOR: Rahul Raja
// WEBSITE: https://www.stellantis.com/
// ============================================================================
