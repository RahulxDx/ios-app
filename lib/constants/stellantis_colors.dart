// ============================================================================
// FILE: stellantis_colors.dart
// DESCRIPTION: Official Stellantis brand colors and theme configuration for
//              the Stellantis Dealer Hygiene App. This file contains the
//              complete color palette based on Stellantis N.V. brand guidelines
//              and provides pre-configured theme data for consistent branding.
// ============================================================================
// PROJECT: Stellantis Dealer Hygiene App
// AUTHOR: Rahul Raja
// WEBSITE: https://www.stellantis.com/
// VERSION: 2.4.0
// ============================================================================
// COPYRIGHT: © 2026 STELLANTIS N.V. - INTERNAL USE ONLY
// ============================================================================

import 'package:flutter/material.dart';

/// StellantisColors - Official Brand Colors
///
/// This class contains the complete Stellantis color palette based on the
/// official Stellantis N.V. brand guidelines. These colors ensure brand
/// consistency across the entire application.
///
/// Color Categories:
/// - Primary Brand Colors: stellantisBlue, deepBlue, skyBlue
/// - Secondary Colors: red, silver, gold
/// - Functional Colors: success, warning, error, info
/// - Neutral Colors: white, background, surface, divider
/// - Text Colors: textPrimary, textSecondary, textLight, textOnPrimary
/// - Status Colors: compliant, partiallyCompliant, nonCompliant
/// - Progress Colors: progressHigh, progressMedium, progressLow, progressCritical
/// - Component Colors: cardBackground, cardBorder, cardShadow
/// - Badge Colors: activeGreen, pendingOrange, inactiveGray
/// - Gradients: primaryGradient, accentGradient
///
/// Usage:
/// ```dart
/// Container(
///   color: StellantisColors.stellantisBlue,
///   decoration: BoxDecoration(gradient: StellantisColors.primaryGradient),
/// )
/// ```
class StellantisColors {
  /// Private constructor to prevent instantiation
  StellantisColors._();

  // ========== PRIMARY BRAND COLORS ==========

  /// Primary Stellantis Navy - Main brand color (replacing blue).
  /// Hex: #003874
  /// Used for: Primary branding, headers, main UI elements
  static const Color stellantisBlue = Color(0xFF003874);

  /// Deep Navy Blue - Dark brand color
  /// Hex: #0C2340 - RGB: (12, 35, 64)
  /// Used for: Dark accents, text on light backgrounds
  static const Color deepBlue = Color(0xFF0C2340);

  /// Sky Blue (deprecated) - mapped to a neutral grey per navy/gray grading.
  /// Hex: #6C757D
  /// Used for: Interactive elements, highlights, secondary actions
  static const Color skyBlue = Color(0xFF6C757D);

  // ========== SECONDARY COLORS ==========

  /// Stellantis Red - Alert and emphasis color
  /// Hex: #D32F2F - RGB: (211, 47, 47)
  /// Used for: Alerts, important notifications, error states
  static const Color red = Color(0xFFD32F2F);

  /// Stellantis Silver - Neutral accent color
  /// Hex: #BDBDBD - RGB: (189, 189, 189)
  /// Used for: Subtle accents, disabled states
  static const Color silver = Color(0xFFBDBDBD);

  /// Stellantis Gold - Premium accent color
  /// Hex: #FFB300 - RGB: (255, 179, 0)
  /// Used for: Premium features, achievements, highlights
  static const Color gold = Color(0xFFFFB300);

  // ========== FUNCTIONAL COLORS ==========

  /// Success Green - Positive feedback color
  /// Hex: #2E7D32 - RGB: (46, 125, 50)
  /// Used for: Success messages, compliant status, positive feedback
  static const Color success = Color(0xFF2E7D32);

  /// Warning Orange - Caution color
  /// Hex: #F57C00 - RGB: (245, 124, 0)
  /// Used for: Warnings, attention alerts, partial compliance
  static const Color warning = Color(0xFFF57C00);

  /// Error Red - Error state color
  /// Hex: #C62828 - RGB: (198, 40, 40)
  /// Used for: Error messages, critical alerts, failed states
  static const Color error = Color(0xFFC62828);

  /// Info (deprecated) - mapped to neutral grey.
  /// Hex: #6C757D
  /// Used for: Information messages, helpful tips
  static const Color info = Color(0xFF6C757D);

  // ========== NEUTRAL COLORS ==========

  /// Pure White
  /// Hex: #FFFFFF - RGB: (255, 255, 255)
  /// Used for: Backgrounds, cards, text on dark surfaces
  static const Color white = Color(0xFFFFFFFF);

  /// Background Grey - Main app background
  /// Hex: #F5F7FA - RGB: (245, 247, 250)
  /// Used for: Screen backgrounds, page surfaces
  static const Color background = Color(0xFFF5F7FA);

  /// Surface White - Component surfaces
  /// Hex: #FFFFFF - RGB: (255, 255, 255)
  /// Used for: Card surfaces, elevated components
  static const Color surface = Color(0xFFFFFFFF);

  /// Divider Grey - Separator color
  /// Hex: #E0E0E0 - RGB: (224, 224, 224)
  /// Used for: Dividers, separators, borders
  static const Color divider = Color(0xFFE0E0E0);

  // ========== TEXT COLORS ==========

  /// Primary Text - Main text color
  /// Hex: #212121 - RGB: (33, 33, 33)
  /// Used for: Body text, headings, primary content
  static const Color textPrimary = Color(0xFF212121);

  /// Secondary Text - Supporting text color
  /// Hex: #757575 - RGB: (117, 117, 117)
  /// Used for: Secondary information, subtitles
  static const Color textSecondary = Color(0xFF757575);

  /// Light Text - Tertiary text color
  /// Hex: #9E9E9E - RGB: (158, 158, 158)
  /// Used for: Hints, placeholders, disabled text
  static const Color textLight = Color(0xFF9E9E9E);

  /// Text on Primary - Text for colored backgrounds
  /// Hex: #FFFFFF - RGB: (255, 255, 255)
  /// Used for: Text on primary color backgrounds
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ========== STATUS COLORS FOR COMPLIANCE ==========

  /// Compliant Green - Fully compliant status
  /// Hex: #43A047 - RGB: (67, 160, 71)
  /// Used for: Fully compliant audits, 100% completion
  static const Color compliant = Color(0xFF43A047);

  /// Partially Compliant Orange - Partial compliance status
  /// Hex: #FB8C00 - RGB: (251, 140, 0)
  /// Used for: Partially compliant audits, needs attention
  static const Color partiallyCompliant = Color(0xFFFB8C00);

  /// Non-Compliant Red - Failed compliance status
  /// Hex: #E53935 - RGB: (229, 57, 53)
  /// Used for: Non-compliant audits, critical issues
  static const Color nonCompliant = Color(0xFFE53935);

  // ========== PROGRESS BAR COLORS ==========

  /// Progress High - High compliance indicator (Green)
  /// Hex: #66BB6A - RGB: (102, 187, 106)
  /// Used for: 80-100% compliance progress
  static const Color progressHigh = Color(0xFF66BB6A);

  /// Progress Medium - Medium compliance indicator (Blue)
  /// Hex: #42A5F5 - RGB: (66, 165, 245)
  /// Used for: 50-79% compliance progress
  static const Color progressMedium = Color(0xFF42A5F5);

  /// Progress Low - Low compliance indicator (Orange)
  /// Hex: #FF9800 - RGB: (255, 152, 0)
  /// Used for: 25-49% compliance progress
  static const Color progressLow = Color(0xFFFF9800);

  /// Progress Critical - Critical compliance indicator (Red)
  /// Hex: #EF5350 - RGB: (239, 83, 80)
  /// Used for: 0-24% compliance progress
  static const Color progressCritical = Color(0xFFEF5350);

  // ========== CARD & COMPONENT COLORS ==========

  /// Card Background - Card surface color
  /// Hex: #FFFFFF - RGB: (255, 255, 255)
  static const Color cardBackground = Color(0xFFFFFFFF);

  /// Card Border - Card outline color
  /// Hex: #E0E0E0 - RGB: (224, 224, 224)
  static const Color cardBorder = Color(0xFFE0E0E0);

  /// Card Shadow - Card elevation shadow
  /// Hex: #0F000000 - RGBA: (0, 0, 0, 0.06)
  static const Color cardShadow = Color(0x0F000000);

  // ========== STATUS BADGE COLORS ==========

  /// Active Green - Active status indicator
  /// Hex: #4CAF50 - RGB: (76, 175, 80)
  static const Color activeGreen = Color(0xFF4CAF50);

  /// Active Green Background - Active badge background
  /// Hex: #E8F5E9 - RGB: (232, 245, 233)
  static const Color activeGreenBg = Color(0xFFE8F5E9);

  /// Pending Orange - Pending status indicator
  /// Hex: #FF9800 - RGB: (255, 152, 0)
  static const Color pendingOrange = Color(0xFFFF9800);

  /// Pending Orange Background - Pending badge background
  /// Hex: #FFF3E0 - RGB: (255, 243, 224)
  static const Color pendingOrangeBg = Color(0xFFFFF3E0);

  /// Inactive Gray - Inactive status indicator
  /// Hex: #9E9E9E - RGB: (158, 158, 158)
  static const Color inactiveGray = Color(0xFF9E9E9E);

  /// Inactive Gray Background - Inactive badge background
  /// Hex: #F5F5F5 - RGB: (245, 245, 245)
  static const Color inactiveGrayBg = Color(0xFFF5F5F5);

  // ========== GRADIENT COLORS ==========

  /// Primary Gradient - Main brand gradient
  /// From: #1B4B8C (Stellantis Blue) to #2563A8 (Lighter Blue)
  /// Used for: Hero sections, primary buttons, premium features
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [StellantisColors.deepBlue, StellantisColors.stellantisBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Accent Gradient - Neutral navy/gray gradient
  static const LinearGradient accentGradient = LinearGradient(
    colors: [StellantisColors.stellantisBlue, StellantisColors.silver],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

/// StellantisTheme - Pre-configured Theme Data
///
/// This class provides a complete Material Design theme configured with
/// Stellantis brand colors and typography. It ensures consistent look and
/// feel across the entire application.
///
/// Features:
/// - Custom color scheme with Stellantis brand colors
/// - Typography using Roboto font family
/// - Consistent component styling (buttons, cards, app bar)
/// - Accessibility-compliant color contrasts
///
/// Usage:
/// ```dart
/// MaterialApp(
///   theme: StellantisTheme.lightTheme,
///   home: HomePage(),
/// )
/// ```
class StellantisTheme {
  /// Private constructor to prevent instantiation
  StellantisTheme._();

  /// Light Theme - Stellantis branded light theme
  ///
  /// This theme provides a complete Material Design configuration with
  /// Stellantis colors, typography, and component styles.
  static ThemeData get lightTheme {
    return ThemeData(
      // Primary colors
      primaryColor: StellantisColors.stellantisBlue,
      scaffoldBackgroundColor: StellantisColors.background,

      // Color scheme
      colorScheme: ColorScheme.light(
        primary: StellantisColors.stellantisBlue,
        secondary: StellantisColors.skyBlue,
        surface: StellantisColors.surface,
        error: StellantisColors.error,
        onPrimary: StellantisColors.textOnPrimary,
        onSecondary: StellantisColors.textOnPrimary,
        onSurface: StellantisColors.textPrimary,
        onError: StellantisColors.textOnPrimary,
      ),

      // Typography
      fontFamily: 'Roboto',
      textTheme: TextTheme(
        // Display styles (largest headings)
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: StellantisColors.textPrimary,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: StellantisColors.textPrimary,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: StellantisColors.textPrimary,
        ),

        // Headline styles (section headings)
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: StellantisColors.textPrimary,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: StellantisColors.textPrimary,
        ),

        // Title styles (component titles)
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: StellantisColors.textPrimary,
        ),

        // Body styles (content text)
        bodyLarge: TextStyle(fontSize: 16, color: StellantisColors.textPrimary),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: StellantisColors.textSecondary,
        ),
        bodySmall: TextStyle(fontSize: 12, color: StellantisColors.textLight),
      ),

      // AppBar theme
      appBarTheme: AppBarTheme(
        backgroundColor: StellantisColors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: StellantisColors.stellantisBlue),
        titleTextStyle: TextStyle(
          color: StellantisColors.stellantisBlue,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      // Button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: StellantisColors.stellantisBlue,
          foregroundColor: StellantisColors.textOnPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      // Card theme
      cardTheme: CardThemeData(
        color: StellantisColors.cardBackground,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  /// Dark Theme - Stellantis branded dark theme
  ///
  /// This theme provides a complete Material Design configuration for dark mode
  /// with Stellantis colors, typography, and component styles optimized for
  /// low-light environments.
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      // Primary colors
      primaryColor: StellantisColors.stellantisBlue,
      scaffoldBackgroundColor: Color(0xFF121212),

      // Color scheme
      colorScheme: ColorScheme.dark(
        primary: StellantisColors.stellantisBlue,
        secondary: StellantisColors.skyBlue,
        surface: Color(0xFF1E1E1E),
        error: StellantisColors.error,
        onPrimary: StellantisColors.textOnPrimary,
        onSecondary: StellantisColors.textOnPrimary,
        onSurface: Color(0xFFE0E0E0),
        onError: StellantisColors.textOnPrimary,
      ),

      // Typography
      fontFamily: 'Roboto',
      textTheme: TextTheme(
        // Display styles (largest headings)
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Color(0xFFE0E0E0),
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Color(0xFFE0E0E0),
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Color(0xFFE0E0E0),
        ),

        // Headline styles (section headings)
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFFE0E0E0),
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFFE0E0E0),
        ),

        // Title styles (component titles)
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFFE0E0E0),
        ),

        // Body styles (content text)
        bodyLarge: TextStyle(fontSize: 16, color: Color(0xFFE0E0E0)),
        bodyMedium: TextStyle(fontSize: 14, color: Color(0xFFB0B0B0)),
        bodySmall: TextStyle(fontSize: 12, color: Color(0xFF808080)),
      ),

      // AppBar theme
      appBarTheme: AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
        elevation: 0,
        iconTheme: IconThemeData(color: StellantisColors.stellantisBlue),
        titleTextStyle: TextStyle(
          color: StellantisColors.stellantisBlue,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      // Button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: StellantisColors.stellantisBlue,
          foregroundColor: StellantisColors.textOnPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      // Card theme
      cardTheme: CardThemeData(
        color: Color(0xFF1E1E1E),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

// ============================================================================
// END OF FILE: stellantis_colors.dart
// ============================================================================
// AUTHOR: Rahul Raja
// WEBSITE: https://www.stellantis.com/
// ============================================================================
