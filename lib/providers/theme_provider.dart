// ============================================================================
// FILE: theme_provider.dart
// DESCRIPTION: Theme provider for managing dark mode state across the app
// ============================================================================
// PROJECT: Stellantis Dealer Hygiene App
// AUTHOR: AI Assistant
// WEBSITE: https://www.stellantis.com/
// VERSION: 1.0.0
// ============================================================================
// COPYRIGHT: © 2026 STELLANTIS N.V. - INTERNAL USE ONLY
// ============================================================================

import 'package:flutter/material.dart';
import '../services/storage_service.dart';

/// ThemeProvider - Manages theme (light/dark mode) state for the entire app
///
/// This provider uses ChangeNotifier to notify widgets when the theme changes.
/// Theme preference is persisted using StorageService.
///
/// Features:
/// - Toggle between light and dark themes
/// - Persist theme preference
/// - Load saved theme on app start
/// - Notify listeners when theme changes
///
/// Usage:
/// ```dart
/// // In main.dart or app.dart
/// ChangeNotifierProvider(
///   create: (_) => ThemeProvider(),
///   child: MyApp(),
/// )
///
/// // In widgets
/// final themeProvider = Provider.of<ThemeProvider>(context);
/// themeProvider.toggleTheme();
/// ```
class ThemeProvider with ChangeNotifier {
  /// Storage service for persisting theme preference
  final StorageService _storageService = StorageService();

  /// Current theme mode (defaults to light)
  ThemeMode _themeMode = ThemeMode.light;

  /// Getter for current theme mode
  ThemeMode get themeMode => _themeMode;

  /// Check if dark mode is active
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  /// Constructor - Loads saved theme preference
  ThemeProvider() {
    _loadThemeFromStorage();
  }

  /// Load theme preference from storage
  Future<void> _loadThemeFromStorage() async {
    final isDark = await _storageService.getSetting<bool>('darkMode');
    if (isDark != null) {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      notifyListeners();
    }
  }

  /// Toggle between light and dark themes
  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await _storageService.saveSetting('darkMode', isDarkMode);
    notifyListeners();
  }

  /// Set theme mode explicitly
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode != mode) {
      _themeMode = mode;
      await _storageService.saveSetting('darkMode', isDarkMode);
      notifyListeners();
    }
  }

  /// Set dark mode state explicitly
  Future<void> setDarkMode(bool isDark) async {
    await setThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);
  }
}

// ============================================================================
// END OF FILE: theme_provider.dart
// ============================================================================
// AUTHOR: AI Assistant
// WEBSITE: https://www.stellantis.com/
// ============================================================================

