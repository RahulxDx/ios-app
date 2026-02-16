// ============================================================================
// FILE: language_selector_widget.dart
// DESCRIPTION: Beautiful enterprise-level language selection modal widget
//              for Stellantis Dealer Hygiene App with Navy Blue/Grey theme.
// ============================================================================
// PROJECT: Stellantis Dealer Hygiene App
// AUTHOR: AI Assistant
// WEBSITE: https://www.stellantis.com/
// VERSION: 1.0.0
// ============================================================================
// COPYRIGHT: © 2026 STELLANTIS N.V. - INTERNAL USE ONLY
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/language_model.dart';
import '../providers/language_provider.dart';
import '../constants/stellantis_colors.dart';

/// LanguageSelectorWidget - Enterprise-level language selection modal
///
/// This widget provides a beautiful modal bottom sheet for language selection
/// with the following features:
/// - Navy Blue and Grey color scheme (Stellantis brand)
/// - Radio button selection
/// - Flag emojis for visual identification
/// - Language descriptions in native language
/// - Apply/Cancel buttons
/// - Smooth animations
/// - Responsive design
///
/// Usage:
/// ```dart
/// showModalBottomSheet(
///   context: context,
///   isScrollControlled: true,
///   backgroundColor: Colors.transparent,
///   builder: (context) => LanguageSelectorWidget(),
/// );
/// ```
class LanguageSelectorWidget extends StatefulWidget {
  const LanguageSelectorWidget({super.key});

  @override
  State<LanguageSelectorWidget> createState() => _LanguageSelectorWidgetState();
}

class _LanguageSelectorWidgetState extends State<LanguageSelectorWidget> {
  // =========================================================================
  // DESIGN COLORS - ENTERPRISE NAVY BLUE & GREY SCHEME
  // =========================================================================
  static const Color _primaryNavy = Color(0xFF003874);
  static const Color _darkNavy = Color(0xFF0C2340);
  static const Color _lightGrey = Color(0xFF6C757D);
  static const Color _borderGrey = Color(0xFFE0E0E0);
  static const Color _bgGrey = Color(0xFFF8F9FA);
  static const Color _white = Color(0xFFFFFFFF);

  // =========================================================================
  // STATE VARIABLES
  // =========================================================================
  Language? _selectedLanguage;
  final TextEditingController _searchController = TextEditingController();
  List<Language> _filteredLanguages = SupportedLanguages.all;

  @override
  void initState() {
    super.initState();
    // Initialize with current language
    _selectedLanguage = context.read<LanguageProvider>().currentLanguage;
    _searchController.addListener(_filterLanguages);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Filter languages based on search query
  void _filterLanguages() {
    final query = _searchController.text.trim();
    setState(() {
      _filteredLanguages = SupportedLanguages.search(query);
    });
  }

  /// Apply language selection
  void _applyLanguage() {
    if (_selectedLanguage != null) {
      context.read<LanguageProvider>().setLanguage(_selectedLanguage!);
      Navigator.pop(context);

      // Show confirmation snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Language changed to ${_selectedLanguage!.name}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: _primaryNavy,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ===================================================================
          // HEADER
          // ===================================================================
          _buildHeader(),

          // ===================================================================
          // SEARCH FIELD (Optional - can be shown/hidden)
          // ===================================================================
          if (_filteredLanguages.length > 3) _buildSearchField(),

          // ===================================================================
          // LANGUAGE LIST
          // ===================================================================
          _buildLanguageList(),

          // ===================================================================
          // ACTION BUTTONS
          // ===================================================================
          _buildActionButtons(),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  /// Build modal header
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: _borderGrey, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SELECT LANGUAGE',
                  style: TextStyle(
                    color: _primaryNavy,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Choose your preferred language',
                  style: TextStyle(
                    color: _lightGrey,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: _lightGrey, size: 24),
            onPressed: () => Navigator.pop(context),
            splashRadius: 24,
          ),
        ],
      ),
    );
  }

  /// Build search field
  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Container(
        decoration: BoxDecoration(
          color: _bgGrey,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _borderGrey, width: 1),
        ),
        child: TextField(
          controller: _searchController,
          style: TextStyle(
            color: _darkNavy,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: 'Search languages...',
            hintStyle: TextStyle(
              color: _lightGrey.withValues(alpha: 0.6),
              fontSize: 14,
            ),
            prefixIcon: Icon(Icons.search, color: _primaryNavy, size: 20),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ),
    );
  }

  /// Build language list
  Widget _buildLanguageList() {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.5,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: _filteredLanguages.isEmpty
              ? [_buildNoResults()]
              : _filteredLanguages
                  .map((language) => _buildLanguageTile(language))
                  .toList(),
        ),
      ),
    );
  }

  /// Build individual language tile
  Widget _buildLanguageTile(Language language) {
    final isSelected = _selectedLanguage?.code == language.code;
    final isCurrent = context.read<LanguageProvider>().isLanguageSelected(language);

    return InkWell(
      onTap: () {
        setState(() {
          _selectedLanguage = language;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? _primaryNavy.withValues(alpha: 0.05) : Colors.transparent,
          border: Border(
            left: BorderSide(
              color: isSelected ? _primaryNavy : Colors.transparent,
              width: 4,
            ),
          ),
        ),
        child: Row(
          children: [
            // Flag emoji
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _bgGrey,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? _primaryNavy : _borderGrey,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Center(
                child: Text(
                  language.flag,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Language info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        language.name,
                        style: TextStyle(
                          color: isSelected ? _primaryNavy : _darkNavy,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (isCurrent) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: StellantisColors.success.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'CURRENT',
                            style: TextStyle(
                              color: StellantisColors.success,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    language.subtitle,
                    style: TextStyle(
                      color: _lightGrey,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Radio button
            Radio<String>(
              value: language.code,
              groupValue: _selectedLanguage?.code,
              activeColor: _primaryNavy,
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = language;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Build no results state
  Widget _buildNoResults() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(
            Icons.search_off,
            size: 48,
            color: _lightGrey.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 12),
          Text(
            'No languages found',
            style: TextStyle(
              color: _primaryNavy,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Try a different search term',
            style: TextStyle(
              color: _lightGrey,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  /// Build action buttons (Cancel and Apply)
  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: _borderGrey, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Cancel button
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: _borderGrey, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'CANCEL',
                style: TextStyle(
                  color: _lightGrey,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Apply button
          Expanded(
            child: ElevatedButton(
              onPressed: _selectedLanguage != null ? _applyLanguage : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryNavy,
                disabledBackgroundColor: _lightGrey.withValues(alpha: 0.3),
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'APPLY',
                style: TextStyle(
                  color: _white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// END OF FILE: language_selector_widget.dart
// ============================================================================
// AUTHOR: AI Assistant
// WEBSITE: https://www.stellantis.com/
// ============================================================================

