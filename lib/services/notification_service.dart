// ============================================================================
// FILE: notification_service.dart
// DESCRIPTION: Local notification service for manager audit alerts
// ============================================================================
// PROJECT: Stellantis Dealer Hygiene App
// AUTHOR: AI Assistant
// VERSION: 1.0.0
// ============================================================================
// COPYRIGHT: © 2026 STELLANTIS N.V. - INTERNAL USE ONLY
// ============================================================================

import 'dart:async';
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import 'auth_service.dart';
import 'package:http/http.dart' as http;

/// Notification service for real-time audit alerts
///
/// Features:
/// - Polls backend for new audits periodically
/// - Shows local notifications when new audits detected
/// - Tracks last checked timestamp to avoid duplicates
/// - Customized notification based on audit status
/// - Works WITHOUT any backend changes
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  final AuthService _authService = AuthService();

  Timer? _pollingTimer;
  bool _isInitialized = false;
  bool _isPolling = false;
  DateTime? _lastCheckedTime;
  Set<String> _notifiedAuditIds = {};
  int _lastTotalAudits = 0;

  // Polling interval (10 seconds for faster detection - adjust as needed)
  static const Duration _pollingInterval = Duration(seconds: 10);

  // SharedPreferences keys
  static const String _keyLastChecked = 'notification_last_checked';
  static const String _keyNotifiedAudits = 'notification_notified_audits';

  /// Initialize notification service
  Future<void> initialize() async {
    if (_isInitialized) {
      print('⚠️  Notification service already initialized');
      return;
    }

    try {
      // Android notification settings
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS notification settings
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      // Initialize plugin
      await _notifications.initialize(
        settings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Load last checked time from storage
      await _loadState();

      _isInitialized = true;
      print('✅ Notification service initialized');
    } catch (e) {
      print('❌ Failed to initialize notification service: $e');
      rethrow;
    }
  }

  /// Load notification state from SharedPreferences
  Future<void> _loadState() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load last checked timestamp
      final lastCheckedString = prefs.getString(_keyLastChecked);
      if (lastCheckedString != null) {
        _lastCheckedTime = DateTime.parse(lastCheckedString);
        print('📅 Last checked time: $_lastCheckedTime');
      } else {
        // First time - set to current time minus 1 hour
        _lastCheckedTime = DateTime.now().subtract(const Duration(hours: 1));
      }

      // Load notified audit IDs
      final notifiedList = prefs.getStringList(_keyNotifiedAudits) ?? [];
      _notifiedAuditIds = Set.from(notifiedList);
      print('📋 Loaded ${_notifiedAuditIds.length} notified audit IDs');
    } catch (e) {
      print('⚠️  Error loading notification state: $e');
      _lastCheckedTime = DateTime.now().subtract(const Duration(hours: 1));
      _notifiedAuditIds = {};
    }
  }

  /// Save notification state to SharedPreferences
  Future<void> _saveState() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (_lastCheckedTime != null) {
        await prefs.setString(_keyLastChecked, _lastCheckedTime!.toIso8601String());
      }

      await prefs.setStringList(_keyNotifiedAudits, _notifiedAuditIds.toList());
    } catch (e) {
      print('⚠️  Error saving notification state: $e');
    }
  }

  /// Start polling for new audits
  Future<void> startPolling() async {
    if (!_isInitialized) {
      print('⚠️  Notification service not initialized. Call initialize() first.');
      return;
    }

    if (_isPolling) {
      print('⚠️  Already polling for notifications');
      return;
    }

    print('🔔 Starting audit notification polling...');
    _isPolling = true;

    // Check immediately on start
    await _checkForNewAudits();

    // Start periodic polling
    _pollingTimer = Timer.periodic(_pollingInterval, (timer) async {
      if (_isPolling) {
        await _checkForNewAudits();
      }
    });

    print('✅ Notification polling started (interval: ${_pollingInterval.inSeconds}s)');
  }

  /// Stop polling for new audits
  Future<void> stopPolling() async {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _isPolling = false;
    print('🔕 Notification polling stopped');
  }

  /// Check for new audits from backend
  Future<void> _checkForNewAudits() async {
    try {
      // Get recent audits from backend
      final baseUrl = await ApiConfig.getBaseUrl();
      final url = Uri.parse('$baseUrl${ApiConfig.apiPrefix}/manager/dashboard');

      print('🔍 Checking for new audits...');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await _processAudits(data);
      } else {
        print('⚠️  Failed to fetch audits: ${response.statusCode}');
      }
    } catch (e) {
      print('⚠️  Error checking for new audits: $e');
    }
  }

  /// Process audits and trigger notifications for new ones
  Future<void> _processAudits(Map<String, dynamic> data) async {
    try {
      final countries = data['countries'] as List<dynamic>? ?? [];
      final totalAudits = data['total_audits'] ?? 0;
      int newAuditCount = 0;

      // Check if total audit count increased
      if (_lastTotalAudits > 0 && totalAudits > _lastTotalAudits) {
        final newAuditsAdded = totalAudits - _lastTotalAudits;
        print('🆕 Detected $newAuditsAdded new audit(s)! Total: $_lastTotalAudits → $totalAudits');
      }

      // Extract all facilities from all zones in all countries
      for (var country in countries) {
        final zones = country['zones'] as List<dynamic>? ?? [];

        for (var zone in zones) {
          final facilities = zone['facilities'] as List<dynamic>? ?? [];

          for (var facility in facilities) {
            final facilityId = facility['facility_id']?.toString() ?? '';
            final facilityName = facility['facility_name']?.toString() ?? '';
            final compliancePercentage = facility['compliance_percentage'] ?? 0.0;
            final totalFacilityAudits = facility['total_audits'] ?? 0;
            final lastAuditDate = facility['last_audit_date']?.toString() ?? '';

            // Create a unique identifier using last_audit_date for better detection
            final auditKey = '${facilityId}_${lastAuditDate}';

            // Check if we've already notified about this audit
            if (!_notifiedAuditIds.contains(auditKey) && totalFacilityAudits > 0) {
              // New audit detected!
              await _showAuditNotification(
                facilityId: facilityId,
                facilityName: facilityName,
                compliancePercentage: compliancePercentage,
                totalAudits: totalFacilityAudits,
                zoneName: zone['zone_name']?.toString() ?? '',
                countryName: country['country_name']?.toString() ?? '',
                lastAuditDate: lastAuditDate,
              );

              _notifiedAuditIds.add(auditKey);
              newAuditCount++;
            }
          }
        }
      }

      // Update total audit count
      _lastTotalAudits = totalAudits;

      if (newAuditCount > 0) {
        print('✅ Sent $newAuditCount notification(s) for new audits');

        // Update last checked time
        _lastCheckedTime = DateTime.now();
        await _saveState();

        // Clean up old notified IDs (keep only last 200)
        if (_notifiedAuditIds.length > 200) {
          final list = _notifiedAuditIds.toList();
          _notifiedAuditIds = Set.from(list.sublist(list.length - 200));
          await _saveState();
        }
      } else {
        print('📭 No new audits detected');
      }
    } catch (e) {
      print('❌ Error processing audits: $e');
    }
  }

  /// Show notification for new audit
  Future<void> _showAuditNotification({
    required String facilityId,
    required String facilityName,
    required double compliancePercentage,
    required int totalAudits,
    required String zoneName,
    required String countryName,
    required String lastAuditDate,
  }) async {
    try {
      // Determine notification style based on compliance
      String title;
      String body;
      String emoji;

      if (compliancePercentage >= 90) {
        emoji = '✅';
        title = 'Excellent Compliance!';
      } else if (compliancePercentage >= 75) {
        emoji = '👍';
        title = 'Good Compliance';
      } else if (compliancePercentage >= 60) {
        emoji = '⚠️';
        title = 'Compliance Alert';
      } else {
        emoji = '🚨';
        title = 'Low Compliance Warning';
      }

      body = '$emoji $facilityName\n'
          '${compliancePercentage.toStringAsFixed(1)}% compliance\n'
          '$zoneName, $countryName\n'
          'Total Audits: $totalAudits';

      // Android notification details
      final androidDetails = AndroidNotificationDetails(
        'audit_updates',
        'Audit Updates',
        channelDescription: 'Notifications for new audit submissions',
        importance: compliancePercentage < 60 ? Importance.high : Importance.defaultImportance,
        priority: compliancePercentage < 60 ? Priority.high : Priority.defaultPriority,
        showWhen: true,
        enableVibration: true,
        playSound: true,
        icon: '@mipmap/ic_launcher',
      );

      // iOS notification details
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Create payload with facility info
      final payload = json.encode({
        'facility_id': facilityId,
        'facility_name': facilityName,
        'compliance': compliancePercentage,
        'zone': zoneName,
        'country': countryName,
      });

      // Show notification
      await _notifications.show(
        facilityId.hashCode,
        title,
        body,
        details,
        payload: payload,
      );

      print('🔔 Notification shown: $title - $facilityName ($compliancePercentage%)');
    } catch (e) {
      print('❌ Error showing notification: $e');
    }
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      try {
        final data = json.decode(response.payload!);
        print('👆 Notification tapped: ${data['facility_name']}');

        // TODO: Navigate to facility detail screen
        // You can use a navigation service or event bus here
        // For example:
        // NavigationService.navigateToFacility(data['facility_id']);
      } catch (e) {
        print('⚠️  Error handling notification tap: $e');
      }
    }
  }

  /// Request notification permissions (iOS)
  Future<bool> requestPermissions() async {
    try {
      final result = await _notifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );

      return result ?? true; // Android always returns true
    } catch (e) {
      print('⚠️  Error requesting permissions: $e');
      return false;
    }
  }

  /// Check if currently polling
  bool get isPolling => _isPolling;

  /// Get last checked time
  DateTime? get lastCheckedTime => _lastCheckedTime;

  /// Clear all notifications
  Future<void> clearAllNotifications() async {
    await _notifications.cancelAll();
    print('🗑️  All notifications cleared');
  }

  /// Reset notification history
  Future<void> resetNotificationHistory() async {
    _notifiedAuditIds.clear();
    _lastTotalAudits = 0;
    _lastCheckedTime = DateTime.now();
    await _saveState();
    print('🔄 Notification history reset');
  }

  /// Send a test notification (for debugging)
  Future<void> sendTestNotification() async {
    try {
      await _showAuditNotification(
        facilityId: 'TEST_FACILITY',
        facilityName: 'Test Dealer',
        compliancePercentage: 85.5,
        totalAudits: 1,
        zoneName: 'Test Zone',
        countryName: 'Test Country',
        lastAuditDate: DateTime.now().toIso8601String(),
      );
      print('✅ Test notification sent');
    } catch (e) {
      print('❌ Error sending test notification: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    stopPolling();
    print('🗑️  Notification service disposed');
  }
}





