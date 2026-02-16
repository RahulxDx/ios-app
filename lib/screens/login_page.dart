// ============================================================================
// FILE: login_page.dart
// DESCRIPTION: Login and authentication screen for the Stellantis Dealer
//              Hygiene App. Provides role-based login for both dealer
//              facilities employees and Stellantis managers with dynamic
//              UI that adapts based on selected user role.
// ============================================================================
// PROJECT: Stellantis Dealer Hygiene App
// AUTHOR: Rahul Raja
// WEBSITE: https://www.stellantis.com/
// VERSION: 2.4.0
// ============================================================================
// COPYRIGHT: © 2026 STELLANTIS N.V. - INTERNAL USE ONLY
// ============================================================================

import 'package:flutter/material.dart';
import '../models/user_role.dart';
import '../services/auth_service.dart';
import 'signup_page.dart';
import 'dealer_home_page.dart';
import 'manager_home_page.dart';

/// LoginPage - Role-Based Authentication Screen
///
/// This screen provides authentication functionality for two user types:
/// - Dealer Facilities Employees
/// - Stellantis Managers
///
/// Features:
/// - Dynamic UI that changes based on selected role
/// - Role selector with visual cards
/// - Email/ID and password input fields
/// - Password visibility toggle
/// - Form validation
/// - Navigation to appropriate home page based on role
/// - Link to signup page for new users
/// - Forgot password functionality
///
/// Navigation:
/// - Dealer Login → DealerHomePage
/// - Manager Login → ManagerHomePage
/// - Signup Link → SignupPage
///
/// Usage:
/// ```dart
/// Navigator.push(
///   context,
///   MaterialPageRoute(builder: (context) => LoginPage()),
/// )
/// ```
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

/// _LoginPageState - Login Page State Management
///
/// Manages form state, validation, and user interactions for the login screen.
/// Handles dynamic content based on selected user role.
class _LoginPageState extends State<LoginPage> {
  // ========== COLOR CONSTANTS ==========

  /// Action navy color for interactive elements
  static const Color actionBlue = Color(0xFF003874);

  /// Neutral grey for secondary text and labels
  static const Color neutralGrey = Color(0xFF6C757D);

  /// Background color for the screen
  static const Color scaffoldBg = Color(0xFFF8F9FA);

  /// Border color for input fields and dividers
  static const Color borderColor = Color(0xFFDEE2E6);

  // ========== ASSET PATHS ==========

  /// Path to Stellantis logo asset
  static const String _logoAsset = 'assets/images/stellantis_logo.png';

  // ========== FORM STATE ==========

  /// Form key for validation
  final _formKey = GlobalKey<FormState>();

  /// Email/ID input controller
  final _emailController = TextEditingController();

  /// Password input controller
  final _passwordController = TextEditingController();

  /// Password visibility toggle state
  bool _passwordVisible = false;

  /// Currently selected user role (default: Dealer Facilities)
  UserRole _selectedRole = UserRole.dealerFacilities;

  /// Authentication service instance
  final AuthService _authService = AuthService();

  /// Loading state for login process
  bool _isLoading = false;

  @override
  void dispose() {
    // Clean up controllers to prevent memory leaks
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ========== DYNAMIC CONTENT GETTERS ==========

  /// Get page title based on selected role
  String get _pageTitle {
    switch (_selectedRole) {
      case UserRole.dealerFacilities:
        return 'Dealer Facilities\nLogin';
      case UserRole.stellantisManager:
        return 'Stellantis Manager\nLogin';
    }
  }

  /// Get email/ID label based on selected role
  String get _idOrEmailLabel {
    switch (_selectedRole) {
      case UserRole.dealerFacilities:
        return 'Employee ID or Email';
      case UserRole.stellantisManager:
        return 'Manager ID or Email';
    }
  }

  /// Get email/ID hint text based on selected role
  String get _idOrEmailHint {
    switch (_selectedRole) {
      case UserRole.dealerFacilities:
        return 'Enter your ID or Email';
      case UserRole.stellantisManager:
        return 'Enter Manager ID or Email';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 50),
                _buildBrandMark(),
                const SizedBox(height: 40),

                Text(
                  _pageTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
                const SizedBox(height: 8),

                const SizedBox(height: 40),
                _buildLabel(_idOrEmailLabel),
                _buildTextField(
                  controller: _emailController,
                  hintText: _idOrEmailHint,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (v) {
                    if ((v ?? '').trim().isEmpty) return 'Please enter your ID/Email';
                    return null;
                  },
                ),

                const SizedBox(height: 20),
                _buildLabel('Password'),
                _buildPasswordField(),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text(
                      "Forgot Password?",
                      style: TextStyle(color: actionBlue, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),

                const SizedBox(height: 10),
                _buildSignInButton(),
                const SizedBox(height: 40),
                _buildRoleDivider(),
                const SizedBox(height: 18),
                _buildRoleSelector(),
                const SizedBox(height: 60),
                _buildFooter(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrandMark() {
    return Center(
      child: Image.asset(
        _logoAsset,
        width: 190,
        height: 44,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Text(
            'STELLANTIS',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          );
        },
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 16,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    String? Function(String?)? validator,
  }) {
    final textColor = Theme.of(context).colorScheme.onSurface;
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      style: TextStyle(color: textColor),
      cursorColor: textColor,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: Theme.of(context).textTheme.bodySmall?.color,
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: Theme.of(context).cardTheme.color,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Theme.of(context).dividerColor, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: actionBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    final textColor = Theme.of(context).colorScheme.onSurface;
    return TextFormField(
      controller: _passwordController,
      obscureText: !_passwordVisible,
      textInputAction: TextInputAction.done,
      style: TextStyle(color: textColor),
      cursorColor: textColor,
      validator: (v) {
        if ((v ?? '').trim().isEmpty) return 'Please enter your password';
        return null;
      },
      decoration: InputDecoration(
        hintText: 'Enter your password',
        hintStyle: TextStyle(
          color: Theme.of(context).textTheme.bodySmall?.color,
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: Theme.of(context).cardTheme.color,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        suffixIcon: IconButton(
          onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
          icon: Icon(
            _passwordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: neutralGrey,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Theme.of(context).dividerColor, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: actionBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
      ),
    );
  }

  Widget _buildSignInButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: actionBlue,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          disabledBackgroundColor: actionBlue.withValues(alpha: 0.6),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                "Sign In",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  /// Handle login button press
  Future<void> _handleLogin() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Attempt login
      await _authService.login(
        emailOrId: _emailController.text.trim(),
        password: _passwordController.text,
        role: _selectedRole,
      );

      if (!mounted) return;

      // Navigate to appropriate home screen based on role
      if (_selectedRole == UserRole.dealerFacilities) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DealerHomePage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ManagerHomePage()),
        );
      }
    } catch (e) {
      if (!mounted) return;

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildRoleDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Theme.of(context).dividerColor, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            'SELECT USER ROLE',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodySmall?.color,
              fontSize: 12,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(child: Divider(color: Theme.of(context).dividerColor, thickness: 1)),
      ],
    );
  }

  Widget _buildRoleSelector() {
    return Row(
      children: [
        Expanded(
          child: _RoleCard(
            title: "DEALER FACILITIES",
            icon: Icons.store_mall_directory,
            selected: _selectedRole == UserRole.dealerFacilities,
            onTap: () => setState(() => _selectedRole = UserRole.dealerFacilities),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _RoleCard(
            title: "STELLANTIS MANAGER",
            icon: Icons.badge,
            selected: _selectedRole == UserRole.stellantisManager,
            onTap: () => setState(() => _selectedRole = UserRole.stellantisManager),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Don't have an account? ",
              style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontWeight: FontWeight.w500, fontSize: 16),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignupPage()),
                );
              },
              child: const Text(
                "Sign Up",
                style: TextStyle(color: actionBlue, fontWeight: FontWeight.w800, fontSize: 16),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          "INTERNAL USE ONLY © 2026 STELLANTIS N.V. | V2.4.0",
          style: TextStyle(
            color: Theme.of(context).textTheme.bodySmall?.color,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.title,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  static const Color actionBlue = Color(0xFF003874);
  static const Color neutralGrey = Color(0xFF6C757D);
  static const Color borderColor = Color(0xFFDEE2E6);

  @override
  Widget build(BuildContext context) {
    final baseBg = Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface;
    final selectedBg = Theme.of(context).colorScheme.primary.withValues(alpha: 0.08);
    final border = selected ? Theme.of(context).colorScheme.primary : Theme.of(context).dividerColor;
    final iconColor = selected ? Theme.of(context).colorScheme.primary : (Theme.of(context).textTheme.bodySmall?.color ?? neutralGrey);
    final textColor = selected ? Theme.of(context).colorScheme.primary : (Theme.of(context).textTheme.bodySmall?.color ?? neutralGrey);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        splashColor: actionBlue.withValues(alpha: 0.2),
        highlightColor: actionBlue.withValues(alpha: 0.1),
        child: Ink(
          height: 110,
          decoration: BoxDecoration(
            color: selected ? selectedBg : baseBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: border, width: selected ? 2.5 : 2),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: actionBlue.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: iconColor, size: 32),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// END OF FILE: login_page.dart
// ============================================================================
// AUTHOR: Rahul Raja
// WEBSITE: https://www.stellantis.com/
// ============================================================================
