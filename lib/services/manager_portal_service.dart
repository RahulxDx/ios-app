// ============================================================================
// FILE: manager_portal_service.dart
// DESCRIPTION: Service for fetching Manager Portal dashboard data from backend
// ============================================================================
// PROJECT: Stellantis Dealer Hygiene App
// AUTHOR: Srikanth Thiygarajan
// WEBSITE: https://www.stellantis.com/
// VERSION: 1.0.0
// ============================================================================
// COPYRIGHT: © 2026 STELLANTIS N.V. - INTERNAL USE ONLY
// ============================================================================

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/facility.dart';

/// Service for Manager Portal operations
///
/// Handles:
/// - Dashboard data retrieval from backend
/// - Aggregated compliance data by country/zone/facility
/// - API communication with error handling
class ManagerPortalService {
  // Singleton pattern
  static final ManagerPortalService _instance =
      ManagerPortalService._internal();
  factory ManagerPortalService() => _instance;
  ManagerPortalService._internal();

  /// Fetch complete Manager Portal dashboard data
  ///
  /// Returns hierarchical compliance data from manual_audits table:
  /// - Country → Zone → Facility structure
  /// - Calculated compliance percentages
  /// - Audit counts and statistics
  Future<List<CountryCompliance>> getDashboardData() async {
    try {
      // Get base URL (will use localhost for development)
      final baseUrl = await ApiConfig.getBaseUrl();
      final url = Uri.parse('$baseUrl${ApiConfig.apiPrefix}/manager/dashboard');

      print('📊 Fetching Manager Portal dashboard from: $url');

      // Make GET request
      final response = await http
          .get(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception(
                'Request timeout - Please check if backend is running',
              );
            },
          );

      print('📡 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('✅ Manager Portal data fetched successfully');
        print('📄 Response: ${response.body}');

        // Parse countries data
        final List<dynamic> countriesJson = responseData['countries'] ?? [];

        return countriesJson.map((countryJson) {
          // Parse zones
          final List<dynamic> zonesJson = countryJson['zones'] ?? [];
          final zones = zonesJson.map((zoneJson) {
            // Parse facilities
            final List<dynamic> facilitiesJson = zoneJson['facilities'] ?? [];
            final facilities = facilitiesJson.map((facilityJson) {
              return FacilityCompliance(
                facilityId: facilityJson['facility_id'] ?? '',
                facilityName: facilityJson['facility_name'] ?? '',
                compliancePercentage:
                    (facilityJson['compliance_percentage'] ?? 0).toDouble(),
                totalAudits: facilityJson['total_audits'] ?? 0,
                completedAudits: facilityJson['completed_audits'] ?? 0,
                pendingAudits: facilityJson['pending_audits'] ?? 0,
                lastAuditDate: DateTime.parse(
                  facilityJson['last_audit_date'] ??
                      DateTime.now().toIso8601String(),
                ),
                zone: facilityJson['zone'] ?? '',
              );
            }).toList();

            return ZoneCompliance(
              zoneName: zoneJson['zone_name'] ?? '',
              compliancePercentage: (zoneJson['compliance_percentage'] ?? 0)
                  .toDouble(),
              totalFacilities: zoneJson['total_facilities'] ?? 0,
              facilities: facilities,
            );
          }).toList();

          return CountryCompliance(
            countryName: countryJson['country_name'] ?? '',
            compliancePercentage: (countryJson['compliance_percentage'] ?? 0)
                .toDouble(),
            totalZones: countryJson['total_zones'] ?? 0,
            totalFacilities: countryJson['total_facilities'] ?? 0,
            zones: zones,
          );
        }).toList();
      } else {
        final errorData = json.decode(response.body);
        throw Exception(
          errorData['detail'] ?? 'Failed to fetch dashboard data',
        );
      }
    } catch (e) {
      print('❌ Error fetching Manager Portal data: $e');
      rethrow;
    }
  }

  /// Test backend connectivity
  ///
  /// Checks if Manager Portal endpoints are available
  Future<bool> testConnection() async {
    try {
      final baseUrl = await ApiConfig.getBaseUrl();
      final url = Uri.parse('$baseUrl/health');

      final response = await http.get(url).timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      print('Backend not available: $e');
      return false;
    }
  }

  /// Refresh dashboard data
  ///
  /// Same as getDashboardData but provides semantic clarity
  /// for UI refresh operations
  Future<List<CountryCompliance>> refreshDashboard() async {
    print('🔄 Refreshing Manager Portal dashboard...');
    return await getDashboardData();
  }

  /// Get recent audits for Manager History
  ///
  /// Fetches recent audits based on the provided duration (e.g., 1h, 24h).
  /// Currently returns an EMPTY LIST as per requirements, ready for backend integration.
  ///
  /// TODO: Implement backend call: GET /api/v1/manager/audits/recent?duration={duration}
  Future<List<Map<String, dynamic>>> getRecentAudits(Duration duration) async {
    try {
      // 1. Fetch full dashboard data (existing endpoint)
      final countries = await getDashboardData();
      final List<Map<String, dynamic>> audits = [];

      // 2. Extract "Last Audit" info from each facility
      for (var country in countries) {
        for (var zone in country.zones) {
          for (var facility in zone.facilities) {
            // Only include if lastAuditDate is valid (not default epoch)
            if (facility.lastAuditDate.year > 2000) {
              audits.add({
                'dealer_name': facility.facilityName,
                'zone': zone.zoneName,
                'time': _formatTimeAgo(facility.lastAuditDate),
                'timestamp': facility.lastAuditDate, // For sorting/filtering
                'score': facility.compliancePercentage.toInt(),
                'status': _determineStatus(facility.compliancePercentage),
              });
            }
          }
        }
      }

      // 3. Sort by newest first
      audits.sort(
        (a, b) =>
            (b['timestamp'] as DateTime).compareTo(a['timestamp'] as DateTime),
      );

      // 4. Filter by duration
      final cutoff = DateTime.now().subtract(duration);
      final filtereddAudits = audits.where((audit) {
        final timestamp = audit['timestamp'] as DateTime;
        return timestamp.isAfter(cutoff);
      }).toList();

      return filtereddAudits;
    } catch (e) {
      print('Error getting recent audits from dashboard data: $e');
      throw Exception('Failed to load history: $e');
    }
  }

  String _determineStatus(double score) {
    if (score >= 90) return 'Compliant';
    if (score < 50) return 'Non-Compliant';
    return 'Review Needed';
  }

  String _formatTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }
}
