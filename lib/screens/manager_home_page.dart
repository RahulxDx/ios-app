// ============================================================================
// FILE: manager_home_page.dart
// DESCRIPTION: Manager dashboard displaying zone-wise performance and national compliance metrics.
// ============================================================================
// PROJECT: Stellantis Dealer Hygiene App
// AUTHOR: Srikanth Thiyagarajan
// WEBSITE: https://www.stellantis.com/
// VERSION: 1.0.0
// ============================================================================
// COPYRIGHT: © 2026 STELLANTIS N.V. - INTERNAL USE ONLY
// ============================================================================

import 'package:flutter/material.dart';
import '../data/sample_data.dart';
import '../models/facility.dart';
import '../constants/stellantis_colors.dart';
import 'manager_zone_screen.dart';
import 'manager_facility_screen.dart';
import 'settings_page.dart';
import 'manager_history_page.dart';
import '../services/auth_service.dart';
import '../services/manager_portal_service.dart';
import '../services/notification_service.dart';
import '../widgets/advanced_search_widget.dart';

/// Manager dashboard for monitoring national dealer hygiene compliance.
///
/// This page provides a comprehensive overview of dealer performance across
/// different zones with the following key features:
/// 1. National compliance metrics with year-over-year comparison
/// 2. Zone-wise performance tracking with visual indicators
/// 3. Consolidated summary showing audited facilities and pending audits
/// 4. Date selector for viewing historical compliance data
/// 5. Bottom navigation for accessing different sections of the app
///
/// The dashboard displays:
/// - National compliance percentage with trend indicators
/// - Zone performance cards with color-coded compliance levels
/// - Quick statistics for audited and pending facilities
/// - Monthly growth metrics
///
/// Users can navigate to detailed zone views by tapping on zone cards.
/// The FAB allows quick access to create new audit entries.
///
/// **UPDATED:** Now fetches live data from backend API
/// - Uses ManagerPortalService to fetch from /api/v1/manager/dashboard
/// - Automatically aggregates manual_audits table data
/// - Refreshes on pull-to-refresh gesture
/// - Falls back to sample data if backend unavailable
class ManagerHomePage extends StatefulWidget {
  const ManagerHomePage({super.key});

  @override
  State<ManagerHomePage> createState() => _ManagerHomePageState();
}

class _ManagerHomePageState extends State<ManagerHomePage> {
  static const Color _navy = Color(0xFF003874);
  static const Color _grey = Color(0xFF6C757D);
  static const Color _bg = Color(0xFFF8F9FA);

  // Services
  final ManagerPortalService _managerService = ManagerPortalService();
  final NotificationService _notificationService = NotificationService();

  // State
  List<CountryCompliance> _countriesData = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
    // Notification polling disabled as per Fix 3
    // _initializeNotifications();
  }

  @override
  void dispose() {
    _notificationService.stopPolling();
    super.dispose();
  }

  // Notification initialization removed as per Fix 3
  // Future<void> _initializeNotifications() async { ... }

  /// Load dashboard data from backend
  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      print('📊 Loading Manager Portal dashboard data...');
      final data = await _managerService.getDashboardData();

      setState(() {
        _countriesData = data;
        _isLoading = false;
        _hasError = false;
      });

      print('✅ Dashboard data loaded: ${data.length} countries');
    } catch (e) {
      print('⚠️  Failed to load backend data: $e');
      print('📦 Falling back to sample data...');

      // Fallback to sample data
      setState(() {
        _countriesData = SampleData.getManagerComplianceData();
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Using sample data - Backend unavailable';
      });
    }
  }

  /// Refresh dashboard data (pull-to-refresh)
  Future<void> _refreshDashboard() async {
    await _loadDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Background color using theme
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshDashboard,
          color: Theme.of(context).colorScheme.primary,
          child: _isLoading
              ? _buildLoadingState()
              : SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User profile header with notifications
                      _buildHeader(),
                      const SizedBox(height: 18),

                      // Show error banner if using fallback data
                      if (_hasError) _buildErrorBanner(),
                      if (_hasError) const SizedBox(height: 12),

                      Text(
                        'Compliance Overview',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.titleLarge?.color,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Zone compliance percentages and dealership details',
                        style: TextStyle(
                          color: _grey,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Country compliance cards with live data
                      if (_countriesData.isEmpty)
                        _buildEmptyState()
                      else
                        ..._countriesData.map(
                          (country) =>
                              _buildDealerComplianceCard(context, country),
                        ),

                      const SizedBox(height: 80),
                    ],
                  ),
                ),
        ),
      ),

      // ===============================================================
      // BOTTOM NAVIGATION BAR
      // ===============================================================
      // Main navigation with notched design for FAB integration
      bottomNavigationBar: _buildBottomNav(context),

      // ===============================================================
      // FLOATING ACTION BUTTON
      // ===============================================================
      // Removed per requirements - Manager view only
      // floatingActionButton: null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  /// Show advanced search modal dialog
  void _showAdvancedSearch(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: AdvancedSearchWidget(
                countries: _countriesData,
                onFacilityTap: (facility) {
                  // Navigate to facility screen
                  _navigateToFacility(facility);
                },
                onZoneTap: (zone, country) {
                  // Navigate to zone screen
                  _navigateToZone(zone, country);
                },
              ),
            ),
          ),
        );
      },
    );
  }

  /// Navigate to facility details screen
  void _navigateToFacility(FacilityCompliance facility) {
    Navigator.pop(context); // Close the search modal

    // Find the zone containing this facility
    for (final country in _countriesData) {
      for (final zone in country.zones) {
        if (zone.facilities.contains(facility)) {
          // Navigate to facility screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ManagerFacilityScreen(zone: zone),
            ),
          );
          return;
        }
      }
    }
  }

  /// Navigate to zone details screen
  void _navigateToZone(ZoneCompliance zone, CountryCompliance country) {
    Navigator.pop(context); // Close the search modal
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ManagerZoneScreen(country: country),
      ),
    );
  }

  /// Builds the header section with user profile and action icons.
  ///
  /// Displays:
  /// - User avatar with initials
  /// - User name and role (National Manager)
  /// - Search icon button
  /// - Notification bell icon with unread indicator badge
  ///
  /// Returns: Row widget containing all header elements
  ///
  /// TODO: Implement search functionality
  /// TODO: Add notifications panel on bell icon tap
  /// TODO: Load user data from authentication service
  Widget _buildHeader() {
    final user = AuthService().currentUser;
    final name = (user?.name.trim().isNotEmpty ?? false)
        ? user!.name.trim()
        : 'Manager';
    final email = (user?.email ?? '').trim().toLowerCase();
    final initials = name
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p[0].toUpperCase())
        .join();

    final useProfileImage = email == 'debabratadas@stellantis.com';

    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: StellantisColors.stellantisBlue,
            shape: BoxShape.circle,
            border: Border.all(color: StellantisColors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: StellantisColors.stellantisBlue.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipOval(
            child: useProfileImage
                ? Image.asset(
                    'assets/images/debabrata-das.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, _) {
                      return Center(
                        child: Text(
                          initials.isEmpty ? 'M' : initials,
                          style: const TextStyle(
                            color: StellantisColors.textOnPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      );
                    },
                  )
                : Center(
                    child: Text(
                      initials.isEmpty ? 'M' : initials,
                      style: const TextStyle(
                        color: StellantisColors.textOnPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "NATIONAL MANAGER",
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(Icons.search, color: StellantisColors.stellantisBlue),
          onPressed: () => _showAdvancedSearch(context),
        ),
        // Notification icon removed as per Fix 3
      ],
    );
  }

  /// Build loading state
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: _navy),
          const SizedBox(height: 16),
          Text(
            'Loading dashboard data...',
            style: TextStyle(
              color: _grey,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Build error banner
  Widget _buildErrorBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _grey.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: _grey, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage,
              style: TextStyle(
                color: _grey,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build empty state
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 64,
              color: _grey.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No Audit Data Available',
              style: TextStyle(
                color: _navy,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Manual audits will appear here once dealers submit their data.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _grey, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a dealer compliance card with compliance metrics.
  ///
  /// Creates an interactive card showing dealer compliance data with:
  /// - Dealer/zone name
  /// - Compliance percentage with trend arrow
  /// - Tap navigation to detailed zone view
  ///
  /// Parameters:
  /// - [context]: BuildContext for navigation
  /// - [country]: CountryCompliance data model with dealer metrics
  ///
  /// Returns: Container with InkWell-wrapped dealer compliance data
  ///
  /// TODO: Add swipe gestures for quick actions
  /// TODO: Implement long-press for additional options menu
  Widget _buildDealerComplianceCard(
    BuildContext context,
    CountryCompliance country,
  ) {
    final complianceColor = _navy; // strict navy/grey grading

    final title = country.countryName;
    final subtitle =
        '${country.totalZones} zones • ${country.totalFacilities} facilities';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ManagerZoneScreen(country: country),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: Theme.of(context).textTheme.titleLarge?.color,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${country.compliancePercentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: complianceColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                  size: 22,
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: (country.compliancePercentage.clamp(0, 100)) / 100,
                minHeight: 8,
                backgroundColor: Theme.of(context).dividerColor,
                color: complianceColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the bottom navigation bar with notched design.
  ///
  /// Creates a navigation bar with four tabs:
  /// 1. Dashboard (current/active)
  /// 2. Map view
  /// 3. Reports
  /// 4. Settings
  ///
  /// Features a circular notch to accommodate the centered FAB.
  ///
  /// Parameters:
  /// - [context]: BuildContext for navigation
  ///
  /// Returns: BottomAppBar with navigation items
  ///
  /// TODO: Implement state management for active tab
  /// TODO: Add navigation logic for Map and Reports tabs
  /// Builds the bottom navigation bar with notched design.
  ///
  /// Creates a navigation bar with four tabs:
  /// 1. Home (current/active)
  /// 2. Stats
  /// 3. History
  /// 4. Settings
  ///
  /// Features a circular notch to accommodate the centered FAB.
  ///
  /// Parameters:
  /// - [context]: BuildContext for navigation
  ///
  /// Returns: BottomAppBar with navigation items
  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 10,
        color: Theme.of(context).bottomAppBarTheme.color,
        elevation: 0,
        child: SizedBox(
          height: 65,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(context, Icons.home, "HOME", true, 0),
              _navItem(context, Icons.bar_chart, "STATS", false, 1),
              const SizedBox(width: 50),
              _navItem(context, Icons.history, "HISTORY", false, 2),
              _navItem(context, Icons.settings, "SETTINGS", false, 3),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a single navigation item for the bottom bar.
  ///
  /// Creates a navigation button with icon and label that changes
  /// appearance based on active state.
  ///
  /// Parameters:
  /// - [context]: BuildContext for navigation
  /// - [icon]: IconData to display
  /// - [label]: Text label below the icon
  /// - [active]: Whether this item is currently active
  /// - [index]: Navigation item index (0-3)
  ///
  /// Returns: InkWell-wrapped navigation item column
  Widget _navItem(
    BuildContext context,
    IconData icon,
    String label,
    bool active,
    int index,
  ) {
    return InkWell(
      onTap: () {
        if (index == 2) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ManagerHistoryPage()),
          );
        } else if (index == 3) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SettingsPage()),
          );
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: active
                ? StellantisColors.stellantisBlue
                : Colors.grey.shade400,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: active
                  ? StellantisColors.stellantisBlue
                  : Colors.grey.shade400,
              fontSize: 11,
              fontWeight: active ? FontWeight.bold : FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// END OF FILE: manager_home_page.dart
// ============================================================================
// AUTHOR: Srikanth Thiyagarajan
// WEBSITE: https://www.stellantis.com/
// ============================================================================
