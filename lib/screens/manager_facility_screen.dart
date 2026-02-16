// ============================================================================
// FILE: manager_facility_screen.dart
// DESCRIPTION: Screen for managers to view facility compliance and details.
// ============================================================================
// PROJECT: Stellantis Dealer Hygiene App
// AUTHOR: Dinesh Kumar G M
// WEBSITE: https://www.stellantis.com/
// VERSION: 1.0.0
// ============================================================================
// COPYRIGHT: © 2026 STELLANTIS N.V. - INTERNAL USE ONLY
// ============================================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/facility.dart';

/// Displays the compliance overview for a specific zone.
///
/// Features:
/// - Visualizes zone compliance percentage.
/// - Lists all facilities within the zone with their status.
/// - Provides navigation back to the dashboard.
///
/// TODO: Implement filtering by compliance status (e.g., show only non-compliant)
/// TODO: Add search functionality to find specific facilities
class ManagerFacilityScreen extends StatelessWidget {
  /// The zone data object containing compliance stats and facility list.
  final ZoneCompliance zone;

  /// Creates a [ManagerFacilityScreen].
  ///
  /// [zone] is required to display the specific zone details.
  const ManagerFacilityScreen({
    super.key,
    required this.zone,
  });

  // Color constants following Stellantis brand guidelines
  static const Color primaryNavy = Color(0xFF003874);
  static const Color actionBlue = Color(0xFF003874);
  // scaffoldBg removed - use Theme.of(context).scaffoldBackgroundColor instead
  static const Color successGreen = Color(0xFF003874); // Navy blue for all compliance indicators
  static const Color warningOrange = Color(0xFF6C757D); // Changed from orange to gray for consistency
  static const Color errorRed = Color(0xFF003874); // Changed from red to navy for consistency

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      // ===================================================================
      // APP BAR
      // ===================================================================
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryNavy),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              zone.zoneName,
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : primaryNavy,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              '${zone.totalFacilities} facilities',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // summary card showing overall zone compliance
            _buildZoneOverviewCard(context),

            const SizedBox(height: 24),
            
            // Section Header
            const Text(
              'Facilities',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: primaryNavy,
              ),
            ),
            const SizedBox(height: 16),
            
            // List of facilities
            ...zone.facilities.map((facility) => _buildFacilityCard(facility)),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // HELPER WIDGETS
  // ===========================================================================

  /// Builds the summary card showing overall zone compliance and stats.
  ///
  /// Returns: A Container widget with zone overview chart and stats.
  Widget _buildZoneOverviewCard(BuildContext context) {
    final complianceColor = _getComplianceColor(zone.compliancePercentage);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Icon and Compliance Percentage
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: complianceColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.location_city,
                  color: complianceColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Zone Compliance',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${zone.compliancePercentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: complianceColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Bottom Row: Stats
          Row(
            children: [
              Expanded(
                child: _buildStatItem('Facilities', '${zone.totalFacilities}'),
              ),
              Expanded(
                child: _buildStatItem('Target', '95%',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds a single statistic item with a label and value.
  ///
  /// Parameters:
  /// - [label]: The description text.
  /// - [value]: The main statistic to display.
  ///
  /// Returns: A Column widget displaying the stat.
  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: primaryNavy,
          ),
        ),
      ],
    );
  }

  /// Builds a detailed card for a single facility.
  ///
  /// Parameters:
  /// - [facility]: The object containing data for the specific facility.
  ///
  /// Returns: A Container widget representing the facility card.
  Widget _buildFacilityCard(FacilityCompliance facility) {
    final complianceColor = _getComplianceColor(facility.compliancePercentage);
    final dateFormatter = DateFormat('MMM dd, yyyy • HH:mm');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: complianceColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Row with Name and Percentage Badge
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        facility.facilityName,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: primaryNavy,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Last audit: ${dateFormatter.format(facility.lastAuditDate)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: complianceColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${facility.compliancePercentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: complianceColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: facility.compliancePercentage / 100,
                minHeight: 8,
                backgroundColor: Colors.grey.shade200,
                color: complianceColor,
              ),
            ),
            const SizedBox(height: 16),
            
            // Stats Row
            Row(
              children: [
                Expanded(
                  child: _buildFacilityStatItem(
                    Icons.check_circle_outline,
                    'Completed',
                    '${facility.completedAudits}',
                    successGreen,
                  ),
                ),
                Expanded(
                  child: _buildFacilityStatItem(
                    Icons.pending_actions,
                    'Pending',
                    '${facility.pendingAudits}',
                    warningOrange,
                  ),
                ),
                Expanded(
                  child: _buildFacilityStatItem(
                    Icons.assignment,
                    'Total',
                    '${facility.totalAudits}',
                    actionBlue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a statistic item specifically for the facility card.
  ///
  /// Parameters:
  /// - [icon]: Icon to display next to the stat.
  /// - [label]: Description of the stat.
  /// - [value]: The numeric value to show.
  /// - [color]: Theme color for the icon and value.
  ///
  /// Returns: A Row widget with icon and text.
  Widget _buildFacilityStatItem(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ===========================================================================
  // UTILITY METHODS
  // ===========================================================================

  /// Determines the color based on the compliance percentage.
  ///
  /// Parameters:
  /// - [percentage]: The numeric compliance score (0-100).
  ///
  /// Returns: 
  /// - [successGreen] for >= 90%
  /// - [warningOrange] for >= 75%
  /// - [errorRed] for anything below
  Color _getComplianceColor(double percentage) {
    if (percentage >= 90) return successGreen;
    if (percentage >= 75) return warningOrange;
    return errorRed;
  }
}

// ============================================================================
// END OF FILE: manager_facility_screen.dart
// ============================================================================
// AUTHOR: Dinesh Kumar G M
// WEBSITE: https://www.stellantis.com/
// ============================================================================
