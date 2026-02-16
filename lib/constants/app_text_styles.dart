// ============================================================================
// FILE: app_text_styles.dart
// DESCRIPTION: Typography and text style constants for the Stellantis Dealer
//              Hygiene App. This file defines reusable text styles that ensure
//              consistent typography across all screens and components.
// ============================================================================
// PROJECT: Stellantis Dealer Hygiene App
// AUTHOR: Rahul Raja
// WEBSITE: https://www.stellantis.com/
// VERSION: 2.4.0
// ============================================================================
// COPYRIGHT: © 2026 STELLANTIS N.V. - INTERNAL USE ONLY
// ============================================================================

import 'package:flutter/material.dart';
import 'app_colors.dart';

/// AppTextStyles - Typography System for Stellantis App
///
/// This class provides predefined text styles that maintain consistent typography
/// throughout the application. All text styles follow the Stellantis design
/// guidelines and brand identity.
///
/// Categories:
/// - Headings: h1, h2, subtitle
/// - Body Text: bodyBold, bodyRegular
/// - Button Text: button, buttonLink
/// - Small Text: caption, dividerText, cardTitle
/// - Input Text: hint
///
/// Usage:
/// ```dart
/// Text('Welcome', style: AppTextStyles.h1)
/// Text('Description', style: AppTextStyles.bodyRegular)
/// ```
class AppTextStyles {
  /// Private constructor to prevent instantiation
  AppTextStyles._();

  // ========== HEADING STYLES =========

  /// H1 - Large heading style
  /// Font size: 28px, Weight: Bold
  /// Used for: Page titles, main headings
  static const TextStyle h1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
  );

  /// H2 - Medium heading style
  /// Font size: 22px, Weight: Medium, Letter spacing: 1.5
  /// Used for: Section headers, secondary titles
  static const TextStyle h2 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.5,
  );

  /// Subtitle - Subheading style
  /// Font size: 18px, Color: Neutral grey
  /// Used for: Subtitles, taglines, descriptive headers
  static const TextStyle subtitle = TextStyle(
    fontSize: 18,
    color: AppColors.neutralGrey,
  );

  // ========== BODY TEXT STYLES =========

  /// Body Bold - Bold body text
  /// Font size: 16px, Weight: Bold
  /// Used for: Emphasized text, labels, important information
  static const TextStyle bodyBold = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 16,
  );

  /// Body Regular - Regular body text
  /// Font size: 16px, Weight: Normal
  /// Used for: Paragraphs, descriptions, general content
  static const TextStyle bodyRegular = TextStyle(
    fontSize: 16,
  );

  // ========== BUTTON TEXT STYLES =========

  /// Button - Primary button text style
  /// Font size: 18px, Weight: Bold, Color: White
  /// Used for: Button labels, call-to-action text
  static const TextStyle button = TextStyle(
    color: Colors.white,
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  /// Button Link - Text button/link style
  /// Font size: Default, Weight: Semi-bold, Color: Action blue
  /// Used for: Text links, secondary actions
  static const TextStyle buttonLink = TextStyle(
    color: AppColors.actionBlue,
    fontWeight: FontWeight.w600,
  );

  // ========== SMALL TEXT STYLES =========

  /// Caption - Small text style
  /// Font size: 10px, Color: Light grey
  /// Used for: Captions, copyright text, version numbers
  static const TextStyle caption = TextStyle(
    color: AppColors.lightGrey,
    fontSize: 10,
  );

  /// Divider Text - Section divider labels
  /// Font size: 12px, Weight: Normal, Color: Neutral grey, Letter spacing: 1.1
  /// Used for: Section separators, category labels
  static const TextStyle dividerText = TextStyle(
    color: AppColors.neutralGrey,
    fontSize: 12,
    letterSpacing: 1.1,
  );

  /// Card Title - Card header text
  /// Font size: 12px, Weight: Bold, Color: Action blue
  /// Used for: Card titles, badge text, status labels
  static const TextStyle cardTitle = TextStyle(
    color: AppColors.actionBlue,
    fontWeight: FontWeight.bold,
    fontSize: 12,
  );

  // ========== INPUT TEXT STYLES =========

  /// Hint - Input placeholder text
  /// Color: Neutral grey
  /// Used for: Text field placeholders, hint text
  static const TextStyle hint = TextStyle(
    color: AppColors.neutralGrey,
  );
}

// ============================================================================
// END OF FILE: app_text_styles.dart
// ============================================================================
// AUTHOR: Rahul Raja
// WEBSITE: https://www.stellantis.com/
// ============================================================================
