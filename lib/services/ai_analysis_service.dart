// ============================================================================
// FILE: ai_analysis_service.dart
// DESCRIPTION: Service for AI image analysis using the backend Vision API
// ============================================================================
// PROJECT: Stellantis Dealer Hygiene App
// AUTHOR: AI Assistant
// VERSION: 1.0.0
// ============================================================================
// COPYRIGHT: © 2026 STELLANTIS N.V. - INTERNAL USE ONLY
// ============================================================================

import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../config/api_config.dart';
import 'auth_service.dart';

/// Result of AI image analysis
class AIAnalysisResult {
  final String auditId;
  final String dealerId;
  final String checkpointId;
  final CleanlinessStatus status;
  final double confidence;
  final String reason;
  final List<DetectedIssue> negativeLabels;
  final String? imageUrl;
  final DateTime analyzedAt;

  /// Optional backend-provided summary metrics.
  /// Example keys: confidence_mean, confidence_median, confidence_std_dev,
  /// negative_labels_count, risk_score, total_labels_detected.
  final Map<String, num>? mathematics;

  AIAnalysisResult({
    required this.auditId,
    required this.dealerId,
    required this.checkpointId,
    required this.status,
    required this.confidence,
    required this.reason,
    required this.negativeLabels,
    this.imageUrl,
    required this.analyzedAt,
    this.mathematics,
  });

  factory AIAnalysisResult.fromJson(Map<String, dynamic> json) {
    Map<String, num>? math;
    final rawMath = json['mathematics'];
    if (rawMath is Map) {
      math = rawMath.map<String, num>((k, v) {
        final key = k.toString();
        if (v is num) return MapEntry(key, v);
        if (v is String) {
          final parsed = num.tryParse(v);
          return MapEntry(key, parsed ?? 0);
        }
        return MapEntry(key, 0);
      });
    }

    return AIAnalysisResult(
      auditId: json['audit_id'],
      dealerId: json['dealer_id'],
      checkpointId: json['checkpoint_id'],
      status: _parseStatus(json['status']),
      confidence: json['confidence'].toDouble(),
      reason: json['reason'],
      negativeLabels: (json['negative_labels'] as List)
          .map((label) => DetectedIssue.fromJson(label))
          .toList(),
      imageUrl: json['image_url'],
      analyzedAt: DateTime.parse(json['analyzed_at']),
      mathematics: math,
    );
  }

  static CleanlinessStatus _parseStatus(String status) {
    switch (status.toUpperCase()) {
      case 'CLEAN':
        return CleanlinessStatus.clean;
      case 'NOT_CLEAN':
        return CleanlinessStatus.dirty;
      case 'REQUIRES_MANUAL_REVIEW':
        return CleanlinessStatus.requiresReview;
      default:
        return CleanlinessStatus.insufficientData;
    }
  }

  /// Get status display text
  String get statusText {
    switch (status) {
      case CleanlinessStatus.clean:
        return 'CLEAN';
      case CleanlinessStatus.dirty:
        return 'DIRTY';
      case CleanlinessStatus.requiresReview:
        return 'NEEDS REVIEW';
      case CleanlinessStatus.insufficientData:
        return 'INSUFFICIENT DATA';
    }
  }

  /// Get recommended actions based on detected issues
  List<String> get recommendedActions {
    if (status == CleanlinessStatus.clean) {
      return ['No action required', 'Maintain current cleaning standards'];
    }

    List<String> actions = [];
    for (var issue in negativeLabels) {
      actions.addAll(issue.getRecommendedActions());
    }

    if (actions.isEmpty) {
      actions = [
        'Inspect area manually',
        'Apply appropriate cleaning measures',
      ];
    }

    return actions.take(3).toList(); // Limit to top 3 actions
  }
}

/// Detected cleanliness issue
class DetectedIssue {
  final String name;
  final double confidence;

  DetectedIssue({required this.name, required this.confidence});

  factory DetectedIssue.fromJson(Map<String, dynamic> json) {
    return DetectedIssue(
      name: json['name'],
      confidence: json['confidence'].toDouble(),
    );
  }

  /// Get recommended actions for this specific issue
  List<String> getRecommendedActions() {
    String lowerName = name.toLowerCase();

    if (lowerName.contains('fingerprint') || lowerName.contains('smudge')) {
      return [
        'Use microfiber cloth and glass cleaner',
        'Wipe down the surface thoroughly',
      ];
    } else if (lowerName.contains('dust') || lowerName.contains('dirt')) {
      return [
        'Clean with appropriate cleaning solution',
        'Use damp cloth for thorough cleaning',
      ];
    } else if (lowerName.contains('stain') || lowerName.contains('spill')) {
      return ['Apply stain remover if needed', 'Clean and disinfect the area'];
    } else if (lowerName.contains('trash') || lowerName.contains('debris')) {
      return ['Remove all trash and debris', 'Empty waste containers'];
    }

    return ['Apply general cleaning measures', 'Inspect area thoroughly'];
  }
}

/// Cleanliness status enum
enum CleanlinessStatus { clean, dirty, requiresReview, insufficientData }

/// Service for AI image analysis
class AIAnalysisService {
  static final AIAnalysisService _instance = AIAnalysisService._internal();
  factory AIAnalysisService() => _instance;
  AIAnalysisService._internal();

  final AuthService _authService = AuthService();

  /// Analyze image for cleanliness
  ///
  /// Uploads image to backend Vision API for analysis
  /// Returns AIAnalysisResult with detected status and recommendations
  Future<AIAnalysisResult> analyzeImage({
    required Uint8List imageBytes,
    required String dealerId,
    required String checkpointId,
    double minConfidence = 70.0,
  }) async {
    // Retry logic for network issues
    int maxRetries = 3;
    int retryCount = 0;
    
    while (retryCount < maxRetries) {
      try {
        final baseUrl = await ApiConfig.getBaseUrl();
        final url = Uri.parse('$baseUrl${ApiConfig.apiPrefix}/hygiene/analyze');

        print('🤖 Analyzing image with AI backend (attempt ${retryCount + 1}/$maxRetries): $url');
        print(
          '📊 Parameters: dealer=$dealerId, checkpoint=$checkpointId, minConfidence=$minConfidence',
        );

        // Create HTTP client with custom settings
        final client = http.Client();
        
        try {
          // Create multipart request
          var request = http.MultipartRequest('POST', url);

          // Add comprehensive headers for better compatibility
          final headers = {
            'Accept': 'application/json',
            'Connection': 'keep-alive',
            'Accept-Encoding': 'gzip, deflate',
          };
          
          // Add authentication token if available
          final authToken = _authService.authToken;
          if (authToken != null && authToken.isNotEmpty) {
            headers['Authorization'] = 'Bearer $authToken';
            print('🔐 Including auth token in request');
          } else {
            print('⚠️  No auth token available - request may fail');
          }
          
          request.headers.addAll(headers);

          // Add form fields
          request.fields['dealer_id'] = dealerId;
          request.fields['checkpoint_id'] = checkpointId;
          request.fields['min_confidence'] = minConfidence.toString();

          // Add image file
          request.files.add(
            http.MultipartFile.fromBytes(
              'image',
              imageBytes,
              filename: 'audit_image.jpg',
              contentType: MediaType('image', 'jpeg'),
            ),
          );

          print('📤 Sending request with image size: ${imageBytes.length} bytes');

          // Send request with timeout
          final streamedResponse = await client.send(request).timeout(
            const Duration(seconds: 90), // Increased timeout for AI processing
            onTimeout: () {
              throw Exception('Request timeout after 90 seconds - Server may be slow');
            },
          );

          // Parse response
          final response = await http.Response.fromStream(streamedResponse).timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('Response parsing timeout - Server may be processing');
            },
          );

          print('🔍 AI Analysis Response Status: ${response.statusCode}');
          print('📦 Raw Response Body: ${response.body}');

          if (response.statusCode == 201 || response.statusCode == 200) {
            print('✅ AI Analysis succeeded');
            final responseData = json.decode(response.body);
            print('📊 Parsed Response Data: $responseData');
            print('   - Status: ${responseData['status']}');
            print('   - Confidence: ${responseData['confidence']}');
            print('   - Reason: ${responseData['reason']}');
            print('   - Negative Labels: ${responseData['negative_labels']}');
            return AIAnalysisResult.fromJson(responseData);
          } else if (response.statusCode == 401) {
            throw Exception('Authentication failed - Please login again');
          } else if (response.statusCode == 422) {
            throw Exception('Invalid request data - ${response.body}');
          } else if (response.statusCode >= 500) {
            // Server error - retry
            throw Exception('Server error: ${response.statusCode}');
          } else {
            print('❌ AI Analysis failed: ${response.body}');
            throw Exception(
              'AI analysis failed: ${response.statusCode} - ${response.body}',
            );
          }
        } finally {
          client.close();
        }
      } catch (e) {
        retryCount++;
        print('❌ AI Analysis error (attempt $retryCount/$maxRetries): $e');
        
        // If this was the last retry, rethrow the error
        if (retryCount >= maxRetries) {
          if (e.toString().contains('ClientException') || 
              e.toString().contains('connection abort') ||
              e.toString().contains('SocketException')) {
            throw Exception(
              'Network error: Cannot connect to server. Please check:\n'
              '1. Server is running at http://52.90.100.90:8000\n'
              '2. Your internet connection\n'
              '3. Firewall settings\n\n'
              'Original error: $e'
            );
          }
          rethrow;
        }
        
        // Wait before retrying (exponential backoff)
        await Future.delayed(Duration(seconds: retryCount * 2));
        print('🔄 Retrying request...');
      }
    }
    
    throw Exception('Failed after $maxRetries attempts');
  }

  /// Get audit result by ID
  Future<AIAnalysisResult> getAuditById(String auditId) async {
    try {
      final baseUrl = await ApiConfig.getBaseUrl();
      final url =
          Uri.parse('$baseUrl${ApiConfig.apiPrefix}/hygiene/audits/$auditId');

      print('🔍 Fetching audit result: $auditId');

      final response = await http.get(
        url,
        headers: {'Accept': 'application/json'},
      ).timeout(
        const Duration(seconds: 30),
      );

      if (response.statusCode == 200) {
        print('✅ Audit result fetched successfully');
        final responseData = json.decode(response.body);
        return AIAnalysisResult.fromJson(responseData);
      } else {
        throw Exception(
          'Failed to fetch audit: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('❌ Fetch audit error: $e');
      rethrow;
    }
  }

  /// Apply manual override to audit result
  Future<AIAnalysisResult> applyManualOverride({
    required String auditId,
    required bool isClean,
    required String reviewerNotes,
  }) async {
    try {
      final baseUrl = await ApiConfig.getBaseUrl();
      final url = Uri.parse(
          '$baseUrl${ApiConfig.apiPrefix}/hygiene/audits/$auditId/override');

      print('🔧 Applying manual override to audit: $auditId');

      final response = await http
          .post(
            url,
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: json.encode({
              'audit_id': auditId,
              'is_clean': isClean,
              'reviewer_notes': reviewerNotes,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        print('✅ Manual override applied successfully');
        final responseData = json.decode(response.body);
        return AIAnalysisResult.fromJson(responseData);
      } else {
        throw Exception(
          'Failed to apply override: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('❌ Manual override error: $e');
      rethrow;
    }
  }

  /// Get dealer statistics
  Future<Map<String, dynamic>> getDealerStats(String dealerId) async {
    try {
      final baseUrl = await ApiConfig.getBaseUrl();
      final url = Uri.parse(
          '$baseUrl${ApiConfig.apiPrefix}/hygiene/dealers/$dealerId/stats');

      print('📊 Fetching dealer stats: $dealerId');

      final response = await http.get(
        url,
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        print('✅ Dealer stats fetched successfully');
        return json.decode(response.body);
      } else {
        throw Exception(
          'Failed to fetch stats: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('❌ Fetch stats error: $e');
      rethrow;
    }
  }
}

/*
 * ========================================================================
 * End of ai_analysis_service.dart
 * Author: AI Assistant
 * ========================================================================
 */
