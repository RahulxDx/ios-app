// ============================================================================
// FILE: storage_service.dart
// DESCRIPTION: Local storage service for persisting app data.
// ============================================================================
// PROJECT: Stellantis Dealer Hygiene App
// AUTHOR: AI Assistant
// WEBSITE: https://www.stellantis.com/
// VERSION: 1.0.0
// ============================================================================
// COPYRIGHT: © 2026 STELLANTIS N.V. - INTERNAL USE ONLY
// ============================================================================

import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Storage service for local data persistence
///
/// Provides functionality for:
/// - Storing and retrieving app settings
/// - Caching audit data
/// - Offline data management
/// - User preferences
///
/// Mock implementation using in-memory storage.
/// Will be replaced with actual database (e.g., sqflite, hive) when backend is ready.
class StorageService {
  // Singleton pattern
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  /// Save a value to storage
  Future<void> save(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is String) {
      await prefs.setString(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    } else if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is List<String>) {
      await prefs.setStringList(key, value);
    } else {
      throw Exception("Invalid type for shared preferences");
    }
  }

  /// Get a value from storage
  Future<T?> get<T>(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.get(key) as T?;
  }

  /// Check if key exists
  Future<bool> contains(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(key);
  }

  /// Remove a value from storage
  Future<void> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  /// Clear all storage
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  /// Save JSON data
  Future<void> saveJson(String key, Map<String, dynamic> json) async {
    final jsonString = jsonEncode(json);
    await save(key, jsonString);
  }

  /// Get JSON data
  Future<Map<String, dynamic>?> getJson(String key) async {
    final jsonString = await get<String>(key);
    if (jsonString == null) return null;

    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// Save list of items
  Future<void> saveList(String key, List<dynamic> list) async {
    final jsonString = jsonEncode(list);
    await save(key, jsonString);
  }

  /// Get list of items
  Future<List<dynamic>?> getList(String key) async {
    final jsonString = await get<String>(key);
    if (jsonString == null) return null;

    try {
      return jsonDecode(jsonString) as List<dynamic>;
    } catch (e) {
      return null;
    }
  }

  // ===== Convenience methods for common storage needs =====

  /// Save user preferences
  Future<void> saveUserPreferences(Map<String, dynamic> preferences) async {
    await saveJson('user_preferences', preferences);
  }

  /// Get user preferences
  Future<Map<String, dynamic>> getUserPreferences() async {
    return await getJson('user_preferences') ?? {};
  }

  /// Save offline audit data
  Future<void> saveOfflineAudit(
    String auditId,
    Map<String, dynamic> auditData,
  ) async {
    final offlineAudits = (await getList('offline_audits') ?? [])
        .cast<Map<String, dynamic>>();
    offlineAudits.add({
      'id': auditId,
      'data': auditData,
      'timestamp': DateTime.now().toIso8601String(),
    });
    await saveList('offline_audits', offlineAudits);
  }

  /// Get offline audits
  Future<List<dynamic>> getOfflineAudits() async {
    return await getList('offline_audits') ?? [];
  }

  /// Clear offline audits
  Future<void> clearOfflineAudits() async {
    await remove('offline_audits');
  }

  /// Save last sync timestamp
  Future<void> saveLastSyncTime(DateTime timestamp) async {
    await save('last_sync', timestamp.toIso8601String());
  }

  /// Get last sync timestamp
  Future<DateTime?> getLastSyncTime() async {
    final timestamp = await get<String>('last_sync');
    if (timestamp == null) return null;

    try {
      return DateTime.parse(timestamp);
    } catch (e) {
      return null;
    }
  }

  // ===== Audit History Methods =====

  /// Get audit history
  Future<List<Map<String, dynamic>>> getAuditHistory() async {
    final history = await getList('audit_history');
    if (history == null) return [];
    return history.cast<Map<String, dynamic>>();
  }

  /// Add audit to history
  Future<void> addAuditToHistory(Map<String, dynamic> auditEntry) async {
    final history = await getAuditHistory();
    // Add to beginning of list
    history.insert(0, auditEntry);

    // Keep only last 50 entries
    if (history.length > 50) {
      history.removeRange(50, history.length);
    }

    await saveList('audit_history', history);
  }

  /// Clear audit history
  Future<void> clearAuditHistory() async {
    await remove('audit_history');
  }

  /// Save app settings
  Future<void> saveSetting(String key, dynamic value) async {
    final settings = await getJson('app_settings') ?? {};
    settings[key] = value;
    await saveJson('app_settings', settings);
  }

  /// Get app setting
  Future<T?> getSetting<T>(String key) async {
    final settings = await getJson('app_settings') ?? {};
    return settings[key] as T?;
  }

  /// Get all settings
  Future<Map<String, dynamic>> getAllSettings() async {
    return await getJson('app_settings') ?? {};
  }
}

// ============================================================================
// END OF FILE: storage_service.dart
// ============================================================================
