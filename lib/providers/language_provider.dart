// ============================================================================
// FILE: language_provider.dart
// DESCRIPTION: Language state management provider for Stellantis Dealer
//              Hygiene App. Manages language selection, persistence, and
//              notification of language changes to the UI.
// ============================================================================
// PROJECT: Stellantis Dealer Hygiene App
// AUTHOR: AI Assistant
// WEBSITE: https://www.stellantis.com/
// VERSION: 1.0.0
// ============================================================================
// COPYRIGHT: © 2026 STELLANTIS N.V. - INTERNAL USE ONLY
// ============================================================================

import 'package:flutter/material.dart';
import '../models/language_model.dart';
import '../services/storage_service.dart';

/// LanguageProvider - Manages language selection state across the app
///
/// This provider uses ChangeNotifier to notify widgets when the language
/// changes. Language preference is persisted using StorageService.
///
/// Features:
/// - Select and change language
/// - Persist language preference to storage
/// - Load saved language on app start
/// - Notify listeners when language changes
/// - Provide current locale for MaterialApp
///
/// Usage:
/// ```dart
/// // In main.dart or app.dart
/// ChangeNotifierProvider(
///   create: (_) => LanguageProvider(),
///   child: MyApp(),
/// )
///
/// // In widgets
/// final languageProvider = Provider.of<LanguageProvider>(context);
/// languageProvider.setLanguage(Language.french());
/// ```
class LanguageProvider with ChangeNotifier {
  /// Storage service for persisting language preference
  final StorageService _storageService = StorageService();

  /// Current selected language (defaults to English)
  Language _currentLanguage = SupportedLanguages.defaultLanguage;

  /// Getter for current language
  Language get currentLanguage => _currentLanguage;

  /// Getter for current locale (for MaterialApp)
  Locale get currentLocale => _currentLanguage.locale;

  /// Check if a specific language is currently selected
  bool isLanguageSelected(Language language) {
    return _currentLanguage.code == language.code;
  }

  /// Constructor - Loads saved language preference
  LanguageProvider() {
    _loadLanguageFromStorage();
  }

  /// Load language preference from storage
  ///
  /// This method is called during initialization to restore the user's
  /// previously selected language. If no language is saved, it defaults
  /// to English (US).
  Future<void> _loadLanguageFromStorage() async {
    try {
      final savedCode = await _storageService.getSetting<String>('selected_language_code');

      if (savedCode != null) {
        final language = SupportedLanguages.getByCode(savedCode);

        if (language != null) {
          _currentLanguage = language;
          notifyListeners();

          print('✅ Language loaded from storage: ${language.name}');
        } else {
          print('⚠️  Invalid language code in storage: $savedCode');
          print('📦 Defaulting to English');
        }
      } else {
        print('📦 No saved language, defaulting to English');
      }
    } catch (e) {
      print('⚠️  Error loading language from storage: $e');
      print('📦 Defaulting to English');
    }
  }

  /// Set new language
  ///
  /// Updates the current language, saves it to storage, and notifies
  /// all listeners (widgets) about the change.
  ///
  /// Example:
  /// ```dart
  /// await languageProvider.setLanguage(Language.french());
  /// ```
  Future<void> setLanguage(Language language) async {
    if (_currentLanguage.code == language.code) {
      print('ℹ️  Language already set to ${language.name}');
      return;
    }

    try {
      // Update current language
      _currentLanguage = language;

      // Save to storage
      await _saveLanguageToStorage(language);

      // Notify all listeners
      notifyListeners();

      print('✅ Language changed to: ${language.name}');
    } catch (e) {
      print('❌ Error setting language: $e');
      // Revert to previous language on error
      _currentLanguage = SupportedLanguages.defaultLanguage;
      notifyListeners();
    }
  }

  /// Save language preference to storage
  ///
  /// Stores both the language code and a timestamp for tracking purposes.
  Future<void> _saveLanguageToStorage(Language language) async {
    try {
      await _storageService.saveSetting('selected_language_code', language.code);
      await _storageService.saveSetting(
        'language_timestamp',
        DateTime.now().toIso8601String(),
      );

      print('💾 Language saved to storage: ${language.code}');
    } catch (e) {
      print('❌ Error saving language to storage: $e');
      rethrow;
    }
  }

  /// Reset language to default (English US)
  ///
  /// Useful for testing or user preference reset.
  Future<void> resetToDefault() async {
    await setLanguage(SupportedLanguages.defaultLanguage);
    print('🔄 Language reset to default (English US)');
  }

  /// Get language change timestamp
  ///
  /// Returns when the language was last changed, or null if never changed.
  Future<DateTime?> getLanguageTimestamp() async {
    try {
      final timestamp = await _storageService.getSetting<String>('language_timestamp');
      if (timestamp != null) {
        return DateTime.parse(timestamp);
      }
    } catch (e) {
      print('⚠️  Error getting language timestamp: $e');
    }
    return null;
  }

  /// Clear language preference from storage
  ///
  /// This will cause the app to use default language on next launch.
  Future<void> clearLanguagePreference() async {
    try {
      await _storageService.saveSetting('selected_language_code', null);
      await _storageService.saveSetting('language_timestamp', null);

      _currentLanguage = SupportedLanguages.defaultLanguage;
      notifyListeners();

      print('🗑️  Language preference cleared');
    } catch (e) {
      print('❌ Error clearing language preference: $e');
    }
  }

  /// Get display text for current language
  ///
  /// Returns formatted text with flag emoji, useful for UI display.
  /// Example: "🇺🇸 English (US)"
  String get displayText => '${_currentLanguage.flag} ${_currentLanguage.name}';

  /// Get compact display text (just flag and native name)
  ///
  /// Returns: "🇺🇸 English"
  String get compactDisplayText => '${_currentLanguage.flag} ${_currentLanguage.nativeName}';
}

// ============================================================================
// END OF FILE: language_provider.dart
// ============================================================================
// AUTHOR: AI Assistant
// WEBSITE: https://www.stellantis.com/
// ============================================================================

