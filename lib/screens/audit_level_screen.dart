// ============================================================================
// FILE: audit_level_screen.dart
// DESCRIPTION: Displays audit levels with progress tracking and navigation to subcategories.
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
import '../data/sample_data.dart';
import 'audit_subcategory_screen.dart';

/// Screen displaying all levels in an audit with progress tracking.
/// 
/// This screen shows a hierarchical view of the audit structure,
/// displaying each top-level category (level) with its completion status.
/// Users can tap on any level to navigate to its subcategories.
/// 
/// Features:
/// - Overall audit progress header with percentage
/// - List of audit levels with individual progress bars
/// - Visual indicators for completion status
/// - Navigation to level subcategories
/// - Real-time progress calculation
/// 
/// TODO: Add filtering options (show only incomplete levels)
/// TODO: Implement swipe gestures for quick navigation
/// TODO: Add share/export functionality for progress reports
class AuditLevelScreen extends StatelessWidget {
  const AuditLevelScreen({super.key});

  // Color constants following Stellantis brand guidelines
  static const Color primaryNavy = Color(0xFF003874);
  static const Color actionBlue = Color(0xFF003874);
  static const Color scaffoldBg = Color(0xFFF8F9FA);

  @override
  Widget build(BuildContext context) {
    // Fetch the current audit data from sample data
    // TODO: Replace with actual data service/provider
    final audit = SampleData.getCurrentAudit();
    final levels = audit.levels;

    return Scaffold(
      backgroundColor: scaffoldBg,
      
      // ===================================================================
      // APP BAR
      // ===================================================================
      // Simple app bar with back navigation and title
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryNavy),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Select Level',
          style: TextStyle(
            color: primaryNavy,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
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
          // Overall progress header at the top
          _buildProgressHeader(audit),
          
          // Scrollable list of level cards
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: levels.length,
              itemBuilder: (context, index) {
                return _buildLevelCard(context, levels[index], index + 1);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the overall progress header showing total audit completion.
  /// 
  /// Displays aggregate statistics including:
  /// - Total completed checkpoints out of total checkpoints
  /// - Overall completion percentage
  /// - Visual progress bar
  /// 
  /// Parameters:
  /// - [audit]: The Audit object containing overall progress data
  /// 
  /// Returns: A Container widget with progress information
  /// 
  /// TODO: Add estimated time to completion
  /// TODO: Show last updated timestamp
  Widget _buildProgressHeader(Audit audit) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Left side: Progress text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Overall Progress',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Display checkpoint completion ratio
                    Text(
                      '${audit.completedCheckpoints} / ${audit.totalCheckpoints} Checkpoints',
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
                  '${(audit.progressPercentage * 100).toStringAsFixed(0)}%',
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
          
          // Visual progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: audit.progressPercentage,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              color: actionBlue,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds an individual level card with navigation capability.
  /// 
  /// Each card displays:
  /// - Level number badge
  /// - Level name and description
  /// - Checkpoint completion count
  /// - Progress percentage
  /// - Visual progress indicator
  /// - Navigation arrow
  /// 
  /// Tapping the card navigates to the level's subcategory screen.
  /// 
  /// Parameters:
  /// - [context]: BuildContext for navigation
  /// - [level]: AuditLevel object containing level data
  /// - [levelNumber]: Display number for the level (1-indexed)
  /// 
  /// Returns: A tappable Container with level information
  /// 
  /// TODO: Add long-press context menu for quick actions
  /// TODO: Implement swipe-to-complete gesture
  /// TODO: Add animation when navigating back with updated progress
  Widget _buildLevelCard(BuildContext context, AuditLevel level, int levelNumber) {
    // Calculate progress metrics for this level
    final completed = level.completedCheckpoints;
    final total = level.totalCheckpoints;
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
            // Navigate to subcategory screen for this level
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AuditSubcategoryScreen(level: level, levelNumber: levelNumber),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // =========================================================
                // TOP ROW: Level number badge, name, description, arrow
                // =========================================================
                Row(
                  children: [
                    // Level number badge
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: primaryNavy.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          '$levelNumber',
                          style: const TextStyle(
                            color: primaryNavy,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Level name and description
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            level.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: primaryNavy,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            level.description,
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
                    // Checkpoint icon and count
                    Icon(
                      Icons.check_circle_outline,
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
                    
                    // Progress percentage
                    Text(
                      '${(progress * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: actionBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                
                // =========================================================
                // PROGRESS BAR
                // =========================================================
                // Visual indicator of level completion
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
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// END OF FILE: audit_level_screen.dart
// ============================================================================
// AUTHOR: Rohith U
// WEBSITE: https://www.stellantis.com/
// ============================================================================
