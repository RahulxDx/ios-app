// ============================================================================
// FILE: language_model.dart
// DESCRIPTION: Language model and constants for multi-language support in
//              Stellantis Dealer Hygiene App. Defines supported languages
//              with locales, flags, and display names.
// ============================================================================
// PROJECT: Stellantis Dealer Hygiene App
// AUTHOR: AI Assistant
// WEBSITE: https://www.stellantis.com/
// VERSION: 1.0.0
// ============================================================================
// COPYRIGHT: © 2026 STELLANTIS N.V. - INTERNAL USE ONLY
// ============================================================================

import 'package:flutter/material.dart';

/// Language - Represents a supported language in the app
///
/// This model defines all properties needed for language selection:
/// - Language code (ISO format)
/// - Display name in English
/// - Native language name
/// - Flag emoji for visual identification
/// - Subtitle/description
/// - Flutter Locale object
///
/// Usage:
/// ```dart
/// final language = Language.english();
/// print(language.name); // "English (US)"
/// print(language.flag); // "🇺🇸"
/// ```
class Language {
  /// ISO language code (e.g., "en_US", "fr_FR")
  final String code;

  /// Display name in English (e.g., "English (US)", "French")
  final String name;

  /// Native language name (e.g., "English", "Français")
  final String nativeName;

  /// Flag emoji representing the language/country
  final String flag;

  /// Subtitle or description for the language
  final String subtitle;

  /// Flutter Locale object for the language
  final Locale locale;

  const Language({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flag,
    required this.subtitle,
    required this.locale,
  });

  /// English (US) - Default language
  static Language english() => const Language(
        code: 'en_US',
        name: 'English (US)',
        nativeName: 'English',
        flag: '🇺🇸',
        subtitle: 'Most commonly used',
        locale: Locale('en', 'US'),
      );

  /// French - Français
  static Language french() => const Language(
        code: 'fr_FR',
        name: 'French',
        nativeName: 'Français',
        flag: '🇫🇷',
        subtitle: 'Langue française',
        locale: Locale('fr', 'FR'),
      );

  /// German - Deutsch
  static Language german() => const Language(
        code: 'de_DE',
        name: 'German',
        nativeName: 'Deutsch',
        flag: '🇩🇪',
        subtitle: 'Deutsche Sprache',
        locale: Locale('de', 'DE'),
      );

  /// Spanish - Español
  static Language spanish() => const Language(
        code: 'es_ES',
        name: 'Spanish',
        nativeName: 'Español',
        flag: '🇪🇸',
        subtitle: 'Idioma español',
        locale: Locale('es', 'ES'),
      );

  /// Italian - Italiano
  static Language italian() => const Language(
        code: 'it_IT',
        name: 'Italian',
        nativeName: 'Italiano',
        flag: '🇮🇹',
        subtitle: 'Lingua italiana',
        locale: Locale('it', 'IT'),
      );

  /// Create a copy of this language with modified properties
  Language copyWith({
    String? code,
    String? name,
    String? nativeName,
    String? flag,
    String? subtitle,
    Locale? locale,
  }) {
    return Language(
      code: code ?? this.code,
      name: name ?? this.name,
      nativeName: nativeName ?? this.nativeName,
      flag: flag ?? this.flag,
      subtitle: subtitle ?? this.subtitle,
      locale: locale ?? this.locale,
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'nativeName': nativeName,
      'flag': flag,
      'subtitle': subtitle,
      'languageCode': locale.languageCode,
      'countryCode': locale.countryCode,
    };
  }

  /// Create from JSON storage
  factory Language.fromJson(Map<String, dynamic> json) {
    return Language(
      code: json['code'] as String,
      name: json['name'] as String,
      nativeName: json['nativeName'] as String,
      flag: json['flag'] as String,
      subtitle: json['subtitle'] as String,
      locale: Locale(
        json['languageCode'] as String,
        json['countryCode'] as String?,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Language && other.code == code;
  }

  @override
  int get hashCode => code.hashCode;

  @override
  String toString() => 'Language($name, $code)';
}

/// SupportedLanguages - Central repository of all supported languages
///
/// This class provides:
/// - List of all supported languages
/// - Default language
/// - Language lookup by code
/// - List of all locales
/// - Search functionality
///
/// Usage:
/// ```dart
/// final languages = SupportedLanguages.all;
/// final defaultLang = SupportedLanguages.defaultLanguage;
/// final french = SupportedLanguages.getByCode('fr_FR');
/// ```
class SupportedLanguages {
  /// Private constructor to prevent instantiation
  SupportedLanguages._();

  /// List of all supported languages (5 languages)
  static final List<Language> all = [
    Language.english(),
    Language.french(),
    Language.german(),
    Language.spanish(),
    Language.italian(),
  ];

  /// Default language (English US)
  static Language get defaultLanguage => Language.english();

  /// List of all supported locales for MaterialApp
  static List<Locale> get allLocales => all.map((lang) => lang.locale).toList();

  /// Get language by code
  ///
  /// Returns the language if found, null otherwise.
  /// Falls back to default language if code is invalid.
  ///
  /// Example:
  /// ```dart
  /// final lang = SupportedLanguages.getByCode('fr_FR');
  /// if (lang != null) print(lang.name); // "French"
  /// ```
  static Language? getByCode(String code) {
    try {
      return all.firstWhere(
        (lang) => lang.code.toLowerCase() == code.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Get language by locale
  ///
  /// Returns the language matching the locale, or default language.
  ///
  /// Example:
  /// ```dart
  /// final lang = SupportedLanguages.getByLocale(Locale('fr', 'FR'));
  /// ```
  static Language getByLocale(Locale locale) {
    try {
      return all.firstWhere(
        (lang) =>
            lang.locale.languageCode == locale.languageCode &&
            lang.locale.countryCode == locale.countryCode,
      );
    } catch (e) {
      return defaultLanguage;
    }
  }

  /// Search languages by query
  ///
  /// Searches in:
  /// - Language name (English)
  /// - Native name
  /// - Language code
  ///
  /// Example:
  /// ```dart
  /// final results = SupportedLanguages.search('fran');
  /// // Returns: [Language.french()]
  /// ```
  static List<Language> search(String query) {
    if (query.isEmpty) return all;

    final lowerQuery = query.toLowerCase();
    return all.where((lang) {
      return lang.name.toLowerCase().contains(lowerQuery) ||
          lang.nativeName.toLowerCase().contains(lowerQuery) ||
          lang.code.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Check if a language code is supported
  static bool isSupported(String code) {
    return getByCode(code) != null;
  }
}

// ============================================================================
// END OF FILE: language_model.dart
// ============================================================================
// AUTHOR: AI Assistant
// WEBSITE: https://www.stellantis.com/
// ============================================================================

