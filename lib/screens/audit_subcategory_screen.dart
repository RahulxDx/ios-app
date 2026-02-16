// ============================================================================
// FILE: audit_subcategory_screen.dart
// DESCRIPTION: Displays subcategories within an audit level with checkpoint navigation and progress tracking.
// ============================================================================
// PROJECT: Stellantis Dealer Hygiene App
// AUTHOR: Rohith U
// WEBSITE: https://www.stellantis.com/
// VERSION: 1.0.0
// ============================================================================
// COPYRIGHT: © 2026 STELLANTIS N.V. - INTERNAL USE ONLY
// ============================================================================

import 'package:flutter/material.dart';
import '../models/audit.dart';
import 'checkpoint_screen.dart';

/// Screen displaying subcategories within a specific audit level.
/// 
/// This screen shows the breakdown of a selected audit level into its
/// constituent subcategories. Each subcategory card displays progress
/// and allows navigation to the detailed checkpoint screen.
/// 
/// Features:
/// - Level-specific progress header with completion metrics
/// - List of subcategories with individual progress indicators
/// - Dynamic color coding based on completion status
/// - Icon indicators for progress state (unchecked, in-progress, completed)
/// - Navigation to checkpoint detail screens
/// 
/// The screen receives [level] and [levelNumber] from the previous screen
/// and passes the selected subcategory to the checkpoint screen.
/// 
/// TODO: Add filtering to show only incomplete subcategories
/// TODO: Implement bulk operations (mark all as complete)
/// TODO: Add subcategory reordering based on priority
class AuditSubcategoryScreen extends StatelessWidget {
  /// The audit level containing all subcategories to display
  final AuditLevel level;
  
  /// The display number for this level (1-indexed for UI)
  final int levelNumber;

  const AuditSubcategoryScreen({
    super.key,
    required this.level,
    required this.levelNumber,
  });

  // Color constants following Stellantis brand guidelines
  static const Color primaryNavy = Color(0xFF003874);
  static const Color actionBlue = Color(0xFF003874);
  static const Color scaffoldBg = Color(0xFFF8F9FA);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBg,
      
      // ===================================================================
      // APP BAR WITH HIERARCHICAL TITLE
      // ===================================================================
      // Shows level number and name in a two-line layout
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryNavy),
          onPressed: () => Navigator.pop(context),
        ),
        // Two-line title showing level context
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Level number label (e.g., "Level 1")
            Text(
              'Level $levelNumber',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            // Level name (e.g., "Main Hall")
            Text(
              level.name,
              style: const TextStyle(
                color: primaryNavy,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        // Bottom border for visual separation
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Colors.grey.shade200,
          ),
        ),
      ),
      
      body: Column(
        children: [
          // Level progress summary at the top
          _buildProgressHeader(),
          
          // Scrollable list of subcategory cards
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: level.subcategories.length,
              itemBuilder: (context, index) {
                return _buildSubcategoryCard(context, level.subcategories[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the progress header for the current level.
  /// 
  /// Displays aggregate statistics for this specific level:
  /// - Completed checkpoints vs total checkpoints
  /// - Percentage completion
  /// - Visual progress bar
  /// 
  /// Returns: A Container widget with level progress information
  /// 
  /// TODO: Add time tracking (time spent on this level)
  /// TODO: Show comparison with average completion time
  Widget _buildProgressHeader() {
    // Calculate progress metrics for this level
    final completed = level.completedCheckpoints;
    final total = level.totalCheckpoints;
    final progress = total > 0 ? completed / total : 0.0;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Left side: Progress label and checkpoint count
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Level Progress',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Checkpoint completion ratio
                    Text(
                      '$completed / $total Checkpoints',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryNavy,
                      ),
                    ),
                  ],
                ),
              ),
              // Right side: Percentage badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: actionBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${(progress * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                    color: actionBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Visual progress bar for level
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              color: actionBlue,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds an individual subcategory card with navigation capability.
  /// 
  /// Each card displays:
  /// - Status icon (dynamic based on progress)
  /// - Subcategory name and description
  /// - Checkpoint completion count
  /// - Progress percentage with color coding
  /// - Visual progress bar
  /// - Navigation arrow
  /// 
  /// The card's color scheme changes based on completion status:
  /// - Green: 100% complete
  /// - Blue: In progress (1-99%)
  /// - Grey: Not started (0%)
  /// 
  /// Tapping navigates to the checkpoint detail screen.
  /// 
  /// Parameters:
  /// - [context]: BuildContext for navigation
  /// - [subcategory]: AuditSubcategory object with checkpoint data
  /// 
  /// Returns: A tappable Container with subcategory information
  /// 
  /// TODO: Add swipe actions (mark complete, skip, etc.)
  /// TODO: Implement haptic feedback on tap
  /// TODO: Add subtle animation when returning from checkpoint screen
  Widget _buildSubcategoryCard(BuildContext context, AuditSubcategory subcategory) {
    // Calculate progress metrics for this subcategory
    final completed = subcategory.completedCheckpoints;
    final total = subcategory.checkpoints.length;
    final progress = total > 0 ? completed / total : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Navigate to checkpoint detail screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CheckpointScreen(subcategory: subcategory),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // =========================================================
                // TOP ROW: Status icon, name, description, arrow
                // =========================================================
                Row(
                  children: [
                    // Status icon with dynamic color based on progress
                    // Icon changes: unchecked → pending → check_circle
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _getColorForProgress(progress).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getIconForProgress(progress),
                        color: _getColorForProgress(progress),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Subcategory name and description
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            subcategory.name,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: primaryNavy,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subcategory.description,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Navigation arrow
                    Icon(
                      Icons.chevron_right,
                      color: Colors.grey.shade400,
                      size: 28,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // =========================================================
                // BOTTOM ROW: Checkpoint count and percentage
                // =========================================================
                Row(
                  children: [
                    // Checklist icon and count
                    Icon(
                      Icons.checklist,
                      size: 18,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$completed / $total Checkpoints',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    
                    // Progress percentage with dynamic color
                    Text(
                      '${(progress * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _getColorForProgress(progress),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                
                // =========================================================
                // PROGRESS BAR WITH DYNAMIC COLOR
                // =========================================================
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: Colors.grey.shade200,
                    color: _getColorForProgress(progress),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Returns an appropriate color based on completion progress.
  /// 
  /// Color coding logic:
  /// - Green (#4CAF50): 100% complete - all checkpoints finished
  /// - Blue (actionBlue): In progress - at least one checkpoint done
  /// - Grey: Not started - no checkpoints completed yet
  /// 
  /// Parameters:
  /// - [progress]: Double value from 0.0 to 1.0 representing completion
  /// 
  /// Returns: Color appropriate for the progress level
  Color _getColorForProgress(double progress) {
    if (progress >= 1.0) return const Color(0xFF4CAF50); // Success green
    if (progress > 0) return actionBlue; // In-progress blue
    return Colors.grey.shade400; // Not started grey
  }

  /// Returns an appropriate icon based on completion progress.
  /// 
  /// Icon logic:
  /// - check_circle: 100% complete
  /// - pending: In progress (partial completion)
  /// - radio_button_unchecked: Not started
  /// 
  /// Parameters:
  /// - [progress]: Double value from 0.0 to 1.0 representing completion
  /// 
  /// Returns: IconData appropriate for the progress level
  IconData _getIconForProgress(double progress) {
    if (progress >= 1.0) return Icons.check_circle; // Completed
    if (progress > 0) return Icons.pending; // In progress
    return Icons.radio_button_unchecked; // Not started
  }
}

// ============================================================================
// END OF FILE: audit_subcategory_screen.dart
// ============================================================================
// AUTHOR: Rohith U
// WEBSITE: https://www.stellantis.com/
// ============================================================================
