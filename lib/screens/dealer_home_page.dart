import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/audit_service.dart';
import '../services/auth_service.dart';
import '../providers/theme_provider.dart';
import '../models/shift.dart';
import 'audit_entry_page.dart';
import 'audit_level_screen.dart';
import 'settings_page.dart';
import 'audit_history_page.dart';

class DealerHomePage extends StatefulWidget {
  const DealerHomePage({super.key});

  @override
  State<DealerHomePage> createState() => _DealerHomePageState();
}

class _DealerHomePageState extends State<DealerHomePage> {
  // Theme Colors
  static const Color primaryNavy = Color(0xFF003874);
  static const Color actionBlue = primaryNavy;
  static const Color successBg = Color(0xFFE8F5E9);
  static const Color successText = Color(0xFF2E7D32);
  // scaffoldBg removed - use Theme.of(context).scaffoldBackgroundColor

  // Service instances
  final AuditService _auditService = AuditService();
  final AuthService _authService = AuthService();

  // State variables
  Map<String, dynamic>? _stats;
  bool _isLoading = true;
  List<Shift> _shifts = [];

  // Keep a local copy so UI updates when auth changes
  User? _user;
  StreamSubscription<User?>? _userSub;

  Timer? _clockTimer;

  @override
  void initState() {
    super.initState();
    _user = _authService.currentUser;
    _userSub = _authService.userStream.listen((u) {
      if (!mounted) return;
      setState(() => _user = u);
    });

    // Refresh greeting (and any time-based UI) every minute.
    _clockTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (!mounted) return;
      setState(() {
        // also refresh shifts availability
        _shifts = Shift.getTodayShifts();
      });
    });

    _loadStats();
    _initializeShifts();
  }

  /// Initialize shifts with current time-based detection
  void _initializeShifts() {
    setState(() {
      _shifts = Shift.getTodayShifts();
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    _userSub?.cancel();
    super.dispose();
  }

  Future<void> _loadStats() async {
    try {
      final user = _authService.currentUser;
      if (user?.facilityId != null) {
        final stats = await _auditService.getAuditStats(user!.facilityId!);
        final userStats = await _authService.getUserStats();

        if (mounted) {
          setState(() {
            _stats = {...stats, ...userStats};
            _isLoading = false;
          });
        }
      } else {
        // Use mock data if no facility
        setState(() {
          _stats = {
            'totalAuditsCompleted': 24,
            'auditsToday': 4,
            'averageCompliance': 82.0,
            'inProgressAudits': 1,
          };
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _stats = {
            'totalAuditsCompleted': 24,
            'auditsToday': 4,
            'averageCompliance': 82.0,
            'inProgressAudits': 1,
          };
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 25),
              _buildComplianceCard(),
              const SizedBox(height: 30),
              _buildGreetingCard(),
              const SizedBox(height: 30),
              _buildSectionTitle("Shift Categories", "OCT 24, 2023"),
              const SizedBox(height: 15),
              // Dynamic shift cards based on current time
              ..._shifts.map((shift) {
                final isActive = shift.isActive;
                final progress = isActive
                    ? (_stats?['averageCompliance'] ?? 0) / 100
                    : 0.0;
                final progressText = isActive
                    ? '${(_stats?['averageCompliance'] ?? 0).toInt()}%'
                    : '';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: _buildShiftCard(
                    context: context,
                    title: shift.displayName,
                    time: shift.timeRange,
                    progress: progress,
                    progressText: progressText,
                    status: isActive ? "ACTIVE" : "LOCKED",
                    isActive: isActive,
                    icon: shift.type == ShiftType.morning
                        ? Icons.wb_sunny
                        : Icons.nightlight_round,
                  ),
                );
              }).toList(),
              const SizedBox(height: 24),
              const Text(
                "Consolidated Summaries",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryNavy,
                ),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      "AUDITS\nDONE",
                      "${_stats?['totalAuditsCompleted'] ?? 24}",
                      "+${_stats?['auditsToday'] ?? 4} Today",
                      Icons.check_circle,
                      const Color(0xFF4CAF50),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildSummaryCard(
                      "AUDITS\nREMAINING",
                      "${_stats?['inProgressAudits'] ?? 8}",
                      "IN PROGRESS",
                      Icons.pending_actions,
                      actionBlue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 80), // Space for FAB
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const AuditEntryPage()))
              .then((_) => _loadStats()); // Reload stats when returning
        },
        backgroundColor: primaryNavy,
        elevation: 8,
        child: const Icon(Icons.add, size: 32, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildHeader() {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Row(
      children: [
        Text(
          "Dealer Dashboard",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.headlineMedium?.color,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () => themeProvider.toggleTheme(),
          child: _buildIconBtn(
            themeProvider.isDarkMode
                ? Icons.light_mode
                : Icons.nightlight_round,
          ),
        ),
        const SizedBox(width: 10),
        Stack(
          children: [
            _buildIconBtn(Icons.notifications_outlined),
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildComplianceCard() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF003874), Color(0xFF004A9C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primaryNavy.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "DAILY COMPLIANCE",
                  style: TextStyle(
                    color: Colors.white70,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Status",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: successBg.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF4CAF50),
                      width: 1.5,
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Color(0xFF4CAF50),
                        size: 16,
                      ),
                      SizedBox(width: 6),
                      Text(
                        "ON TRACK",
                        style: TextStyle(
                          color: Color(0xFF4CAF50),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: CircularProgressIndicator(
                  value: (_stats?['averageCompliance'] ?? 78.0) / 100.0,
                  strokeWidth: 10,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  color: Colors.white,
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(
                children: [
                  Text(
                    "${(_stats?['averageCompliance'] ?? 78.0).toInt()}%",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "COMPLETE",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: primaryNavy),
            onPressed: () {},
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          Row(
            children: const [
              Icon(Icons.calendar_today, size: 16, color: primaryNavy),
              SizedBox(width: 8),
              Text(
                "October 2023",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: primaryNavy,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: primaryNavy),
            onPressed: () {},
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  /// Get greeting message based on current time
  /// Morning: 6:00 AM - 11:59 AM
  /// Afternoon: 12:00 PM - 5:59 PM
  /// Evening: 6:00 PM - 5:59 AM
  String _getGreetingBasedOnTime() {
    final hour = DateTime.now().hour;

    if (hour >= 6 && hour < 12) {
      return "GOOD MORNING,";
    } else if (hour >= 12 && hour < 18) {
      return "GOOD AFTERNOON,";
    } else {
      return "GOOD EVENING,";
    }
  }

  Widget _buildGreetingCard() {
    final displayName = (_user?.name.trim().isNotEmpty ?? false)
        ? _user!.name.trim()
        : 'User';
    final email = _user?.email ?? '';
    final initials = displayName
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p[0].toUpperCase())
        .join();

    final useProfileImage =
        email.trim().toLowerCase() == 'debabratadas@stellantis.com';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: actionBlue, width: 2),
            ),
            child: useProfileImage
                ? CircleAvatar(
                    radius: 30,
                    backgroundColor: actionBlue.withValues(alpha: 0.12),
                    backgroundImage: const AssetImage(
                      'assets/images/debabrata-das.png',
                    ),
                    onBackgroundImageError: (_, __) {},
                    child: Text(
                      initials.isEmpty ? 'U' : initials,
                      style: const TextStyle(
                        color: primaryNavy,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                  )
                : CircleAvatar(
                    radius: 30,
                    backgroundColor: actionBlue.withValues(alpha: 0.12),
                    child: Text(
                      initials.isEmpty ? 'U' : initials,
                      style: const TextStyle(
                        color: primaryNavy,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getGreetingBasedOnTime(),
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  displayName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                if (email.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    email,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.wb_sunny, color: Colors.orange, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildShiftCard({
    required BuildContext context,
    required String title,
    required String time,
    required double progress,
    required String progressText,
    required String status,
    required bool isActive,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isActive
                      ? actionBlue.withValues(alpha: 0.1)
                      : Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: isActive ? actionBlue : Colors.grey,
                  size: 24,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: isActive ? Colors.black : Colors.grey.shade400,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      time,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              if (isActive)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: successBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: const TextStyle(
                      color: successText,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      letterSpacing: 0.5,
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.lock_outline,
                    color: Colors.grey.shade400,
                    size: 20,
                  ),
                ),
            ],
          ),
          if (isActive) ...[
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "PROGRESS",
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                  ),
                ),
                Text(
                  progressText,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: primaryNavy,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: Colors.grey.shade200,
                color: primaryNavy,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AuditLevelScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryNavy,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      "CONTINUE AUDIT",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(width: 10),
                    Icon(Icons.arrow_forward, size: 18, color: Colors.white),
                  ],
                ),
              ),
            ),
          ] else ...[
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200, width: 1.5),
              ),
              child: Text(
                status,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String label,
    String value,
    String sub,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.bold,
              fontSize: 11,
              letterSpacing: 0.8,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            sub,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, String? trailing) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        if (trailing != null)
          Text(
            trailing,
            style: TextStyle(
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w600,
              fontSize: 13,
              letterSpacing: 0.5,
            ),
          ),
      ],
    );
  }

  Widget _buildIconBtn(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon, size: 20, color: primaryNavy),
    );
  }

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
              _navItem(Icons.home, "HOME", true, () {}),
              _navItem(Icons.bar_chart, "STATS", false, () {}),
              const SizedBox(width: 50),
              _navItem(Icons.history, "HISTORY", false, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AuditHistoryPage(),
                  ),
                );
              }),
              _navItem(Icons.settings, "SETTINGS", false, () {
                Navigator.push(
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
            color: active ? primaryNavy : Colors.grey.shade400,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: active ? primaryNavy : Colors.grey.shade400,
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

/*
 * ========================================================================
 * End of dealer_home_page.dart
 * Author: Rahul Raja
 * Website: https://www.stellantis.com/
 * ========================================================================
 */
