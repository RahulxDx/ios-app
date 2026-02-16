// ============================================================================
// FILE: checkpoint_screen.dart
// DESCRIPTION: Checkpoint list screen displaying all checkpoints for a
//              subcategory with progress tracking and completion status.
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
import 'checkpoint_detail_screen.dart';

/// Checkpoint list screen for a specific audit subcategory.
/// 
/// Displays all checkpoints within a subcategory with:
/// - Progress tracking header showing completion status
/// - Visual progress bar
/// - List of all checkpoints with preview information
/// - Completion indicators (icons and status)
/// - Navigation to detailed checkpoint inspection
/// 
/// Each checkpoint card shows:
/// - Checkpoint number or completion icon
/// - Title and description preview
/// - Recording method (photo or manual)
/// - Compliance status color coding
/// 
/// Features:
/// - Real-time progress calculation
/// - Color-coded compliance indicators
/// - Completion status badges
/// - Tap to open detailed inspection screen
/// 
/// TODO: Add filter options (All, Completed, Pending)
/// TODO: Implement checkpoint reordering
/// TODO: Add bulk actions (mark multiple as complete)
/// TODO: Show estimated time to complete remaining checkpoints
class CheckpointScreen extends StatelessWidget {
  final AuditSubcategory subcategory;

  const CheckpointScreen({
    super.key,
    required this.subcategory,
  });

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

  /// Builds the checkpoint list screen UI.
  /// 
  /// Creates a screen with:
  /// - App bar with subcategory name
  /// - Progress header showing completion stats
  /// - Scrollable list of checkpoint cards
  /// 
  /// @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBg,
      // ===============================================================
      // APP BAR
      // ===============================================================
      // Navigation and subcategory identification
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryNavy),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Checkpoints',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              subcategory.name,
              style: const TextStyle(
                color: primaryNavy,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
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
      // BODY - PROGRESS HEADER + CHECKPOINT LIST
      // ===============================================================
      body: Column(
        children: [
          // Progress tracking header
          _buildProgressHeader(),
          
          // Scrollable checkpoint list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: subcategory.checkpoints.length,
              itemBuilder: (context, index) {
                return _buildCheckpointCard(context, subcategory.checkpoints[index], index + 1);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the progress tracking header.
  /// 
  /// Displays:
  /// - Subcategory description
  /// - Completion count (X / Y Completed)
  /// - Percentage completion badge
  /// - Visual progress bar
  /// 
  /// Calculates progress dynamically from checkpoint completion status.
  /// 
  /// Returns: Container with progress information and bar
  Widget _buildProgressHeader() {
    final completed = subcategory.completedCheckpoints;
    final total = subcategory.checkpoints.length;
    final progress = total > 0 ? completed / total : 0.0;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            subcategory.description,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  '$completed / $total Completed',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: primaryNavy,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: actionBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${(progress * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                    color: actionBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: Colors.grey.shade200,
              color: actionBlue,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a single checkpoint card.
  /// 
  /// Displays checkpoint information with:
  /// - Numbered icon OR compliance status icon (if completed)
  /// - Title and description
  /// - Recording method indicator (photo/manual)
  /// - Color-coded border for compliance status
  /// - Navigation chevron
  /// 
  /// Parameters:
  /// - [context]: BuildContext for navigation
  /// - [checkpoint]: Checkpoint data model
  /// - [number]: Sequential checkpoint number
  /// 
  /// Returns: Tappable card that navigates to detail screen
  /// 
  /// TODO: Add swipe actions for quick operations
  Widget _buildCheckpointCard(BuildContext context, Checkpoint checkpoint, int number) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: checkpoint.isCompleted
              ? _getComplianceColor(checkpoint.complianceLevel)
              : Colors.grey.shade200,
          width: checkpoint.isCompleted ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CheckpointDetailScreen(checkpoint: checkpoint, checkpointNumber: number),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: checkpoint.isCompleted
                        ? _getComplianceColor(checkpoint.complianceLevel).withValues(alpha: 0.1)
                        : Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: checkpoint.isCompleted
                        ? Icon(
                            _getComplianceIcon(checkpoint.complianceLevel),
                            color: _getComplianceColor(checkpoint.complianceLevel),
                            size: 22,
                          )
                        : Text(
                            '$number',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        checkpoint.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: checkpoint.isCompleted ? primaryNavy : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        checkpoint.description,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (checkpoint.isCompleted) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              checkpoint.evidence?.photoPath != null
                                  ? Icons.camera_alt
                                  : Icons.edit_note,
                              size: 14,
                              color: Colors.grey.shade500,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              checkpoint.evidence?.photoPath != null
                                  ? 'Photo captured'
                                  : 'Manual entry',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey.shade400,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Maps compliance level to brand color.
  /// 
  /// Parameters:
  /// - [level]: Optional compliance level enum
  /// 
  /// Returns: Corresponding brand color (grey if null)
  Color _getComplianceColor(ComplianceLevel? level) {
    switch (level) {
      case ComplianceLevel.compliant:
        return successGreen;
      case ComplianceLevel.partiallyCompliant:
        return warningOrange;
      case ComplianceLevel.nonCompliant:
        return errorRed;
      default:
        return Colors.grey;
    }
  }

  /// Maps compliance level to appropriate icon.
  /// 
  /// Parameters:
  /// - [level]: Optional compliance level enum
  /// 
  /// Returns: Icon representing the compliance status
  IconData _getComplianceIcon(ComplianceLevel? level) {
    switch (level) {
      case ComplianceLevel.compliant:
        return Icons.check_circle;
      case ComplianceLevel.partiallyCompliant:
        return Icons.warning;
      case ComplianceLevel.nonCompliant:
        return Icons.cancel;
      default:
        return Icons.radio_button_unchecked;
    }
  }
}

// ============================================================================
// END OF FILE: checkpoint_screen.dart
// ============================================================================
// AUTHOR: Sujan Sreenivasulu
// WEBSITE: https://www.stellantis.com/
// ============================================================================

