// ============================================================================
// FILE: manager_history_page.dart
// DESCRIPTION: Manager-specific history page to view recent dealer audits
//              filtered by time (1h, 24h) and grouped by zone.
// ============================================================================
// PROJECT: Stellantis Dealer Hygiene App
// AUTHOR: Srikanth Thiygarajan
// WEBSITE: https://www.stellantis.com/
// ============================================================================

import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
import '../constants/stellantis_colors.dart';
import '../services/manager_portal_service.dart';
import 'manager_home_page.dart';
import 'settings_page.dart';

/// Manager History Page
///
/// Displays a list of recent audits submitted by dealers.
/// Features:
/// - Time based filtering: "Past 1 Hour" vs "Past 24 Hours"
/// - Pull-to-refresh
/// - Empty state handling
///
/// Data Source: [ManagerPortalService.getRecentAudits]
class ManagerHistoryPage extends StatefulWidget {
  const ManagerHistoryPage({super.key});

  @override
  State<ManagerHistoryPage> createState() => _ManagerHistoryPageState();
}

class _ManagerHistoryPageState extends State<ManagerHistoryPage> {
  // Service
  final ManagerPortalService _managerService = ManagerPortalService();

  // State
  bool _isLoading = true;
  Duration _selectedDuration = const Duration(hours: 1); // Default to 1 hour
  List<Map<String, dynamic>> _recentAudits = [];

  @override
  void initState() {
    super.initState();
    _loadRecentAudits();
  }

  /// Load audits based on selected duration
  Future<void> _loadRecentAudits() async {
    setState(() => _isLoading = true);

    try {
      // Fetch from service (mocked or real)
      final audits = await _managerService.getRecentAudits(_selectedDuration);

      if (mounted) {
        setState(() {
          _recentAudits = audits;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading manager history: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: StellantisColors.error,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'RETRY',
              textColor: Colors.white,
              onPressed: _loadRecentAudits,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Recent Activity',
          style: TextStyle(
            color: Theme.of(context).textTheme.titleLarge?.color,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false, // Custom bottom nav handles back
      ),
      body: Column(
        children: [
          // Time Filter Segmented Control
          _buildTimeFilter(),

          // Audit List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadRecentAudits,
                    child: _recentAudits.isEmpty
                        ? _buildEmptyState()
                        : _buildAuditList(),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  /// Time Filter Widget (1h vs 24h)
  Widget _buildTimeFilter() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildFilterOption('Past 1 Hour', const Duration(hours: 1)),
          _buildFilterOption('Past 24 Hours', const Duration(hours: 24)),
        ],
      ),
    );
  }

  Widget _buildFilterOption(String label, Duration duration) {
    final isSelected = _selectedDuration == duration;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (!isSelected) {
            setState(() => _selectedDuration = duration);
            _loadRecentAudits();
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? StellantisColors.stellantisBlue
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey.shade600,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  /// Empty State Widget
  Widget _buildEmptyState() {
    return ListView(
      // Use ListView to allow pull-to-refresh on empty state
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.access_time,
                size: 64,
                color: Colors.grey.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'No recent audits found',
                style: TextStyle(
                  color: Theme.of(context).textTheme.titleLarge?.color,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'in the past ${_selectedDuration.inHours} hours',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Audit List Builder
  Widget _buildAuditList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _recentAudits.length,
      itemBuilder: (context, index) {
        final audit = _recentAudits[index];
        return _buildAuditCard(audit);
      },
    );
  }

  /// Individual Audit Card
  Widget _buildAuditCard(Map<String, dynamic> audit) {
    // Determine status color
    final status = audit['status'] ?? 'Unknown';
    Color statusColor = StellantisColors.stellantisBlue;
    if (status == 'Compliant') statusColor = StellantisColors.success;
    if (status == 'Non-Compliant') statusColor = StellantisColors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  audit['dealer_name'] ?? 'Unknown Dealer',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 14,
                color: Colors.grey.shade500,
              ),
              const SizedBox(width: 4),
              Text(
                audit['zone'] ?? 'Unknown Zone',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
              const Spacer(),
              Text(
                audit['time'] ?? '', // Formatted time string
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Consistent Bottom Navigation
  Widget _buildBottomNav() {
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
              _navItem(Icons.home, "HOME", false, () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const ManagerHomePage()),
                  (route) => false,
                );
              }),
              _navItem(Icons.bar_chart, "STATS", false, () {}),
              const SizedBox(width: 50),
              // Active state for History
              _navItem(Icons.history, "HISTORY", true, () {}),
              _navItem(Icons.settings, "SETTINGS", false, () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(
    IconData icon,
    String label,
    bool active,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
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
