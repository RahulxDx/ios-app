// ============================================================================
// FILE: api_config.dart
// DESCRIPTION: API configuration with automatic local/remote detection
// ============================================================================
// PROJECT: Stellantis Dealer Hygiene App
// AUTHOR: AI Assistant
// WEBSITE: https://www.stellantis.com/
// VERSION: 1.0.0
// ============================================================================
// COPYRIGHT: © 2026 STELLANTIS N.V. - INTERNAL USE ONLY
// ============================================================================

/// API Configuration for Stellantis Hygiene Backend
///
/// Production backend running on EC2: http://52.90.100.90:8000
/// This app is configured to ALWAYS use the production EC2 backend
class ApiConfig {
  // Private constructor to prevent instantiation
  ApiConfig._();

  // === Production EC2 Backend URL ===

  /// EC2 Production URL (Always used)
  static const String _productionUrl = 'http://52.90.100.90:8000';


  // === API version prefix ===
  static const String apiPrefix = '/api/v1';

  // === Base URL Configuration ===

  /// Always returns production EC2 backend URL
  /// This app is configured to ALWAYS use the production backend
  static Future<String> getBaseUrl() async {
    // ALWAYS USE EC2 PRODUCTION URL
    print('🚀 Using PRODUCTION EC2 backend: $_productionUrl');
    return _productionUrl;
  }

  /// Synchronous version of getBaseUrl for immediate access
  static String get baseUrl => _productionUrl;


  /// Get complete API base URL with prefix
  static Future<String> getApiBaseUrl() async {
    final baseUrl = await getBaseUrl();
    return '$baseUrl$apiPrefix';
  }

  // === API Endpoints (dynamic) ===

  static Future<String> get signupEndpoint async => '${await getApiBaseUrl()}/auth/signup';
  static Future<String> get signinEndpoint async => '${await getApiBaseUrl()}/auth/signin';
  static Future<String> get analyzeHygieneEndpoint async => '${await getApiBaseUrl()}/vision/analyze/gemini';

  static Future<String> auditByIdEndpoint(String auditId) async =>
      '${await getApiBaseUrl()}/hygiene/audits/$auditId';

  static Future<String> overrideAuditEndpoint(String auditId) async =>
      '${await getApiBaseUrl()}/hygiene/audits/$auditId/override';

  static Future<String> dealerStatsEndpoint(String dealerId) async =>
      '${await getApiBaseUrl()}/hygiene/dealers/$dealerId/stats';

  // === Timeout Configuration ===
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 60);
  static const Duration sendTimeout = Duration(seconds: 60);

  // === Request Headers ===
  static Map<String, String> get defaultHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  static Map<String, String> authHeaders(String token) => {
        ...defaultHeaders,
        'Authorization': 'Bearer $token',
      };

  // === File Upload Configuration ===
  static const int maxImageSizeBytes = 15 * 1024 * 1024; // 15MB
  static const List<String> allowedImageTypes = ['image/jpeg', 'image/png'];

  // === Retry Configuration ===
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);

  // === Debug Mode ===
  static const bool debugMode = bool.fromEnvironment('DEBUG', defaultValue: true);
}

// ============================================================================
// END OF FILE: api_config.dart
// ============================================================================


