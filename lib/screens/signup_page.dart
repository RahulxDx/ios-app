import 'package:flutter/material.dart';
import '../models/user_role.dart';
import '../services/auth_service.dart';
import 'dealer_home_page.dart';
import 'manager_home_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  // Colors close to the screenshot
  static const Color actionBlue = Color(0xFF003874);
  static const Color neutralGrey = Color(0xFF6C757D);
  static const Color scaffoldBg = Color(0xFFF8F9FA);
  static const Color borderColor = Color(0xFFDEE2E6);

  static const String _logoAsset = 'assets/images/stellantis_logo.png';

  // Form state
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _passwordVisible = false;
  bool _isLoading = false;

  UserRole _role = UserRole.dealerFacilities;
  String? _facilityLocation;

  final AuthService _authService = AuthService();

  final List<String> _facilityLocations = const [
    'Select location',
    'Detroit - Plant 1',
    'Auburn Hills - HQ',
    'Toledo - Assembly',
    'Windsor - Engine',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String get _pageTitle {
    switch (_role) {
      case UserRole.dealerFacilities:
        return 'Dealer Facilities\nRegistration';
      case UserRole.stellantisManager:
        return 'Stellantis Manager\nRegistration';
    }
  }

  String get _idOrEmailLabel {
    switch (_role) {
      case UserRole.dealerFacilities:
        return 'Employee ID or Email';
      case UserRole.stellantisManager:
        return 'Manager ID or Email';
    }
  }

  String get _idOrEmailHint {
    switch (_role) {
      case UserRole.dealerFacilities:
        return 'Enter ID or Email';
      case UserRole.stellantisManager:
        return 'Enter Manager ID or Email';
    }
  }

  String get _locationLabel {
    switch (_role) {
      case UserRole.dealerFacilities:
        return 'Facility Location';
      case UserRole.stellantisManager:
        return 'Office Location';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 28),
                _buildBrandMark(),
                const SizedBox(height: 26),

                Text(
                  _pageTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Facility Hygiene Audit System',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 26),
                _buildRoleDivider(),
                const SizedBox(height: 18),
                _buildRoleSelector(),

                const SizedBox(height: 26),
                _buildLabel('Full Name'),
                _buildTextField(
                  controller: _nameController,
                  hintText: 'e.g. John Doe',
                  textInputAction: TextInputAction.next,
                  validator: (v) {
                    if ((v ?? '').trim().isEmpty) return 'Please enter your name';
                    return null;
                  },
                ),

                const SizedBox(height: 18),
                _buildLabel(_idOrEmailLabel),
                _buildTextField(
                  controller: _emailController,
                  hintText: _idOrEmailHint,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (v) {
                    if ((v ?? '').trim().isEmpty) return 'Please enter your email/ID';
                    return null;
                  },
                ),

                const SizedBox(height: 18),
                _buildLabel(_locationLabel),
                _buildDropdown(),

                const SizedBox(height: 18),
                _buildLabel('Create Password'),
                _buildPasswordField(),

                const SizedBox(height: 22),
                _buildRegisterButton(),

                const SizedBox(height: 18),
                _buildBackToSignIn(context),

                const SizedBox(height: 34),
                Text(
                  'INTERNAL USE ONLY © 2026 STELLANTIS N.V. | V2.4.0',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 18),
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
            title: 'DEALER FACILITIES',
            icon: Icons.store_mall_directory,
            selected: _role == UserRole.dealerFacilities,
            onTap: () => setState(() => _role = UserRole.dealerFacilities),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _RoleCard(
            title: 'STELLANTIS MANAGER',
            icon: Icons.badge,
            selected: _role == UserRole.stellantisManager,
            onTap: () => setState(() => _role = UserRole.stellantisManager),
          ),
        ),
      ],
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

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Theme.of(context).dividerColor, width: 1.2),
      ),
      child: DropdownButtonFormField<String>(
        value: _facilityLocation ?? _facilityLocations.first,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        decoration: InputDecoration(
          border: InputBorder.none,
          labelStyle: Theme.of(context).textTheme.bodySmall,
        ),
        items: _facilityLocations.map((location) {
          return DropdownMenuItem(value: location, child: Text(location));
        }).toList(),
        onChanged: (val) => setState(() => _facilityLocation = val),
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

  Widget _buildRegisterButton() {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleRegister,
        style: ElevatedButton.styleFrom(
          backgroundColor: actionBlue,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                'Register',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Future<void> _handleRegister() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    if (_facilityLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a facility location'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        role: _role,
        facilityId: 'facility_${DateTime.now().millisecondsSinceEpoch}',
        facilityName: _facilityLocation,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration successful!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to appropriate home screen
      if (_role == UserRole.dealerFacilities) {
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration failed: ${e.toString()}'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildBackToSignIn(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Already have an account? ',
          style: TextStyle(
            color: neutralGrey,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.of(context).maybePop(),
          child: const Text(
            'Back to Sign In',
            style: TextStyle(
              color: actionBlue,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
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
              Icon(icon, color: iconColor, size: 26),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
/*
 * ========================================================================
 * End of signup_page.dart
 * Author: Rahul Raja
 * Website: https://www.stellantis.com/
 * ========================================================================
 */
