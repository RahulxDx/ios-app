// ============================================================================
// FILE: facility.dart
// DESCRIPTION: Data model for facilities and their compliance aggregation.
// ============================================================================
// PROJECT: Stellantis Dealer Hygiene App
// AUTHOR: Rohith U
// WEBSITE: https://www.stellantis.com/
// VERSION: 1.0.0
// ============================================================================
// COPYRIGHT: © 2026 STELLANTIS N.V. - INTERNAL USE ONLY
// ============================================================================

/// Represents a physical facility (e.g., Dealer, Workshop) within the system.
class Facility {
  final String id;
  final String name;
  final String location;
  final String address;
  final String zone;
  final String country;
  final String contactPerson;
  final String contactEmail;
  final String contactPhone;
  final double monthlyComplianceTarget;
  final List<String> assignedEmployees;

  Facility({
    required this.id,
    required this.name,
    required this.location,
    required this.address,
    required this.zone,
    required this.country,
    required this.contactPerson,
    required this.contactEmail,
    required this.contactPhone,
    this.monthlyComplianceTarget = 95.0,
    this.assignedEmployees = const [],
  });
  
  // TODO: Add validation logic for email and phone number format.
  // TODO: Add JSON serialization (fromJson, toJson).
}

/// Aggregated compliance data for a specific facility.
class FacilityCompliance {
  final String facilityId;
  final String facilityName;
  final double compliancePercentage;
  final int totalAudits;
  final int completedAudits;
  final int pendingAudits;
  final DateTime lastAuditDate;
  final String zone;

  FacilityCompliance({
    required this.facilityId,
    required this.facilityName,
    required this.compliancePercentage,
    required this.totalAudits,
    required this.completedAudits,
    required this.pendingAudits,
    required this.lastAuditDate,
    required this.zone,
  });
}

/// Aggregated compliance data for a zone (group of facilities).
class ZoneCompliance {
  final String zoneName;
  final double compliancePercentage;
  final int totalFacilities;
  final List<FacilityCompliance> facilities;

  ZoneCompliance({
    required this.zoneName,
    required this.compliancePercentage,
    required this.totalFacilities,
    required this.facilities,
  });
}

/// Aggregated compliance data for a country (group of zones).
class CountryCompliance {
  final String countryName;
  final double compliancePercentage;
  final int totalZones;
  final int totalFacilities;
  final List<ZoneCompliance> zones;

  CountryCompliance({
    required this.countryName,
    required this.compliancePercentage,
    required this.totalZones,
    required this.totalFacilities,
    required this.zones,
  });
}

// ============================================================================
// END OF FILE: facility.dart
// ============================================================================
// AUTHOR: Rohith U
// WEBSITE: https://www.stellantis.com/
// ============================================================================

