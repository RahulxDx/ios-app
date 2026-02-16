// ============================================================================
// FILE: audit_entry_page.dart
// DESCRIPTION: Main audit entry screen providing three audit type options with navigation.
// ============================================================================
// PROJECT: Stellantis Dealer Hygiene App
// AUTHOR: Rohith U
// WEBSITE: https://www.stellantis.com/
// VERSION: 1.0.0
// ============================================================================
// COPYRIGHT: © 2026 STELLANTIS N.V. - INTERNAL USE ONLY
// ============================================================================

import 'package:flutter/material.dart';
import '../constants/stellantis_colors.dart';
import '../services/auth_service.dart';
import 'new_facility_audit_page.dart';
import 'ai_audit_analysis_page.dart';
import 'manual_audit_page.dart';

/// Entry point screen for selecting the type of audit to perform.
/// 
/// This page presents three different audit methods to the user:
/// 1. New Facility Audit - Complete facility hygiene inspection
/// 2. AI Photo Analysis - Quick photo-based AI scan
/// 3. Manual Audit - Detailed manual inspection checklist
/// 
/// Each option is presented as a card with an icon, title, description,
/// and navigation arrow. Users can tap any card to navigate to the
/// corresponding audit workflow.
/// 
/// TODO: Add analytics tracking for audit type selection
/// TODO: Implement conditional rendering based on user permissions
/// TODO: Add quick stats showing pending/completed audits
class AuditEntryPage extends StatelessWidget {
  const AuditEntryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Background color using theme
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      // App bar with back navigation and centered title
      appBar: AppBar(
        title: Text(
          'New Audit Entry',
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
          icon: Icon(Icons.arrow_back_ios, color: Theme.of(context).colorScheme.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              
              // Section title
              Text(
                'Select Audit Type',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
              const SizedBox(height: 20),
              
              // ===============================================================
              // NEW FACILITY AUDIT CARD
              // ===============================================================
              // Comprehensive facility-wide hygiene inspection option.
              // Navigates to the full facility audit workflow.
              _buildAuditTypeCard(
                context,
                icon: Icons.store_outlined,
                title: 'New Facility Audit',
                subtitle: 'Complete facility hygiene inspection',
                color: StellantisColors.stellantisBlue,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const NewFacilityAuditPage()),
                  );
                },
              ),
              const SizedBox(height: 16),
              
              // ===============================================================
              // AI PHOTO ANALYSIS CARD
              // ===============================================================
              // Quick AI-powered photo analysis for rapid spot checks.
              // Uses machine learning to detect hygiene issues.
              // TODO: Add offline capability for AI analysis
              _buildAuditTypeCard(
                context,
                icon: Icons.camera_alt_outlined,
                title: 'AI Photo Analysis',
                subtitle: 'Quick photo-based AI scan',
                color: StellantisColors.success,
                onTap: () {
                  // Get current user info for dealer ID
                  final authService = AuthService();
                  final currentUser = authService.currentUser;
                  final dealerId = currentUser?.facilityId ?? currentUser?.id ?? 'UNKNOWN';

                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AIAuditAnalysisPage(
                        dealerId: dealerId,
                        checkpointId: 'QUICK_SCAN_${DateTime.now().millisecondsSinceEpoch}',
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              
              // ===============================================================
              // MANUAL AUDIT CARD
              // ===============================================================
              // Traditional manual inspection with detailed checklist.
              // Allows for thorough examination without requiring photos.
              _buildAuditTypeCard(
                context,
                icon: Icons.checklist_rtl,
                title: 'Manual Audit',
                subtitle: 'Detailed manual inspection checklist',
                color: StellantisColors.skyBlue,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ManualAuditPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a styled audit type selection card.
  /// 
  /// Creates a reusable card component with an icon, title, subtitle,
  /// and navigation arrow. The card has hover/tap effects and follows
  /// the Stellantis design system.
  /// 
  /// Parameters:
  /// - [context]: BuildContext for navigation
  /// - [icon]: IconData to display on the left side
  /// - [title]: Main title text for the audit type
  /// - [subtitle]: Descriptive subtitle explaining the audit type
  /// - [color]: Brand color for the icon background
  /// - [onTap]: Callback function when card is tapped
  /// 
  /// Returns: A styled InkWell-wrapped Container widget
  /// 
  /// TODO: Add accessibility labels for screen readers
  /// TODO: Implement haptic feedback on tap
  Widget _buildAuditTypeCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Theme.of(context).dividerColor, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon container with colored background
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),

            // Title and subtitle text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// END OF FILE: audit_entry_page.dart
// ============================================================================
// AUTHOR: Rohith U
// WEBSITE: https://www.stellantis.com/
// ============================================================================
