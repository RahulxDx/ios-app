// ============================================================================
// FILE: manual_audit_service.dart
// DESCRIPTION: Service for handling manual audit API communication
// ============================================================================
// PROJECT: Stellantis Dealer Hygiene App
// AUTHOR: AI Assistant
// WEBSITE: https://www.stellantis.com/
// VERSION: 1.0.0
// ============================================================================
// COPYRIGHT: © 2026 STELLANTIS N.V. - INTERNAL USE ONLY
// ============================================================================

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/manual_audit_model.dart';
import '../config/api_config.dart';

/// Service for Manual Audit operations
///
/// Handles:
/// - Manual audit submission to backend
/// - API communication
/// - Error handling
class ManualAuditService {
  // Singleton pattern
  static final ManualAuditService _instance = ManualAuditService._internal();
  factory ManualAuditService() => _instance;
  ManualAuditService._internal();

  /// Submit manual audit to backend
  ///
  /// Sends audit data to FastAPI endpoint
  /// Returns true if successful, throws exception on error
  Future<Map<String, dynamic>> submitManualAudit(ManualAuditModel audit) async {
    try {
      // Get base URL (will use localhost for development)
      final baseUrl = await ApiConfig.getBaseUrl();
      final url = Uri.parse('$baseUrl${ApiConfig.apiPrefix}/manual-audit');

      print('🚀 Submitting manual audit to: $url');
      print('📦 Audit data: ${json.encode(audit.toJson())}');

      // Make POST request
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(audit.toJson()),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout - Please check if backend is running');
        },
      );

      print('📡 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        print('✅ Manual audit submitted successfully');
        return responseData;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['detail'] ?? 'Failed to submit audit');
      }
    } catch (e) {
      print('❌ Error submitting manual audit: $e');
      rethrow;
    }
  }

  /// Test backend connectivity
  ///
  /// Checks if backend is available
  Future<bool> testConnection() async {
    try {
      final baseUrl = await ApiConfig.getBaseUrl();
      final url = Uri.parse('$baseUrl/health');

      final response = await http.get(url).timeout(
        const Duration(seconds: 5),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Backend not available: $e');
      return false;
    }
  }
}

