// ============================================================================
// FILE: ai_audit_analysis_page.dart
// DESCRIPTION: AI-powered audit analysis screen with integrated camera functionality
// ============================================================================
// PROJECT: Stellantis Dealer Hygiene App
// AUTHOR: Rohith U
// WEBSITE: https://www.stellantis.com/
// VERSION: 2.0.0 (Updated with camera integration)
// ============================================================================
// COPYRIGHT: © 2026 STELLANTIS N.V. - INTERNAL USE ONLY
// ============================================================================

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/stellantis_colors.dart';
import '../services/ai_analysis_service.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../widgets/ai_metrics_card.dart';

/// Screen widget that handles camera capture and AI analysis workflow.
///
/// Features:
/// - Camera capture with live preview
/// - Image selection from gallery
/// - AI analysis with backend API
/// - Real-time results display with confidence scoring
/// - Recommended actions based on analysis
///
/// Complete workflow: Camera → Capture → API → Analysis → Results
class AIAuditAnalysisPage extends StatefulWidget {
  final String? dealerId;
  final String? checkpointId;
  final AIAnalysisResult? analysisResult;
  final Uint8List? capturedImage;

  const AIAuditAnalysisPage({
    super.key,
    this.dealerId,
    this.checkpointId,
    this.analysisResult,
    this.capturedImage,
  });

  @override
  State<AIAuditAnalysisPage> createState() => _AIAuditAnalysisPageState();
}

class _AIAuditAnalysisPageState extends State<AIAuditAnalysisPage> {
  final AIAnalysisService _aiAnalysisService = AIAnalysisService();
  final StorageService _storageService = StorageService();
  final ImagePicker _picker = ImagePicker();

  // State variables
  AIAnalysisResult? _analysisResult;
  Uint8List? _capturedImageBytes;
  bool _isAnalyzing = false;
  bool _hasCapture = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Initialize with provided data if available
    if (widget.analysisResult != null) {
      _analysisResult = widget.analysisResult;
      _capturedImageBytes = widget.capturedImage;
      _hasCapture = true;
    }
  }

  /// Capture image from camera
  Future<void> _captureFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image == null) return;

      final bytes = await image.readAsBytes();
      setState(() {
        _capturedImageBytes = bytes;
        _hasCapture = true;
        _errorMessage = null;
      });

      // Auto-analyze after capture
      await _analyzeImage();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to capture image: $e';
      });
    }
  }

  /// Select image from gallery
  Future<void> _selectFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image == null) return;

      final bytes = await image.readAsBytes();
      setState(() {
        _capturedImageBytes = bytes;
        _hasCapture = true;
        _errorMessage = null;
      });

      // Auto-analyze after selection
      await _analyzeImage();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to select image: $e';
      });
    }
  }

  /// Analyze captured image with AI
  Future<void> _analyzeImage() async {
    if (_capturedImageBytes == null) {
      setState(() {
        _errorMessage = 'No image to analyze';
      });
      return;
    }

    // Get dealer ID from widget params or current user
    String? dealerId = widget.dealerId;
    String? checkpointId = widget.checkpointId;

    if (dealerId == null || checkpointId == null) {
      final authService = AuthService();
      final currentUser = authService.currentUser;
      dealerId ??= currentUser?.facilityId ?? currentUser?.id;
      checkpointId ??= 'QUICK_SCAN_${DateTime.now().millisecondsSinceEpoch}';

      if (dealerId == null) {
        setState(() {
          _errorMessage = 'Unable to identify dealer. Please log in again.';
        });
        return;
      }
    }

    setState(() {
      _isAnalyzing = true;
      _errorMessage = null;
      _analysisResult = null;
    });

    try {
      final result = await _aiAnalysisService.analyzeImage(
        imageBytes: _capturedImageBytes!,
        dealerId: dealerId!,
        checkpointId: checkpointId!,
        minConfidence: 70.0,
      );

      // Debug logging to verify backend response
      print('✅ BACKEND RESPONSE:');
      print('   Status: ${result.status} (${result.statusText})');
      print('   Confidence: ${result.confidence}%');
      print('   Reason: ${result.reason}');
      print('   Negative Labels: ${result.negativeLabels.length}');
      for (var label in result.negativeLabels) {
        print('      - ${label.name} (${label.confidence}%)');
      }

      setState(() {
        _analysisResult = result;
        _isAnalyzing = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'AI analysis failed: $e';
        _isAnalyzing = false;
      });
    }
  }

  /// Reset capture to take new photo
  void _resetCapture() {
    setState(() {
      _capturedImageBytes = null;
      _analysisResult = null;
      _hasCapture = false;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'AI Audit Analysis',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Theme.of(context).colorScheme.primary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_hasCapture && !_isAnalyzing)
            IconButton(
              icon: Icon(
                Icons.refresh,
                color: Theme.of(context).colorScheme.primary,
              ),
              onPressed: _resetCapture,
              tooltip: 'Take New Photo',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Camera/Image capture section
            _buildCameraSection(),
            const SizedBox(height: 24),

            // Analysis results or capture prompt
            if (_isAnalyzing)
              _buildAnalyzingCard()
            else if (_errorMessage != null)
              _buildErrorCard()
            else if (_analysisResult != null) ...[
              _buildStatusCard(),
              const SizedBox(height: 24),
              _buildRecommendedActionsCard(),
              const SizedBox(height: 24),
              _buildProceedButton(),
            ] else if (!_hasCapture)
              _buildCapturePromptCard(),
          ],
        ),
      ),
    );
  }

  /// Build camera section with capture buttons or captured image
  Widget _buildCameraSection() {
    // Determine background color based on analysis result
    Color backgroundColor;
    Color borderColor;

    if (_analysisResult != null) {
      // Show color based on actual backend result
      if (_analysisResult!.status == CleanlinessStatus.clean) {
        backgroundColor = StellantisColors.success.withValues(alpha: 0.15);
        borderColor = StellantisColors.success;
      } else if (_analysisResult!.status == CleanlinessStatus.dirty) {
        backgroundColor = StellantisColors.red.withValues(alpha: 0.15);
        borderColor = StellantisColors.red;
      } else {
        backgroundColor = Theme.of(context).cardTheme.color ?? Colors.white;
        borderColor = Theme.of(context).dividerColor;
      }
    } else {
      backgroundColor = Theme.of(context).cardTheme.color ?? Colors.white;
      borderColor = Theme.of(context).dividerColor;
    }

    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Show captured image if available
          if (_capturedImageBytes != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Image.memory(
                _capturedImageBytes!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            )
          else
            // Camera placeholder
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.camera_alt_outlined,
                    size: 80,
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.6),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tap to capture image',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Camera or Gallery',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

          // Detection zone badge (if analyzing or analyzed)
          if (_hasCapture)
            Positioned(
              top: 20,
              left: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _analysisResult != null
                      ? (_analysisResult!.status == CleanlinessStatus.clean
                            ? StellantisColors.success
                            : _analysisResult!.status == CleanlinessStatus.dirty
                            ? StellantisColors.red
                            : StellantisColors.stellantisBlue)
                      : StellantisColors.stellantisBlue,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_analysisResult != null) ...[
                      Icon(
                        _analysisResult!.status == CleanlinessStatus.clean
                            ? Icons.check_circle
                            : _analysisResult!.status == CleanlinessStatus.dirty
                            ? Icons.cancel
                            : Icons.info,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      _analysisResult != null
                          ? _analysisResult!.statusText
                          : 'DETECTION ZONE',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Camera + Gallery buttons
          if (!_hasCapture && !_isAnalyzing)
            Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 120),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildCaptureButton(
                        icon: Icons.camera_alt,
                        label: 'Camera',
                        onTap: _captureFromCamera,
                      ),
                      const SizedBox(width: 16),
                      _buildCaptureButton(
                        icon: Icons.photo_library,
                        label: 'Gallery',
                        onTap: _selectFromGallery,
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCaptureButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: StellantisColors.stellantisBlue,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: StellantisColors.stellantisBlue.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCapturePromptCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        children: [
          Icon(
            Icons.info_outline,
            size: 48,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'No Image Captured',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Capture or select an image to start AI analysis',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyzingCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Analyzing with AI...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This may take a few moments',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: StellantisColors.red.withValues(alpha: 0.6)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: StellantisColors.red, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Analysis Failed',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _errorMessage ?? 'Unknown error',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    if (_analysisResult == null) return const SizedBox.shrink();

    final result = _analysisResult!;
    final isClean = result.status == CleanlinessStatus.clean;

    return AiMetricsCard(
      title: 'AI Analysis',
      statusLabel: 'STATUS',
      statusValue: result.statusText,
      statusColor: isClean ? StellantisColors.success : StellantisColors.red,
      confidencePercent: result.confidence,
      mathematics: result.mathematics,
      diagnosisLabel: 'DIAGNOSIS',
      diagnosisText: result.reason,
      issues: result.negativeLabels
          .map(
            (issue) =>
                '${issue.name} (${issue.confidence.toStringAsFixed(0)}%)',
          )
          .toList(),
    );
  }

  Widget _buildRecommendedActionsCard() {
    if (_analysisResult == null) return const SizedBox.shrink();

    final actions = _analysisResult!.recommendedActions;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.info_outline,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recommended Actions',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 12),
                ...actions.map(
                  (action) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '• ',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            action,
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.color,
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProceedButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () async {
          // Save to history before proceeding
          if (_analysisResult != null) {
            await _storageService.addAuditToHistory({
              'type': 'AI Analysis',
              'checkpoint': widget.checkpointId ?? 'Quick Scan',
              'date': DateTime.now().toIso8601String(),
              'status': _analysisResult!.statusText,
              'score': _analysisResult!.confidence,
              'details': _analysisResult!.reason,
            });
          }
          if (!context.mounted) return;
          // Return result to calling screen
          Navigator.pop(context, _analysisResult);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: StellantisColors.stellantisBlue,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Proceed',
              style: TextStyle(
                color: StellantisColors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward, color: StellantisColors.white, size: 20),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// END OF FILE: ai_audit_analysis_page.dart
// ============================================================================
// AUTHOR: Rohith U
// WEBSITE: https://www.stellantis.com/
// ============================================================================
