// ============================================================================
// FILE: camera_ai_service.dart
// DESCRIPTION: Service for capturing images and performing AI analysis
// ============================================================================
// PROJECT: Stellantis Dealer Hygiene App
// AUTHOR: Srikanth Thiygarajan
// VERSION: 1.0.0
// ============================================================================
// COPYRIGHT: © 2026 STELLANTIS N.V. - INTERNAL USE ONLY
// ============================================================================

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'ai_analysis_service.dart';
import '../screens/ai_audit_analysis_page.dart';

/// Service for camera integration and AI analysis
class CameraAIService {
  static final CameraAIService _instance = CameraAIService._internal();
  factory CameraAIService() => _instance;
  CameraAIService._internal();

  final ImagePicker _picker = ImagePicker();
  final AIAnalysisService _aiService = AIAnalysisService();

  /// Capture image from camera and analyze
  Future<AIAnalysisResult?> captureAndAnalyze({
    required String dealerId,
    required String checkpointId,
    required BuildContext context,
    double minConfidence = 70.0,
  }) async {
    try {
      // Show image source selection
      final ImageSource? source = await _showImageSourceDialog(context);
      if (source == null) return null;

      // Capture image
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image == null) return null;

      // Convert to bytes
      final Uint8List imageBytes = await image.readAsBytes();

      // Show loading dialog
      if (context.mounted) {
        _showAnalyzingDialog(context);
      }

      // Perform AI analysis
      final result = await _aiService.analyzeImage(
        imageBytes: imageBytes,
        dealerId: dealerId,
        checkpointId: checkpointId,
        minConfidence: minConfidence,
      );

      // Close loading dialog
      if (context.mounted) {
        Navigator.pop(context);
      }

      return result;
    } catch (e) {
      // Close loading dialog if open
      if (context.mounted) {
        Navigator.pop(context);
        _showErrorDialog(context, e.toString());
      }
      return null;
    }
  }

  /// Show image source selection dialog
  Future<ImageSource?> _showImageSourceDialog(BuildContext context) async {
    return await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }

  /// Show analyzing dialog
  void _showAnalyzingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text('Analyzing image with AI...'),
            const SizedBox(height: 8),
            Text(
              'This may take a few moments',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Show error dialog
  void _showErrorDialog(BuildContext context, String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Analysis Failed'),
        content: Text(error),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Navigate to AI Analysis Results page
  void navigateToResults({
    required BuildContext context,
    required AIAnalysisResult result,
    required Uint8List imageBytes,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AIAuditAnalysisPage(
          analysisResult: result,
          capturedImage: imageBytes,
        ),
      ),
    );
  }

  /// Capture, analyze, and navigate to results (all-in-one)
  Future<void> captureAnalyzeAndShow({
    required String dealerId,
    required String checkpointId,
    required BuildContext context,
    double minConfidence = 70.0,
  }) async {
    final result = await captureAndAnalyze(
      dealerId: dealerId,
      checkpointId: checkpointId,
      context: context,
      minConfidence: minConfidence,
    );

    if (result != null && context.mounted) {
      // Navigate to results page
      // Note: The image bytes would need to be captured separately
      // This is a simplified version
      _showSuccessDialog(context, result);
    }
  }

  /// Show success dialog with result summary
  void _showSuccessDialog(BuildContext context, AIAnalysisResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          result.statusText,
          style: TextStyle(
            color: result.status == CleanlinessStatus.clean
                ? Colors.green
                : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Confidence: ${result.confidence.toStringAsFixed(1)}%'),
            const SizedBox(height: 8),
            Text(result.reason),
            if (result.negativeLabels.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Issues Detected:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...result.negativeLabels.map(
                (issue) => Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text('• ${issue.name}'),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

/*
 * ========================================================================
 * End of camera_ai_service.dart
 * Author: AI Assistant
 * ========================================================================
 */

