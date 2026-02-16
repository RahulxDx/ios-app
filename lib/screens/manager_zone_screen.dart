// ============================================================================
// FILE: manager_zone_screen.dart
// DESCRIPTION: Manager zone overview screen displaying zone-level compliance
//              metrics and facility navigation for a specific country.
// ============================================================================
// PROJECT: Stellantis Dealer Hygiene App
// AUTHOR: Sujan Sreenivasulu
// WEBSITE: https://www.stellantis.com/
// VERSION: 1.0.0
// ============================================================================
// COPYRIGHT: © 2026 STELLANTIS N.V. - INTERNAL USE ONLY
// ============================================================================

import 'package:flutter/material.dart';
import '../models/facility.dart';
import 'manager_facility_screen.dart';

/// Manager zone overview screen for country-level supervision.
/// 
/// This screen displays zone-level compliance data for a selected country,
/// allowing managers to:
/// - View overall country compliance percentage
/// - Monitor individual zone performance
/// - Navigate to zone-specific facility details
/// - Track key metrics (zones, facilities)
/// 
/// Features:
/// - Gradient overview card with compliance percentage
/// - Color-coded compliance indicators (green, orange, red)
/// - Zone list with progress bars
/// - Real-time compliance calculations
/// - Tap-to-navigate to facility screen
/// 
/// Visual Hierarchy:
/// 1. App bar with country name and zone count
/// 2. Overview card with overall compliance and stats
/// 3. Scrollable list of zones with individual metrics
/// 
/// TODO: Add filtering options (by compliance level, zone name)
/// TODO: Implement sort functionality (name, compliance, facilities)
/// TODO: Add compliance trend graphs over time
/// TODO: Export zone report functionality
/// TODO: Add search capability for zones
class ManagerZoneScreen extends StatelessWidget {
  final CountryCompliance country;

  const ManagerZoneScreen({
    super.key,
    required this.country,
  });

  // =========================================================================
  // DESIGN SYSTEM COLORS
  // =========================================================================
  // Brand colors following Stellantis design guidelines
  static const Color primaryNavy = Color(0xFF003874);
  static const Color actionBlue = Color(0xFF003874);
  // scaffoldBg removed - use Theme.of(context).scaffoldBackgroundColor
  static const Color successGreen = Color(0xFF003874); // Navy blue for all compliance indicators
  // Neutral gray used instead of yellow/orange to match navy/gray grading
  static const Color warningOrange = Color(0xFF6C757D); // Changed from gray to maintain consistency
  static const Color errorRed = Color(0xFF003874); // Changed from red to navy for consistency

  /// Builds the manager zone overview screen UI.
  /// 
  /// Creates a screen with:
  /// - App bar with country name and zone count
  /// - Overview card with overall compliance metrics
  /// - Scrollable list of zones with navigation
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      // ===============================================================
      // APP BAR
      // ===============================================================
      // Country name and zone count display
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
              country.countryName,
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : primaryNavy,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              '${country.totalZones} zones',
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
            color: Colors.grey.shade200,
          ),
        ),
      ),
      // ===============================================================
      // BODY - SCROLLABLE CONTENT
      // ===============================================================
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overall compliance overview card
            _buildOverviewCard(),
            const SizedBox(height: 24),
            
            // Zone list section header
            const Text(
              'Zones',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: primaryNavy,
              ),
            ),
            const SizedBox(height: 16),
            
            // Dynamic zone cards list
            ...country.zones.map((zone) => _buildZoneCard(context, zone)),
          ],
        ),
      ),
    );
  }

  /// Builds the country overview card with compliance metrics.
  /// 
  /// Displays:
  /// - Overall compliance percentage (large display)
  /// - Compliance status icon
  /// - Total zones count
  /// - Total facilities count
  /// - Color-coded gradient background
  /// 
  /// The card uses gradient colors based on compliance level to provide
  /// immediate visual feedback on country performance.
  /// 
  /// Returns: Gradient container with compliance statistics
  Widget _buildOverviewCard() {
    final complianceColor = _getComplianceColor(country.compliancePercentage);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [complianceColor, complianceColor.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: complianceColor.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Overall Compliance',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '${country.compliancePercentage.toStringAsFixed(1)}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Icon(
                _getComplianceIcon(country.compliancePercentage),
                color: Colors.white,
                size: 48,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Zones',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${country.totalZones}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Facilities',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${country.totalFacilities}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds a single zone compliance card.
  /// 
  /// Displays zone information including:
  /// - Zone name and icon
  /// - Number of facilities in zone
  /// - Compliance percentage
  /// - Progress bar visualization
  /// - Navigation chevron
  /// 
  /// The card is tappable and navigates to the facility screen for
  /// detailed zone management.
  /// 
  /// Parameters:
  /// - [context]: BuildContext for navigation
  /// - [zone]: ZoneCompliance data model
  /// 
  /// Returns: Tappable card that navigates to ManagerFacilityScreen
  /// 
  /// TODO: Add long-press for quick actions menu
  /// TODO: Implement swipe gestures for additional options
  Widget _buildZoneCard(BuildContext context, ZoneCompliance zone) {
    final complianceColor = _getComplianceColor(zone.compliancePercentage);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
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
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ManagerFacilityScreen(zone: zone),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: complianceColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.location_city,
                        color: complianceColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            zone.zoneName,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: primaryNavy,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${zone.totalFacilities} facilities',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${zone.compliancePercentage.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: complianceColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.chevron_right,
                      color: Colors.grey.shade400,
                      size: 28,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: zone.compliancePercentage / 100,
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade200,
                    color: complianceColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Maps compliance percentage to brand color.
  /// 
  /// Color thresholds:
  /// - >= 90%: Success green (excellent compliance)
  /// - >= 75%: Navy gray (needs attention)
  /// - < 75%: Error red (critical issues)
  /// 
  /// Parameters:
  /// - [percentage]: Compliance percentage (0-100)
  /// 
  /// Returns: Corresponding brand color
  Color _getComplianceColor(double percentage) {
    if (percentage >= 90) return successGreen;
    if (percentage >= 75) return actionBlue; // use navy instead of yellow
    return errorRed;
  }

  /// Maps compliance percentage to appropriate icon.
  /// 
  /// Icon selection:
  /// - >= 90%: Check circle (excellent)
  /// - >= 75%: Trending up (needs attention)
  /// - < 75%: Error (critical)
  /// 
  /// Parameters:
  /// - [percentage]: Compliance percentage (0-100)
  /// 
  /// Returns: Icon representing compliance status
  IconData _getComplianceIcon(double percentage) {
    if (percentage >= 90) return Icons.check_circle;
    if (percentage >= 75) return Icons.trending_up; // avoid warning amber icon
    return Icons.error;
  }
}

// ============================================================================
// END OF FILE: manager_zone_screen.dart
// ============================================================================
// AUTHOR: Sujan Sreenivasulu
// WEBSITE: https://www.stellantis.com/
// ============================================================================
