// ============================================================================
// FILE: new_facility_audit_page.dart
// DESCRIPTION: Screen for initiating new facility audits with AI or manual options.
// ============================================================================
// PROJECT: Stellantis Dealer Hygiene App
// AUTHOR: Dinesh Kumar G M
// WEBSITE: https://www.stellantis.com/
// VERSION: 1.0.0
// ============================================================================
// COPYRIGHT: © 2026 STELLANTIS N.V. - INTERNAL USE ONLY
// ============================================================================

import 'package:flutter/material.dart';
import '../constants/stellantis_colors.dart';
import '../services/audit_service.dart';
import '../services/auth_service.dart';
import '../models/shift.dart';
import 'ai_audit_analysis_page.dart';
import 'manual_audit_page.dart';
import 'audit_level_screen.dart';

/// Displays the screen for starting a new facility audit.
///
/// Features:
/// - Allows selection of shift details (Morning/Evening).
/// - Provides dropdowns for Activity, Subcategory, and Checkpoint selection.
/// - Integrated navigation to [AIAuditAnalysisPage] and [ManualAuditPage].
/// - Displays real-time status of shift availability.
///
/// TODO: Fetch dynamic shift data from API
/// TODO: Optimize dropdowns for large datasets
class NewFacilityAuditPage extends StatefulWidget {
  const NewFacilityAuditPage({super.key});

  @override
  State<NewFacilityAuditPage> createState() => _NewFacilityAuditPageState();
}

class _NewFacilityAuditPageState extends State<NewFacilityAuditPage> {
  // ---------------------------------------------------------------------------
  // State Variables
  // ---------------------------------------------------------------------------
  String _selectedShift = 'Morning Shift';
  bool _isCreatingAudit = false;
  List<Shift> _shifts = [];

  // Service instances
  final AuditService _auditService = AuditService();
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _initializeShifts();
  }

  /// Initialize shifts and auto-select the currently active one
  void _initializeShifts() {
    _shifts = Shift.getTodayShifts();

    // Auto-select the currently active shift
    final activeShift = _shifts.firstWhere(
      (shift) => shift.isActive,
      orElse: () => _shifts.first,
    );

    setState(() {
      _selectedShift = activeShift.displayName;
    });
  }

  /// Start a new facility audit
  Future<void> _startAudit() async {
    setState(() => _isCreatingAudit = true);

    try {
      final user = _authService.currentUser;

      // Create new audit
      final audit = await _auditService.createAudit(
        facilityId: user?.facilityId ?? 'facility_001',
        facilityName: user?.facilityName ?? 'Downtown Stellantis Showroom',
        shift: _selectedShift,
        performedBy: user?.name ?? 'John Dealer',
        performedById: user?.id ?? 'dealer_001',
      );

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Audit started for $_selectedShift'),
          backgroundColor: StellantisColors.success,
          duration: const Duration(seconds: 2),
        ),
      );

      // Navigate to audit level screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AuditLevelScreen()),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to start audit: ${e.toString()}'),
          backgroundColor: StellantisColors.error,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isCreatingAudit = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      // ===================================================================
      // APP BAR
      // ===================================================================
      appBar: AppBar(
        title: Text(
          'New Facility Audit',
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
      
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            
            // =============================================================
            // SHIFT STATUS CARD
            // =============================================================
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SHIFT STATUS',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: _shifts.map((shift) {
                      final isActive = shift.isActive;
                      final isSelected = _selectedShift == shift.displayName;

                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: shift == _shifts.first ? 12 : 0,
                            left: shift == _shifts.last ? 12 : 0,
                          ),
                          child: _buildShiftOption(
                            shift.displayName,
                            shift.timeRange,
                            isActive ? 'CURRENTLY ACTIVE' : 'AVAILABLE AT ${shift.startTime}',
                            isActive,
                            isActive
                                ? StellantisColors.stellantisBlue
                                : StellantisColors.cardBorder,
                            isActive ? Icons.check_circle : Icons.lock_outline,
                            onTap: isActive
                                ? () {
                                    setState(() {
                                      _selectedShift = shift.displayName;
                                    });
                                  }
                                : null,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            
            // =============================================================
            // INFO BOX
            // =============================================================
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Starting a facility audit will guide you through all audit levels and checkpoints. You can capture photos and add notes for each checkpoint.',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            
            // =============================================================
            // ACTION BUTTONS
            // =============================================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _isCreatingAudit ? null : _startAudit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: StellantisColors.stellantisBlue,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        disabledBackgroundColor: StellantisColors.stellantisBlue.withValues(alpha: 0.6),
                      ),
                      icon: _isCreatingAudit
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Icon(Icons.assignment, color: StellantisColors.textOnPrimary, size: 24),
                      label: Text(
                        _isCreatingAudit ? 'Starting Audit...' : 'Start Facility Audit',
                        style: TextStyle(
                          color: StellantisColors.textOnPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // HELPER WIDGETS
  // ===========================================================================

  /// Builds a selectable shift option card.
  ///
  /// Parameters:
  /// - [title]: Name of the shift.
  /// - [time]: Duration of the shift.
  /// - [status]: Availability status.
  /// - [isActive]: Whether this shift is currently active.
  /// - [borderColor]: Color of the border.
  /// - [icon]: Icon to display.
  /// - [onTap]: Callback when shift is tapped (null if disabled).
  ///
  /// Returns: A Container widget representing the shift option.
  Widget _buildShiftOption(
    String title,
    String time,
    String status,
    bool isActive,
    Color borderColor,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
        color: isActive
            ? StellantisColors.stellantisBlue.withValues(alpha: 0.05)
            : StellantisColors.inactiveGrayBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
          width: isActive ? 2.5 : 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: isActive ? StellantisColors.stellantisBlue : StellantisColors.textSecondary,
                ),
              ),
              Icon(
                icon,
                color: isActive ? StellantisColors.stellantisBlue : StellantisColors.textLight,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            time,
            style: TextStyle(
              color: isActive ? StellantisColors.stellantisBlue : StellantisColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isActive ? StellantisColors.success : StellantisColors.textLight,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  status,
                  style: TextStyle(
                    color: isActive ? StellantisColors.success : StellantisColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }

  /// Builds a standard dropdown selection card.
  ///
  /// Parameters:
  /// - [value]: The currently selected value.
  /// - [onChanged]: Callback when selection changes.
  ///
  /// Returns: A Container widget for dropdown selection.
  Widget _buildDropdownCard(String value, ValueChanged<String?> onChanged) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
          Icon(Icons.keyboard_arrow_down, color: Theme.of(context).textTheme.bodyMedium?.color, size: 24),
        ],
      ),
    );
  }
}

// ============================================================================
// END OF FILE: new_facility_audit_page.dart
// ============================================================================
// AUTHOR: Dinesh Kumar G M
// WEBSITE: https://www.stellantis.com/
// ============================================================================
