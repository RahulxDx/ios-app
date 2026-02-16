// ============================================================================
// FILE: custom_dropdown.dart
// DESCRIPTION: Reusable dropdown form field component with consistent styling and validation.
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

/// A customized dropdown widget with consistent brand styling.
/// 
/// This widget provides a reusable dropdown component that follows
/// the Stellantis design system and includes:
/// - Optional label above the dropdown
/// - Validation support
/// - Consistent border styling (enabled, focused, error states)
/// - Brand color integration
/// - Form integration support
/// 
/// The dropdown automatically handles placeholder text styling,
/// showing items in grey when they represent placeholder values
/// like "Select location".
/// 
/// Usage Example:
/// ```dart
/// CustomDropdown(
///   label: 'Select Facility',
///   value: selectedValue,
///   items: ['Option 1', 'Option 2', 'Option 3'],
///   onChanged: (value) => setState(() => selectedValue = value),
///   validator: (value) => value == null ? 'Required' : null,
/// )
/// ```
/// 
/// TODO: Add search/filter functionality for long item lists
/// TODO: Support custom item builders for complex items
/// TODO: Add icons/leading widgets to dropdown items
class CustomDropdown extends StatelessWidget {
  /// Optional label displayed above the dropdown
  final String? label;
  
  /// Currently selected value (must be one of [items])
  final String? value;
  
  /// List of options to display in the dropdown
  final List<String> items;
  
  /// Callback invoked when selection changes
  final void Function(String?)? onChanged;
  
  /// Optional validation function for form validation
  final String? Function(String?)? validator;

  const CustomDropdown({
    super.key,
    this.label,
    required this.value,
    required this.items,
    this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ===============================================================
        // OPTIONAL LABEL
        // ===============================================================
        // Displays label text above the dropdown if provided
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              label!,
              style: AppTextStyles.bodyBold,
            ),
          ),
        
        // ===============================================================
        // DROPDOWN FORM FIELD
        // ===============================================================
        // Main dropdown component with custom styling
        DropdownButtonFormField<String>(
          initialValue: value,
          validator: validator,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 18,
            ),
            
            // =========================================================
            // BORDER STYLES
            // =========================================================
            // Different borders for different states
            
            // Default/enabled state border
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.borderColor),
            ),
            
            // Focused state border (when user interacts)
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
          
          // =========================================================
          // DROPDOWN ITEMS
          // =========================================================
          // Build dropdown menu items from the provided list
          // Placeholder items (like "Select location") are styled grey
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: AppTextStyles.bodyRegular.copyWith(
                  // Grey color for placeholder-style items
                  color: item == 'Select location' ? AppColors.neutralGrey : Colors.black,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

// ============================================================================
// END OF FILE: custom_dropdown.dart
// ============================================================================
// AUTHOR: Rohith U
// WEBSITE: https://www.stellantis.com/
// ============================================================================
