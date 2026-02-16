// ============================================================================
// FILE: checkpoint_detail_screen.dart
// DESCRIPTION: Detailed checkpoint inspection screen with AI photo analysis
//              and manual compliance declaration capabilities.
// ============================================================================
// PROJECT: Stellantis Dealer Hygiene App
// AUTHOR: Sujan Sreenivasulu
// WEBSITE: https://www.stellantis.com/
// VERSION: 1.0.0
// ============================================================================
// COPYRIGHT: © 2026 STELLANTIS N.V. - INTERNAL USE ONLY
// ============================================================================

import 'package:flutter/material.dart';
import '../models/audit.dart';
import '../services/audit_service.dart';
import '../services/camera_service.dart';
import '../widgets/ai_metrics_card.dart';

/// Detailed checkpoint inspection screen for recording audit observations.
/// 
/// This screen provides two methods for recording checkpoint compliance:
/// 1. Photo Analysis - Capture photo and get AI-powered compliance analysis
/// 2. Manual Entry - Self-declare compliance status without photo evidence
/// 
/// Features:
/// - Dual-mode recording (AI photo analysis or manual declaration)
/// - Real-time AI analysis with confidence scoring
/// - Compliance status selection (Compliant, Partially Compliant, Non-Compliant)
/// - Optional notes/comments for each checkpoint
/// - Visual feedback with color-coded compliance indicators
/// - Progress saving and navigation
/// 
/// TODO: Integrate with actual camera API for photo capture
/// TODO: Connect to backend AI service for real image analysis
/// TODO: Add photo preview and retake functionality
/// TODO: Implement offline photo queue for later processing
/// TODO: Add voice-to-text for notes input
class CheckpointDetailScreen extends StatefulWidget {
  final Checkpoint checkpoint;
  final int checkpointNumber;

  const CheckpointDetailScreen({
    super.key,
    required this.checkpoint,
    required this.checkpointNumber,
  });

  @override
  State<CheckpointDetailScreen> createState() => _CheckpointDetailScreenState();
}

class _CheckpointDetailScreenState extends State<CheckpointDetailScreen> {
  // =========================================================================
  // DESIGN SYSTEM COLORS
  // =========================================================================
  // Brand colors following Stellantis design guidelines
  static const Color primaryNavy = Color(0xFF003874);
  static const Color actionBlue = Color(0xFF003874);
  static const Color scaffoldBg = Color(0xFFF8F9FA);
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color warningOrange = Color(0xFFFF9800);
  static const Color errorRed = Color(0xFFF44336);

  // =========================================================================
  // STATE VARIABLES
  // =========================================================================
  ComplianceLevel? _selectedCompliance;  // Selected compliance status
  final _notesController = TextEditingController();  // Notes input controller
  bool _isPhotoMode = true;  // Toggle between photo/manual mode
  bool _photoTaken = false;  // Photo capture status
  bool _isAnalyzing = false;  // AI analysis in progress flag
  AIAnalysisResult? _aiAnalysis;  // AI analysis results
  String? _photoPath;  // Path to captured photo

  // Service instances
  final AuditService _auditService = AuditService();
  final CameraService _cameraService = CameraService();

  @override
  void initState() {
    super.initState();
    _selectedCompliance = widget.checkpoint.complianceLevel;
    _notesController.text = widget.checkpoint.notes ?? '';
    _photoTaken = widget.checkpoint.evidence?.photoPath != null;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  /// Builds the checkpoint detail screen UI.
  /// 
  /// Creates a scrollable screen with:
  /// - App bar with close button and checkpoint number
  /// - Checkpoint information section
  /// - Mode selector (Photo vs Manual)
  /// - Photo capture or manual entry section
  /// - Compliance status selector
  /// - Additional notes input
  /// - Save & Continue button
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBg,
      // ===============================================================
      // APP BAR
      // ===============================================================
      // Close button and checkpoint identifier
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: primaryNavy),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Checkpoint ${widget.checkpointNumber}',
          style: const TextStyle(
            color: primaryNavy,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Colors.grey.shade200,
          ),
        ),
      ),
      // ===============================================================
      // BODY - SCROLLABLE CONTENT
      // ===============================================================
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Checkpoint title and description
            _buildCheckpointInfo(),
            
            // Photo vs Manual mode selector
            _buildModeSelector(),
            
            // Conditional rendering based on selected mode
            if (_isPhotoMode) _buildPhotoSection() else _buildManualSection(),
            
            // Compliance status selection
            if (_selectedCompliance != null) _buildComplianceSelector(),
            
            // Optional notes input
            _buildNotesSection(),
            
            // Bottom padding for scrolling
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  /// Builds the checkpoint information header section.
  /// 
  /// Displays the checkpoint title and detailed description to help
  /// auditors understand what needs to be inspected.
  /// 
  /// Returns: Container with title and description text
  Widget _buildCheckpointInfo() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.checkpoint.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: primaryNavy,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.checkpoint.description,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the recording mode selector toggle.
  /// 
  /// Allows users to switch between:
  /// - Photo Analysis: AI-powered photo inspection
  /// - Manual Entry: Self-declared compliance status
  /// 
  /// Returns: Card with two-option toggle selector
  /// 
  /// TODO: Add haptic feedback on mode change
  Widget _buildModeSelector() {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Select Recording Method',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _buildModeButton(
                  icon: Icons.camera_alt,
                  label: 'Photo Analysis',
                  subtitle: 'AI-powered',
                  isSelected: _isPhotoMode,
                  onTap: () => setState(() => _isPhotoMode = true),
                ),
              ),
              Container(width: 1, height: 80, color: Colors.grey.shade200),
              Expanded(
                child: _buildModeButton(
                  icon: Icons.edit_note,
                  label: 'Manual Entry',
                  subtitle: 'Self-declare',
                  isSelected: !_isPhotoMode,
                  onTap: () => setState(() => _isPhotoMode = false),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds a single mode selection button.
  /// 
  /// Creates a styled button for mode selection with icon, label,
  /// and subtitle. Visual state changes when selected.
  /// 
  /// Parameters:
  /// - [icon]: Icon to display
  /// - [label]: Primary button text
  /// - [subtitle]: Descriptive text below label
  /// - [isSelected]: Whether this mode is currently active
  /// - [onTap]: Callback when button is tapped
  Widget _buildModeButton({
    required IconData icon,
    required String label,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        color: isSelected ? actionBlue.withValues(alpha: 0.05) : Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? actionBlue : Colors.grey.shade400,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? actionBlue : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: isSelected ? actionBlue.withValues(alpha: 0.7) : Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the photo capture and AI analysis section.
  /// 
  /// Handles:
  /// - Photo capture UI
  /// - AI analysis loading state
  /// - Analysis results display
  /// - Photo retake functionality
  /// 
  /// Returns: Card with photo preview and capture/analysis controls
  /// 
  /// TODO: Integrate real camera API
  /// TODO: Add photo preview with zoom functionality
  Widget _buildPhotoSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 280,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: _photoTaken
                ? Stack(
                    children: [
                      Center(
                        child: Icon(
                          Icons.check_circle,
                          size: 64,
                          color: successGreen,
                        ),
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: IconButton(
                          onPressed: () => setState(() => _photoTaken = false),
                          icon: const Icon(Icons.refresh, color: primaryNavy),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.camera_alt_outlined,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No photo captured',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (_isAnalyzing) ...[
                  const CircularProgressIndicator(),
                  const SizedBox(height: 12),
                  Text(
                    'Analyzing photo with AI...',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ] else if (_aiAnalysis != null) ...[
                  _buildAIAnalysisResult(),
                ] else ...[
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _takePhoto,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: actionBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.camera_alt, color: Colors.white),
                      label: const Text(
                        'Capture Photo',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Photo will be analyzed by AI to determine compliance',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the AI analysis result display.
  /// 
  /// Shows:
  /// - Suggested compliance level
  /// - Confidence score percentage
  /// - Analysis notes/reasoning
  /// - Detected issues list
  /// 
  /// Returns: Styled container with analysis results
  Widget _buildAIAnalysisResult() {
    final complianceColor = _getComplianceColor(_aiAnalysis!.suggestedCompliance);

    return AiMetricsCard(
      title: 'AI Analysis Result',
      statusLabel: 'SUGGESTED',
      statusValue: _getComplianceName(_aiAnalysis!.suggestedCompliance),
      statusColor: complianceColor,
      confidencePercent: (_aiAnalysis!.confidenceScore * 100),
      diagnosisLabel: 'NOTES',
      diagnosisText: _aiAnalysis!.analysisNotes,
      issues: _aiAnalysis!.detectedIssues,
    );
  }

  /// Builds the manual entry information section.
  /// 
  /// Displays instructions for manual compliance declaration
  /// when photo mode is not selected.
  /// 
  /// Returns: Information card for manual entry mode
  Widget _buildManualSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 20,
                color: const Color(0xFF003874),
              ),
              const SizedBox(width: 8),
              const Text(
                'Manual Declaration',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Manually declare the compliance status based on your inspection.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the compliance status selector.
  /// 
  /// Allows selection of:
  /// - Compliant: All requirements met
  /// - Partially Compliant: Minor issues present
  /// - Non-Compliant: Significant issues found
  /// 
  /// Returns: Card with three compliance level options
  Widget _buildComplianceSelector() {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Compliance Status',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
                letterSpacing: 0.5,
              ),
            ),
          ),
          _buildComplianceOption(
            ComplianceLevel.compliant,
            'Compliant',
            'Checkpoint meets all requirements',
            Icons.check_circle,
            successGreen,
          ),
          Divider(height: 1, color: Colors.grey.shade200),
          _buildComplianceOption(
            ComplianceLevel.partiallyCompliant,
            'Partially Compliant',
            'Minor issues need attention',
            Icons.warning,
            warningOrange,
          ),
          Divider(height: 1, color: Colors.grey.shade200),
          _buildComplianceOption(
            ComplianceLevel.nonCompliant,
            'Non-Compliant',
            'Significant issues found',
            Icons.cancel,
            errorRed,
          ),
        ],
      ),
    );
  }

  /// Builds a single compliance level option.
  /// 
  /// Parameters:
  /// - [level]: ComplianceLevel enum value
  /// - [title]: Display title for the option
  /// - [description]: Explanatory text
  /// - [icon]: Icon to display
  /// - [color]: Brand color for this compliance level
  /// 
  /// Returns: Selectable list tile with styled content
  Widget _buildComplianceOption(
    ComplianceLevel level,
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    final isSelected = _selectedCompliance == level;

    return InkWell(
      onTap: () => setState(() => _selectedCompliance = level),
      child: Container(
        padding: const EdgeInsets.all(16),
        color: isSelected ? color.withValues(alpha: 0.05) : Colors.transparent,
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: (isSelected ? color : Colors.grey.shade400).withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? color : Colors.grey.shade400,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? color : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: color,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  /// Builds the additional notes input section.
  /// 
  /// Provides a text field for auditors to add observations,
  /// comments, or context about the checkpoint inspection.
  /// 
  /// Returns: Card with multiline text input field
  /// 
  /// TODO: Add character count indicator
  /// TODO: Implement auto-save functionality
  Widget _buildNotesSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Additional Notes (Optional)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Add any observations or comments...',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(14),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the bottom action bar with save button.
  /// 
  /// Button is enabled only when:
  /// - Compliance level is selected
  /// - Photo is taken (if in photo mode) OR in manual mode
  /// 
  /// Returns: Fixed bottom bar with save button
  Widget _buildBottomBar() {
    final canSave = _selectedCompliance != null &&
        ((_isPhotoMode && _photoTaken) || !_isPhotoMode);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 54,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: canSave ? _saveCheckpoint : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryNavy,
              disabledBackgroundColor: Colors.grey.shade300,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Save & Continue',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Captures photo and performs AI analysis.
  ///
  /// Current implementation:
  /// - Uses CameraService to capture photo
  /// - Uses AuditService for AI analysis
  /// - Updates UI with analysis results
  ///
  /// TODO: Add photo preview and retake functionality
  /// TODO: Handle camera errors gracefully
  void _takePhoto() async {
    try {
      setState(() {
        _isAnalyzing = true;
      });

      // Capture photo using camera service
      final photo = await _cameraService.takePhoto(
        checkpointId: widget.checkpoint.id,
      );

      setState(() {
        _photoTaken = true;
        _photoPath = photo.path;
      });

      // Perform AI analysis
      final analysis = await _auditService.analyzePhoto(photo.path);

      if (!mounted) return;

      setState(() {
        _isAnalyzing = false;
        _aiAnalysis = analysis;
        _selectedCompliance = analysis.suggestedCompliance;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isAnalyzing = false;
        _photoTaken = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to capture photo: ${e.toString()}'),
          backgroundColor: errorRed,
        ),
      );
    }
  }

  /// Generates demo analysis notes based on compliance level.
  /// 
  /// TODO: Remove when real AI integration is complete
  /// 
  /// Parameters:
  /// - [level]: Compliance level to generate notes for
  /// 
  /// Returns: Sample analysis text
  String _getAnalysisNotes(ComplianceLevel level) {
    switch (level) {
      case ComplianceLevel.compliant:
        return 'Area appears clean and well-maintained. All requirements are met.';
      case ComplianceLevel.partiallyCompliant:
        return 'Area is generally acceptable but minor improvements needed.';
      case ComplianceLevel.nonCompliant:
        return 'Significant cleanliness issues detected. Immediate action required.';
    }
  }

  /// Generates demo detected issues list based on compliance level.
  /// 
  /// TODO: Remove when real AI integration is complete
  /// 
  /// Parameters:
  /// - [level]: Compliance level to generate issues for
  /// 
  /// Returns: List of sample issue descriptions
  List<String> _getDetectedIssues(ComplianceLevel level) {
    switch (level) {
      case ComplianceLevel.compliant:
        return [];
      case ComplianceLevel.partiallyCompliant:
        return ['Minor debris visible', 'Some areas need attention'];
      case ComplianceLevel.nonCompliant:
        return ['Visible dirt and stains', 'Cleaning required', 'Does not meet standards'];
    }
  }

  /// Saves the checkpoint data and navigates back.
  /// 
  /// Collects all checkpoint data including:
  /// - Selected compliance level
  /// - Photo evidence (if captured)
  /// - Additional notes
  /// 
  /// Persists data using AuditService and navigates back on success
  void _saveCheckpoint() async {
    if (_selectedCompliance == null) return;

    try {
      // Get current audit
      final currentAudit = _auditService.getCurrentAudit();
      if (currentAudit == null) {
        throw Exception('No active audit found');
      }

      // Update checkpoint in audit
      await _auditService.updateCheckpoint(
        auditId: currentAudit.id,
        checkpointId: widget.checkpoint.id,
        complianceLevel: _selectedCompliance!,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        photoPath: _photoPath,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Checkpoint saved as ${_getComplianceName(_selectedCompliance!)}'),
          backgroundColor: successGreen,
          duration: const Duration(seconds: 2),
        ),
      );

      Navigator.pop(context, true); // Return true to indicate success
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save checkpoint: ${e.toString()}'),
          backgroundColor: errorRed,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// Maps compliance level to brand color.
  /// 
  /// Parameters:
  /// - [level]: Compliance level enum
  /// 
  /// Returns: Corresponding brand color
  Color _getComplianceColor(ComplianceLevel level) {
    switch (level) {
      case ComplianceLevel.compliant:
        return successGreen;
      case ComplianceLevel.partiallyCompliant:
        return warningOrange;
      case ComplianceLevel.nonCompliant:
        return errorRed;
    }
  }

  /// Converts compliance level enum to display text.
  /// 
  /// Parameters:
  /// - [level]: Compliance level enum
  /// 
  /// Returns: Human-readable compliance level name
  String _getComplianceName(ComplianceLevel level) {
    switch (level) {
      case ComplianceLevel.compliant:
        return 'Compliant';
      case ComplianceLevel.partiallyCompliant:
        return 'Partially Compliant';
      case ComplianceLevel.nonCompliant:
        return 'Non-Compliant';
    }
  }
}

// ============================================================================
// END OF FILE: checkpoint_detail_screen.dart
// ============================================================================
// AUTHOR: Sujan Sreenivasulu
// WEBSITE: https://www.stellantis.com/
// ============================================================================
