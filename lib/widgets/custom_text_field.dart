// ============================================================================
// FILE: custom_text_field.dart
// DESCRIPTION: Reusable text input field with password visibility toggle and validation support.
// ============================================================================
// PROJECT: Stellantis Dealer Hygiene App
// AUTHOR: Rohith U
// WEBSITE: https://www.stellantis.com/
// VERSION: 1.0.0
// ============================================================================
// COPYRIGHT: © 2026 STELLANTIS N.V. - INTERNAL USE ONLY
// ============================================================================

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

/// A customized text field widget with consistent brand styling.
/// 
/// This widget provides a reusable text input component that includes:
/// - Optional label above the input field
/// - Password visibility toggle for secure text entry
/// - Form validation support
/// - Consistent border styling for all states
/// - Customizable keyboard type and input actions
/// - Brand color integration
/// 
/// The widget is stateful to manage password visibility state.
/// 
/// Features:
/// - Automatic password masking with toggle button
/// - Visual state feedback (enabled, focused, error)
/// - Form integration with validation
/// - Flexible keyboard configuration
/// 
/// Usage Example:
/// ```dart
/// CustomTextField(
///   label: 'Email',
///   hint: 'Enter your email',
///   controller: emailController,
///   keyboardType: TextInputType.emailAddress,
///   validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
/// )
/// ```
/// 
/// TODO: Add character counter for fields with max length
/// TODO: Support prefix icons
/// TODO: Add auto-fill hints for better UX
class CustomTextField extends StatefulWidget {
  /// Optional label displayed above the text field
  final String? label;
  
  /// Placeholder text shown when field is empty
  final String hint;
  
  /// Whether this field contains password (enables visibility toggle)
  final bool isPassword;
  
  /// Optional controller for managing the text value
  final TextEditingController? controller;
  
  /// Optional validation function for form validation
  final String? Function(String?)? validator;
  
  /// Keyboard type to display (email, number, etc.)
  final TextInputType? keyboardType;
  
  /// Action button on keyboard (next, done, search, etc.)
  final TextInputAction? textInputAction;

  const CustomTextField({
    super.key,
    this.label,
    required this.hint,
    this.isPassword = false,
    this.controller,
    this.validator,
    this.keyboardType,
    this.textInputAction,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

/// Private state class managing password visibility toggle.
class _CustomTextFieldState extends State<CustomTextField> {
  /// Tracks whether password is currently visible
  /// Starts as false (password hidden) for security
  bool _passwordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ===============================================================
        // OPTIONAL LABEL
        // ===============================================================
        // Displays label text above the input if provided
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              widget.label!,
              style: AppTextStyles.bodyBold,
            ),
          ),
        
        // ===============================================================
        // TEXT FORM FIELD
        // ===============================================================
        // Main input field with custom styling
        TextFormField(
          controller: widget.controller,
          // Obscure text only for password fields when visibility is off
          obscureText: widget.isPassword && !_passwordVisible,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          validator: widget.validator,
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: AppTextStyles.hint,
            filled: true,
            fillColor: AppColors.white,
            
            // =========================================================
            // SUFFIX ICON (PASSWORD VISIBILITY TOGGLE)
            // =========================================================
            // Shows visibility toggle button only for password fields
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      // Toggle icon based on visibility state
                      _passwordVisible
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.neutralGrey,
                    ),
                    onPressed: () {
                      // Toggle password visibility state
                      setState(() {
                        _passwordVisible = !_passwordVisible;
                      });
                    },
                  )
                : null,
            
            // Content padding for comfortable touch targets
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 18,
            ),
            
            // =========================================================
            // BORDER STYLES
            // =========================================================
            // Different borders for different interaction states
            
            // Default/enabled state border
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.borderColor),
            ),
            
            // Focused state border (when user is typing)
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: AppColors.actionBlue,
                width: 2,
              ),
            ),
            
            // Error state border (validation failed)
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 1,
              ),
            ),
            
            // Focused error border (user interacting with invalid field)
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// END OF FILE: custom_text_field.dart
// ============================================================================
// AUTHOR: Rohith U
// WEBSITE: https://www.stellantis.com/
// ============================================================================
