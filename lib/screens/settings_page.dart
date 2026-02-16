// ============================================================================
// FILE: settings_page.dart
// DESCRIPTION: Settings and preferences screen for the Stellantis Dealer
//              Hygiene App. Provides user profile management, app preferences,
//              security settings, and account controls for both dealer
//              employees and managers.
// ============================================================================
// PROJECT: Stellantis Dealer Hygiene App
// AUTHOR: Rahul Raja
// WEBSITE: https://www.stellantis.com/
// VERSION: 2.4.0
// ============================================================================
// COPYRIGHT: © 2026 STELLANTIS N.V. - INTERNAL USE ONLY
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/stellantis_colors.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../providers/theme_provider.dart';
import '../providers/language_provider.dart';
import '../widgets/language_selector_widget.dart';
import 'login_page.dart';
import '../config/feature_flags.dart';
import 'audit_entry_page.dart';
import 'audit_history_page.dart';
import 'manager_history_page.dart';

/// SettingsPage - User Settings and Preferences Screen
///
/// This screen provides comprehensive settings and preferences management
/// for the Stellantis Dealer Hygiene App. Users can manage their profile,
/// customize app behavior, configure notifications, and access support.
///
/// Features:
/// - User profile card with edit functionality
/// - Account preferences (profile, language, dark mode)
/// - Audit and security settings (shift alerts, privacy)
/// - Support and help center access
/// - Logout functionality
/// - Bottom navigation for app-wide navigation
/// - Floating action button for quick actions
///
/// Settings Categories:
/// 1. Account & Preferences
///    - Profile update
///    - Language selection
///    - Dark mode toggle
///
/// 2. Audit & Security
///    - Shift alerts
///    - Privacy settings
///
/// 3. Support
///    - Help center
///    - About app information
///
/// Navigation:
/// - Logout → LoginPage (clears navigation stack)
/// - Dashboard → Returns to previous screen
/// - Bottom nav provides app-wide navigation
///
/// Usage:
/// ```dart
/// Navigator.push(
///   context,
///   MaterialPageRoute(builder: (context) => SettingsPage()),
/// )
/// ```
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

/// _SettingsPageState - Settings Page State Management
///
/// Manages settings preferences, UI state, and user interactions for the
/// settings screen. Handles profile display, preference toggles, and navigation.
class _SettingsPageState extends State<SettingsPage> {
  /// Service instances
  final AuthService _authService = AuthService();
  final StorageService _storageService = StorageService();

  bool _isManager = false;

  @override
  void initState() {
    super.initState();
    _checkUserRole();
  }

  void _checkUserRole() {
    final user = _authService.currentUser;
    // Simple check based on email or role if available.
    // For now, consistent with ManagerHomePage check:
    final email = (user?.email ?? '').trim().toLowerCase();
    if (email == 'debabratadas@stellantis.com') {
      _isManager = true;
    }
  }

  /// Handle logout
  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: StellantisColors.error,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _authService.logout();
      if (!mounted) return;

      // TEMP: If auth is bypassed, don't force navigation to LoginPage.
      if (FeatureFlags.bypassAuth) {
        Navigator.of(context).pop();
        return;
      }

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.only(left: 8.0, top: 8.0),
          child: Text(
            "Settings",
            style: TextStyle(
              color: Theme.of(context).textTheme.titleLarge?.color,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildProfileCard(),
            const SizedBox(height: 30),
            _buildSectionHeader("ACCOUNT & PREFERENCES"),
            _buildSettingsGroup([
              _buildSettingItem(
                Icons.person_outline,
                "Profile Update",
                StellantisColors.stellantisBlue,
                trailingText: "SOON",
                trailingColor: StellantisColors.textSecondary,
              ),
              Consumer<LanguageProvider>(
                builder: (context, languageProvider, child) {
                  return _buildSettingItem(
                    Icons.language,
                    "Language",
                    StellantisColors.stellantisBlue,
                    trailingText: languageProvider.displayText,
                    onTap: () => _showLanguageSelector(context),
                  );
                },
              ),
              Consumer<ThemeProvider>(
                builder: (context, themeProvider, child) {
                  return _buildSettingItem(
                    Icons.dark_mode_outlined,
                    "Dark Mode",
                    StellantisColors.gold,
                    isSwitch: true,
                    switchValue: themeProvider.isDarkMode,
                    onChanged: (val) => themeProvider.setDarkMode(val),
                  );
                },
              ),
            ]),
            const SizedBox(height: 30),
            _buildSectionHeader("AUDIT & SECURITY"),
            _buildSettingsGroup([
              _buildSettingItem(
                Icons.notifications_outlined,
                "Shift Alerts",
                StellantisColors.red,
              ),
              _buildSettingItem(
                Icons.lock_outline,
                "Privacy Settings",
                StellantisColors.success,
              ),
            ]),
            const SizedBox(height: 30),
            _buildSectionHeader("SUPPORT"),
            _buildSettingsGroup([
              _buildSettingItem(
                Icons.help_outline,
                "Help Center",
                StellantisColors.textSecondary,
              ),
              _buildSettingItem(
                Icons.info_outline,
                "About Audit App",
                StellantisColors.textSecondary,
              ),
            ]),
            const SizedBox(height: 40),
            _buildLogoutButton(),
            const SizedBox(height: 30),
            Center(
              child: Text(
                "Version 2.4.0 (Stellantis Production)",
                style: TextStyle(
                  color: StellantisColors.textLight,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
      // Hide FAB for Managers
      floatingActionButton: _isManager
          ? null
          : FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AuditEntryPage(),
                  ),
                );
              },
              backgroundColor: StellantisColors.stellantisBlue,
              elevation: 8,
              child: const Icon(
                Icons.add,
                size: 32,
                color: StellantisColors.textOnPrimary,
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  // ========== UI BUILDER METHODS ==========

  /// Build User Profile Card
  ///
  /// Displays user information including avatar, name, role, and edit button.
  /// Shows user's initials in a circular avatar with Stellantis brand colors.
  Widget _buildProfileCard() {
    final user = _authService.currentUser;
    final initials =
        user?.name.split(' ').map((n) => n[0]).take(2).join() ?? 'JD';
    final email = (user?.email ?? '').trim().toLowerCase();
    final useProfileImage = email == 'debabratadas@stellantis.com';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: StellantisColors.stellantisBlue,
              shape: BoxShape.circle,
            ),
            child: useProfileImage
                ? ClipOval(
                    child: Image.asset(
                      'assets/images/debabrata-das.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Text(
                            initials,
                            style: TextStyle(
                              color: StellantisColors.textOnPrimary,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
                  )
                : Center(
                    child: Text(
                      initials,
                      style: TextStyle(
                        color: StellantisColors.textOnPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
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
                  user?.name ?? "debabrata-das",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.facilityName ??
                      user?.email ??
                      "Stellantis Facility Manager",
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Edit",
                  style: TextStyle(
                    color: StellantisColors.stellantisBlue,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right,
                  color: StellantisColors.textSecondary,
                  size: 18,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build Section Header
  ///
  /// Creates styled section headers for organizing settings groups.
  /// Uses uppercase text with letter spacing for visual hierarchy.
  ///
  /// Parameters:
  /// - title: Section title text (e.g., "ACCOUNT & PREFERENCES")
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 10.0),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).textTheme.bodySmall?.color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  /// Build Settings Group Container
  ///
  /// Creates a card-style container that groups related settings items
  /// with proper spacing and dividers between items.
  ///
  /// Parameters:
  /// - items: List of setting item widgets to display in the group
  Widget _buildSettingsGroup(List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor, width: 1),
      ),
      child: Column(
        children: List.generate(items.length, (index) {
          return Column(
            children: [
              items[index],
              if (index != items.length - 1)
                Divider(
                  height: 1,
                  indent: 60,
                  color: Theme.of(context).dividerColor,
                ),
            ],
          );
        }),
      ),
    );
  }

  /// Build Individual Setting Item
  ///
  /// Creates a setting item with icon, title, and trailing content.
  /// Supports both navigation items and toggle switches.
  ///
  /// Parameters:
  /// - icon: Leading icon for the setting
  /// - title: Setting name/description
  /// - iconColor: Color for the icon and its background
  /// - trailingText: Optional text to show on the right (e.g., "English (US)")
  /// - trailingColor: Optional color for trailing text
  /// - isSwitch: Whether this item is a toggle switch
  /// - switchValue: Current switch state (required if isSwitch is true)
  /// - onChanged: Callback for switch value changes
  Widget _buildSettingItem(
    IconData icon,
    String title,
    Color iconColor, {
    String? trailingText,
    Color? trailingColor,
    bool isSwitch = false,
    bool? switchValue,
    Function(bool)? onChanged,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
      trailing: isSwitch
          ? Switch(
              value: switchValue!,
              onChanged: onChanged,
              activeTrackColor: StellantisColors.textSecondary,
              activeThumbColor: StellantisColors.white,
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (trailingText != null)
                  Text(
                    trailingText,
                    style: TextStyle(
                      color: trailingColor ?? StellantisColors.textSecondary,
                      fontSize: 14,
                      fontWeight: trailingColor != null
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                Icon(
                  Icons.chevron_right,
                  color: StellantisColors.cardBorder,
                  size: 20,
                ),
              ],
            ),
      onTap: isSwitch ? null : onTap,
    );
  }

  /// Show Language Selector Modal
  ///
  /// Opens a beautiful modal bottom sheet for language selection with
  /// all supported languages, flags, and descriptions.
  void _showLanguageSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const LanguageSelectorWidget(),
    );
  }

  /// Build Logout Button
  ///
  /// Creates a prominent logout button that navigates user back to login
  /// screen and clears the navigation stack for security.
  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _handleLogout,
        style: ElevatedButton.styleFrom(
          backgroundColor: StellantisColors.red.withValues(alpha: 0.1),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, color: StellantisColors.red),
            const SizedBox(width: 10),
            Text(
              "Log Out",
              style: TextStyle(
                color: StellantisColors.red,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build Bottom Navigation Bar
  ///
  /// Creates consistent bottom navigation matching dealer home pattern.
  /// Highlights the Settings tab as active.
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
                Navigator.pop(context);
              }),
              _navItem(Icons.bar_chart, "STATS", false, () {}),
              const SizedBox(width: 50),
              _navItem(Icons.history, "HISTORY", false, () {
                if (_isManager) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ManagerHistoryPage(),
                    ),
                  );
                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AuditHistoryPage(),
                    ),
                  );
                }
              }),
              _navItem(Icons.settings, "SETTINGS", true, () {}),
            ],
          ),
        ),
      ),
    );
  }

  /// Build Navigation Item
  ///
  /// Creates individual navigation items for the bottom bar with icon and label.
  ///
  /// Parameters:
  /// - icon: Navigation icon
  /// - label: Navigation label text
  /// - active: Whether this item is currently active
  /// - onTap: Tap callback
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

// ============================================================================
// END OF FILE: settings_page.dart
// ============================================================================
// AUTHOR: Rahul Raja
// WEBSITE: https://www.stellantis.com/
// ============================================================================
