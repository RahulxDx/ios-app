// ============================================================================
// FILE: advanced_search_widget.dart
// DESCRIPTION: Enterprise-level advanced search widget for facilities, zones,
//              and countries with real-time filtering and results display.
// ============================================================================
// PROJECT: Stellantis Dealer Hygiene App
// AUTHOR: AI Assistant
// WEBSITE: https://www.stellantis.com/
// VERSION: 1.0.0
// ============================================================================
// COPYRIGHT: © 2026 STELLANTIS N.V. - INTERNAL USE ONLY
// ============================================================================

import 'package:flutter/material.dart';
import '../models/facility.dart';
import '../constants/stellantis_colors.dart';

/// AdvancedSearchWidget - Enterprise-level search for compliance data
///
/// This widget provides a beautiful, enterprise-grade search interface for:
/// - Searching facilities by name, ID, or zone
/// - Searching zones by name or country
/// - Searching countries
/// - Real-time filtering with visual feedback
/// - Search history management
/// - Results preview with compliance metrics
///
/// Features:
/// - Navy Blue and Grey color scheme (per Stellantis brand guidelines)
/// - Real-time search with debouncing
/// - Search results with compliance indicators
/// - Clear search history
/// - Empty state handling
/// - Responsive design
///
/// Usage:
/// ```dart
/// AdvancedSearchWidget(
///   countries: _countriesData,
///   onFacilityTap: (facility) => navigateToFacility(facility),
///   onZoneTap: (zone) => navigateToZone(zone),
/// )
/// ```
class AdvancedSearchWidget extends StatefulWidget {
  /// List of all countries with their zones and facilities
  final List<CountryCompliance> countries;

  /// Callback when a facility is selected from search results
  final Function(FacilityCompliance) onFacilityTap;

  /// Callback when a zone is selected from search results
  final Function(ZoneCompliance, CountryCompliance) onZoneTap;

  const AdvancedSearchWidget({
    super.key,
    required this.countries,
    required this.onFacilityTap,
    required this.onZoneTap,
  });

  @override
  State<AdvancedSearchWidget> createState() => _AdvancedSearchWidgetState();
}

class _AdvancedSearchWidgetState extends State<AdvancedSearchWidget> {
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
  final TextEditingController _searchController = TextEditingController();
  List<SearchResult> _searchResults = [];
  List<String> _searchHistory = [];
  bool _isSearching = false;
  bool _showResults = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_performSearch);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Performs real-time search across all data
  void _performSearch() {
    final query = _searchController.text.trim().toLowerCase();

    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _showResults = false;
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    // Collect all search results
    List<SearchResult> results = [];

    // Search through countries
    for (final country in widget.countries) {
      if (country.countryName.toLowerCase().contains(query)) {
        results.add(SearchResult(
          type: SearchResultType.country,
          title: country.countryName,
          subtitle: '${country.totalZones} zones • ${country.totalFacilities} facilities',
          compliancePercentage: country.compliancePercentage,
          country: country,
        ));
      }

      // Search through zones
      for (final zone in country.zones) {
        if (zone.zoneName.toLowerCase().contains(query)) {
          results.add(SearchResult(
            type: SearchResultType.zone,
            title: zone.zoneName,
            subtitle: '${country.countryName} • ${zone.totalFacilities} facilities',
            compliancePercentage: zone.compliancePercentage,
            zone: zone,
            country: country,
          ));
        }

        // Search through facilities
        for (final facility in zone.facilities) {
          if (facility.facilityName.toLowerCase().contains(query) ||
              facility.facilityId.toLowerCase().contains(query)) {
            results.add(SearchResult(
              type: SearchResultType.facility,
              title: facility.facilityName,
              subtitle:
                  '${facility.facilityId} • ${zone.zoneName} • ${country.countryName}',
              compliancePercentage: facility.compliancePercentage,
              facility: facility,
              zone: zone,
              country: country,
            ));
          }
        }
      }
    }

    setState(() {
      _searchResults = results;
      _showResults = true;
      _isSearching = false;

      // Add to search history if not already present
      if (query.isNotEmpty && !_searchHistory.contains(query)) {
        _searchHistory.insert(0, query);
        if (_searchHistory.length > 10) _searchHistory.removeLast();
      }
    });
  }

  /// Get color indicator based on compliance percentage
  Color _getComplianceColor(double percentage) {
    if (percentage >= 85) return StellantisColors.success;
    if (percentage >= 70) return StellantisColors.warning;
    return StellantisColors.error;
  }

  /// Clear search and reset state
  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchResults = [];
      _showResults = false;
    });
  }

  /// Clear search history
  void _clearHistory() {
    setState(() => _searchHistory.clear());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ===================================================================
          // SEARCH INPUT FIELD
          // ===================================================================
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: _bgGrey,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _searchController.text.isNotEmpty ? _primaryNavy : _borderGrey,
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Icon(
                      Icons.search,
                      color: _primaryNavy,
                      size: 22,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(
                        color: _darkNavy,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search facilities, zones, countries...',
                        hintStyle: TextStyle(
                          color: _lightGrey.withValues(alpha: 0.6),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      textInputAction: TextInputAction.search,
                    ),
                  ),
                  if (_searchController.text.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: IconButton(
                        icon: const Icon(Icons.close, color: _lightGrey, size: 20),
                        onPressed: _clearSearch,
                        splashRadius: 20,
                      ),
                    ),
                  if (_isSearching)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(_primaryNavy),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ===================================================================
          // SEARCH RESULTS OR EMPTY STATE
          // ===================================================================
          if (_searchController.text.isEmpty && _searchHistory.isNotEmpty)
            _buildSearchHistory()
          else if (_showResults)
            _buildSearchResults()
          else if (_searchController.text.isNotEmpty && _searchResults.isEmpty)
            _buildNoResults(),
        ],
      ),
    );
  }

  /// Build search history section
  Widget _buildSearchHistory() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Searches',
                style: TextStyle(
                  color: _primaryNavy,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              GestureDetector(
                onTap: _clearHistory,
                child: Text(
                  'Clear',
                  style: TextStyle(
                    color: _lightGrey,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _searchHistory
                .map((query) => GestureDetector(
                      onTap: () {
                        _searchController.text = query;
                        _performSearch();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _bgGrey,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _borderGrey),
                        ),
                        child: Text(
                          query,
                          style: const TextStyle(
                            color: _lightGrey,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  /// Build search results list
  Widget _buildSearchResults() {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.5),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                '${_searchResults.length} result${_searchResults.length != 1 ? 's' : ''} found',
                style: TextStyle(
                  color: _lightGrey,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            const SizedBox(height: 8),
            ...List.generate(
              _searchResults.length,
              (index) => _buildSearchResultTile(_searchResults[index]),
            ),
          ],
        ),
      ),
    );
  }

  /// Build individual search result tile
  Widget _buildSearchResultTile(SearchResult result) {
    final color = _getComplianceColor(result.compliancePercentage);
    final icon = _getIconForType(result.type);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () {
          if (result.type == SearchResultType.facility && result.facility != null) {
            widget.onFacilityTap(result.facility!);
            _clearSearch();
          } else if (result.type == SearchResultType.zone &&
              result.zone != null &&
              result.country != null) {
            widget.onZoneTap(result.zone!, result.country!);
            _clearSearch();
          }
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _bgGrey,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _borderGrey),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _primaryNavy.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: _primaryNavy, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _darkNavy,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      result.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _lightGrey,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${result.compliancePercentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build no results state
  Widget _buildNoResults() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      child: Column(
        children: [
          Icon(
            Icons.search_off,
            size: 48,
            color: _lightGrey.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No results found',
            style: TextStyle(
              color: _primaryNavy,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try searching by facility name, zone, or country',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _lightGrey,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Get icon based on search result type
  IconData _getIconForType(SearchResultType type) {
    switch (type) {
      case SearchResultType.country:
        return Icons.public;
      case SearchResultType.zone:
        return Icons.location_on;
      case SearchResultType.facility:
        return Icons.business;
    }
  }
}

// ============================================================================
// SEARCH RESULT MODEL
// ============================================================================

/// Enum for search result types
enum SearchResultType { country, zone, facility }

/// Model for search results
class SearchResult {
  final SearchResultType type;
  final String title;
  final String subtitle;
  final double compliancePercentage;
  final CountryCompliance? country;
  final ZoneCompliance? zone;
  final FacilityCompliance? facility;

  SearchResult({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.compliancePercentage,
    this.country,
    this.zone,
    this.facility,
  });
}

// ============================================================================
// END OF FILE: advanced_search_widget.dart
// ============================================================================
// AUTHOR: AI Assistant
// WEBSITE: https://www.stellantis.com/
// ============================================================================

