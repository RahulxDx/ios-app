// ============================================================================
// FILE: sample_data.dart
// DESCRIPTION: Sample data provider for the Stellantis Dealer Hygiene App.
//              This file contains mock/demo data for audits, facilities,
//              compliance metrics, and organizational hierarchies used for
//              testing and demonstration purposes.
// ============================================================================
// PROJECT: Stellantis Dealer Hygiene App
// AUTHOR: Rahul Raja
// WEBSITE: https://www.stellantis.com/
// VERSION: 2.4.0
// ============================================================================
// COPYRIGHT: © 2026 STELLANTIS N.V. - INTERNAL USE ONLY
// ============================================================================

import '../models/audit.dart';
import '../models/facility.dart';

/// SampleData - Mock Data Provider
///
/// This class provides sample data for the Stellantis Dealer Hygiene App,
/// including audit levels, facilities, compliance metrics, and organizational
/// structures. This data is used for development, testing, and demonstrations.
///
/// Available Data:
/// - Audit Levels: 4 levels with subcategories and checkpoints
/// - Facilities: Sample dealership and plant locations
/// - Current Audits: In-progress audit data for dealers
/// - Manager Data: Country/zone/facility compliance hierarchy
///
/// Data Categories:
/// 1. Exterior Cleanliness (Parking, Building, Landscaping)
/// 2. Showroom & Customer Areas (Reception, Showroom, Restrooms)
/// 3. Service Department (Service Bays, Parts Storage)
/// 4. Employee Areas (Break Room, Employee Restrooms)
///
/// Usage:
/// ```dart
/// final levels = SampleData.getAuditLevels();
/// final facilities = SampleData.getFacilities();
/// final audit = SampleData.getCurrentAudit();
/// final managerData = SampleData.getManagerComplianceData();
/// ```
class SampleData {
  /// Private constructor to prevent instantiation
  SampleData._();

  // ==========================================================================
  // AUDIT LEVELS DATA
  // ==========================================================================

  /// Get Sample Audit Levels with Subcategories and Checkpoints
  ///
  /// Returns a complete hierarchical structure of audit levels used for
  /// facility hygiene assessments. Each level contains multiple subcategories,
  /// and each subcategory contains specific checkpoints to be verified.
  ///
  /// Returns:
  /// - List of 4 AuditLevel objects
  /// - Total of 10 subcategories
  /// - Total of 28 checkpoints
  ///
  /// Levels:
  /// 1. Exterior Cleanliness (3 subcategories, 8 checkpoints)
  /// 2. Showroom & Customer Areas (3 subcategories, 10 checkpoints)
  /// 3. Service Department (2 subcategories, 5 checkpoints)
  /// 4. Employee Areas (2 subcategories, 5 checkpoints)
  static List<AuditLevel> getAuditLevels() {
    return [
      // ========== LEVEL 1: EXTERIOR CLEANLINESS ==========
      // Covers all external areas visible to customers and visitors
      // including parking lots, building facade, and landscaping
      AuditLevel(
        id: 'level_1',
        name: 'Exterior Cleanliness',
        description: 'Assessment of building exterior, parking, and entrance areas',
        subcategories: [
          AuditSubcategory(
            id: 'sub_1_1',
            name: 'Parking Area',
            description: 'Customer and employee parking areas',
            checkpoints: [
              Checkpoint(
                id: 'cp_1_1_1',
                title: 'Parking lot is free of debris',
                description: 'Check for litter, leaves, and other debris',
              ),
              Checkpoint(
                id: 'cp_1_1_2',
                title: 'Parking lines are clearly visible',
                description: 'White/yellow lines are not faded',
              ),
              Checkpoint(
                id: 'cp_1_1_3',
                title: 'No oil stains or fluid leaks',
                description: 'Parking surface is clean from automotive fluids',
              ),
            ],
          ),
          AuditSubcategory(
            id: 'sub_1_2',
            name: 'Building Exterior',
            description: 'Building facade and entrance',
            checkpoints: [
              Checkpoint(
                id: 'cp_1_2_1',
                title: 'Windows are clean and streak-free',
                description: 'All exterior windows cleaned',
              ),
              Checkpoint(
                id: 'cp_1_2_2',
                title: 'Entrance doors are clean',
                description: 'No fingerprints, smudges, or dirt',
              ),
              Checkpoint(
                id: 'cp_1_2_3',
                title: 'Signage is clean and properly lit',
                description: 'Dealership signage is visible and illuminated',
              ),
            ],
          ),
          AuditSubcategory(
            id: 'sub_1_3',
            name: 'Landscaping',
            description: 'Grounds and greenery maintenance',
            checkpoints: [
              Checkpoint(
                id: 'cp_1_3_1',
                title: 'Grass/lawn is trimmed',
                description: 'Lawn maintained at appropriate height',
              ),
              Checkpoint(
                id: 'cp_1_3_2',
                title: 'Plants and shrubs are healthy',
                description: 'No dead plants, proper watering',
              ),
            ],
          ),
        ],
      ),

      // ========== LEVEL 2: SHOWROOM & CUSTOMER AREAS ==========
      // Public-facing interior spaces where customers spend time
      // Critical for brand image and customer satisfaction
      AuditLevel(
        id: 'level_2',
        name: 'Showroom & Customer Areas',
        description: 'Public-facing interior spaces',
        subcategories: [
          AuditSubcategory(
            id: 'sub_2_1',
            name: 'Reception Area',
            description: 'First customer contact point',
            checkpoints: [
              Checkpoint(
                id: 'cp_2_1_1',
                title: 'Reception desk is organized',
                description: 'No clutter, clean surface',
              ),
              Checkpoint(
                id: 'cp_2_1_2',
                title: 'Seating area is clean',
                description: 'Chairs/sofas vacuumed, no stains',
              ),
              Checkpoint(
                id: 'cp_2_1_3',
                title: 'Reading materials are organized',
                description: 'Magazines current and neatly arranged',
              ),
            ],
          ),
          AuditSubcategory(
            id: 'sub_2_2',
            name: 'Showroom Floor',
            description: 'Vehicle display area',
            checkpoints: [
              Checkpoint(
                id: 'cp_2_2_1',
                title: 'Floor is clean and polished',
                description: 'No scuff marks, properly mopped',
              ),
              Checkpoint(
                id: 'cp_2_2_2',
                title: 'Display vehicles are spotless',
                description: 'Cars washed, interiors clean',
              ),
              Checkpoint(
                id: 'cp_2_2_3',
                title: 'Product displays are dust-free',
                description: 'Accessories and parts displays cleaned',
              ),
              Checkpoint(
                id: 'cp_2_2_4',
                title: 'Glass surfaces are clean',
                description: 'Windows, doors, display cases streak-free',
              ),
            ],
          ),
          AuditSubcategory(
            id: 'sub_2_3',
            name: 'Customer Restrooms',
            description: 'Public restroom facilities',
            checkpoints: [
              Checkpoint(
                id: 'cp_2_3_1',
                title: 'Restrooms are clean and sanitized',
                description: 'Toilets, sinks, floors cleaned',
              ),
              Checkpoint(
                id: 'cp_2_3_2',
                title: 'Supplies are fully stocked',
                description: 'Soap, paper towels, toilet paper available',
              ),
              Checkpoint(
                id: 'cp_2_3_3',
                title: 'No unpleasant odors',
                description: 'Air freshener present, well-ventilated',
              ),
            ],
          ),
        ],
      ),

      // ========== LEVEL 3: SERVICE DEPARTMENT ==========
      // Workshop and technical service areas where vehicle maintenance occurs
      // Requires strict cleanliness standards for safety and efficiency
      AuditLevel(
        id: 'level_3',
        name: 'Service Department',
        description: 'Workshop and service areas',
        subcategories: [
          AuditSubcategory(
            id: 'sub_3_1',
            name: 'Service Bays',
            description: 'Vehicle service stations',
            checkpoints: [
              Checkpoint(
                id: 'cp_3_1_1',
                title: 'Bays are free of oil and fluid spills',
                description: 'Clean work surface, spills cleaned immediately',
              ),
              Checkpoint(
                id: 'cp_3_1_2',
                title: 'Tools are organized',
                description: 'Tool storage clean and properly arranged',
              ),
              Checkpoint(
                id: 'cp_3_1_3',
                title: 'Waste bins are not overflowing',
                description: 'Trash and recycling properly managed',
              ),
            ],
          ),
          AuditSubcategory(
            id: 'sub_3_2',
            name: 'Parts Storage',
            description: 'Inventory and parts areas',
            checkpoints: [
              Checkpoint(
                id: 'cp_3_2_1',
                title: 'Parts shelves are organized',
                description: 'Labeled and properly stored',
              ),
              Checkpoint(
                id: 'cp_3_2_2',
                title: 'Floor is clean',
                description: 'No debris or spilled parts',
              ),
            ],
          ),
        ],
      ),

      // ========== LEVEL 4: EMPLOYEE AREAS ==========
      // Staff facilities including break rooms and employee restrooms
      // Important for employee satisfaction and workplace compliance
      AuditLevel(
        id: 'level_4',
        name: 'Employee Areas',
        description: 'Staff facilities and break rooms',
        subcategories: [
          AuditSubcategory(
            id: 'sub_4_1',
            name: 'Break Room',
            description: 'Employee rest area',
            checkpoints: [
              Checkpoint(
                id: 'cp_4_1_1',
                title: 'Break room is clean',
                description: 'Tables wiped, floor swept',
              ),
              Checkpoint(
                id: 'cp_4_1_2',
                title: 'Kitchen area is sanitized',
                description: 'Microwave, refrigerator, sink clean',
              ),
              Checkpoint(
                id: 'cp_4_1_3',
                title: 'Trash is emptied',
                description: 'Bins not overflowing',
              ),
            ],
          ),
          AuditSubcategory(
            id: 'sub_4_2',
            name: 'Employee Restrooms',
            description: 'Staff bathroom facilities',
            checkpoints: [
              Checkpoint(
                id: 'cp_4_2_1',
                title: 'Restrooms are clean',
                description: 'Sanitized and well-maintained',
              ),
              Checkpoint(
                id: 'cp_4_2_2',
                title: 'Supplies are stocked',
                description: 'Soap, towels, tissue available',
              ),
            ],
          ),
        ],
      ),
    ];
  }

  // ==========================================================================
  // FACILITIES DATA
  // ==========================================================================

  /// Get Sample Facilities
  ///
  /// Returns a list of sample Stellantis facilities including dealerships,
  /// manufacturing plants, and distribution centers across North America.
  /// Each facility includes complete contact information, location details,
  /// and organizational hierarchy.
  ///
  /// Returns:
  /// - List of 4 Facility objects
  /// - 2 zones (Great Lakes, Canada)
  /// - 2 countries (United States, Canada)
  ///
  /// Facilities:
  /// 1. Detroit Plant 1 (Manufacturing)
  /// 2. Auburn Hills HQ (Corporate Headquarters)
  /// 3. Toledo Assembly (Manufacturing)
  /// 4. Windsor Engine Plant (Manufacturing - Canada)
  static List<Facility> getFacilities() {
    return [
      Facility(
        id: 'fac_1',
        name: 'Detroit Plant 1',
        location: 'Detroit, MI',
        address: '1234 Industrial Blvd, Detroit, MI 48201',
        zone: 'North America - Great Lakes',
        country: 'United States',
        contactPerson: 'John Smith',
        contactEmail: 'john.smith@stellantis.com',
        contactPhone: '+1-313-555-0100',
        monthlyComplianceTarget: 95.0,
        assignedEmployees: ['emp_1', 'emp_2'],
      ),
      Facility(
        id: 'fac_2',
        name: 'Auburn Hills HQ',
        location: 'Auburn Hills, MI',
        address: '1000 Chrysler Drive, Auburn Hills, MI 48326',
        zone: 'North America - Great Lakes',
        country: 'United States',
        contactPerson: 'Sarah Johnson',
        contactEmail: 'sarah.johnson@stellantis.com',
        contactPhone: '+1-248-555-0200',
        monthlyComplianceTarget: 95.0,
        assignedEmployees: ['emp_3'],
      ),
      Facility(
        id: 'fac_3',
        name: 'Toledo Assembly',
        location: 'Toledo, OH',
        address: '4400 Chrysler Drive, Toledo, OH 43608',
        zone: 'North America - Great Lakes',
        country: 'United States',
        contactPerson: 'Michael Brown',
        contactEmail: 'michael.brown@stellantis.com',
        contactPhone: '+1-419-555-0300',
        monthlyComplianceTarget: 95.0,
        assignedEmployees: ['emp_4'],
      ),
      Facility(
        id: 'fac_4',
        name: 'Windsor Engine Plant',
        location: 'Windsor, ON',
        address: '1635 Walker Road, Windsor, ON N8W 3R8',
        zone: 'North America - Canada',
        country: 'Canada',
        contactPerson: 'Emily Davis',
        contactEmail: 'emily.davis@stellantis.com',
        contactPhone: '+1-519-555-0400',
        monthlyComplianceTarget: 95.0,
        assignedEmployees: ['emp_5'],
      ),
    ];
  }

  // ==========================================================================
  // CURRENT AUDIT DATA
  // ==========================================================================

  /// Get Sample Current Audit
  ///
  /// Returns an in-progress audit with partially completed checkpoints.
  /// This data simulates a real dealer's current audit session with some
  /// checkpoints already verified and marked with compliance levels.
  ///
  /// Returns:
  /// - Audit object for Detroit Plant 1
  /// - Status: In Progress
  /// - 3 checkpoints already completed (2 compliant, 1 non-compliant)
  /// - Overall compliance: 78%
  ///
  /// Completion Details:
  /// - Parking lot debris check: ✅ Compliant
  /// - Parking lines visibility: ✅ Compliant
  /// - Window cleaning: ❌ Non-Compliant (needs re-cleaning)
  static Audit getCurrentAudit() {
    final levels = getAuditLevels();

    // Mark some checkpoints as completed for demo
    levels[0].subcategories[0].checkpoints[0] = levels[0].subcategories[0].checkpoints[0].copyWith(
      isCompleted: true,
      complianceLevel: ComplianceLevel.compliant,
      completedAt: DateTime.now().subtract(const Duration(hours: 2)),
    );
    levels[0].subcategories[0].checkpoints[1] = levels[0].subcategories[0].checkpoints[1].copyWith(
      isCompleted: true,
      complianceLevel: ComplianceLevel.compliant,
      completedAt: DateTime.now().subtract(const Duration(hours: 2)),
    );
    levels[0].subcategories[1].checkpoints[0] = levels[0].subcategories[1].checkpoints[0].copyWith(
      isCompleted: true,
      complianceLevel: ComplianceLevel.nonCompliant,
      completedAt: DateTime.now().subtract(const Duration(hours: 1)),
      notes: 'Windows need re-cleaning',
    );

    return Audit(
      id: 'audit_001',
      facilityId: 'fac_1',
      facilityName: 'Detroit Plant 1',
      date: DateTime.now(),
      shift: 'Morning',
      status: AuditStatus.inProgress,
      performedBy: 'John Doe',
      performedById: 'emp_1',
      levels: levels,
      overallCompliance: 0.78,
    );
  }

  // ==========================================================================
  // MANAGER COMPLIANCE DATA
  // ==========================================================================

  /// Get Sample Manager Compliance Data
  ///
  /// Returns hierarchical compliance data for Stellantis managers at country,
  /// zone, and facility levels. This data structure allows managers to drill
  /// down from country-level overview to individual facility performance.
  ///
  /// Returns:
  /// - List of CountryCompliance objects (2 countries)
  /// - United States: 82.5% compliance (2 zones, 8 facilities)
  ///   - Great Lakes Zone: 85.3% (5 facilities)
  ///   - Southwest Zone: 78.2% (3 facilities)
  /// - Canada: 89.3% compliance (1 zone, 3 facilities)
  ///   - Ontario Zone: 89.3% (3 facilities)
  ///
  /// Hierarchy:
  /// Country → Zone → Facility → Audits
  ///
  /// Metrics Included:
  /// - Overall compliance percentage
  /// - Total/completed/pending audits
  /// - Last audit date for each facility
  /// - Facility assignment to zones and countries
  static List<CountryCompliance> getManagerComplianceData() {
    return [
      CountryCompliance(
        countryName: 'United States',
        compliancePercentage: 82.5,
        totalZones: 2,
        totalFacilities: 8,
        zones: [
          ZoneCompliance(
            zoneName: 'Great Lakes',
            compliancePercentage: 85.3,
            totalFacilities: 5,
            facilities: [
              FacilityCompliance(
                facilityId: 'fac_1',
                facilityName: 'Detroit Plant 1',
                compliancePercentage: 88.5,
                totalAudits: 60,
                completedAudits: 58,
                pendingAudits: 2,
                lastAuditDate: DateTime.now().subtract(const Duration(hours: 3)),
                zone: 'Great Lakes',
              ),
              FacilityCompliance(
                facilityId: 'fac_2',
                facilityName: 'Auburn Hills HQ',
                compliancePercentage: 92.0,
                totalAudits: 60,
                completedAudits: 60,
                pendingAudits: 0,
                lastAuditDate: DateTime.now().subtract(const Duration(hours: 5)),
                zone: 'Great Lakes',
              ),
              FacilityCompliance(
                facilityId: 'fac_3',
                facilityName: 'Toledo Assembly',
                compliancePercentage: 79.8,
                totalAudits: 60,
                completedAudits: 55,
                pendingAudits: 5,
                lastAuditDate: DateTime.now().subtract(const Duration(days: 1)),
                zone: 'Great Lakes',
              ),
            ],
          ),
          ZoneCompliance(
            zoneName: 'Southwest',
            compliancePercentage: 78.2,
            totalFacilities: 3,
            facilities: [
              FacilityCompliance(
                facilityId: 'fac_5',
                facilityName: 'Phoenix Distribution',
                compliancePercentage: 81.0,
                totalAudits: 60,
                completedAudits: 57,
                pendingAudits: 3,
                lastAuditDate: DateTime.now().subtract(const Duration(hours: 8)),
                zone: 'Southwest',
              ),
            ],
          ),
        ],
      ),
      CountryCompliance(
        countryName: 'Canada',
        compliancePercentage: 89.3,
        totalZones: 1,
        totalFacilities: 3,
        zones: [
          ZoneCompliance(
            zoneName: 'Ontario',
            compliancePercentage: 89.3,
            totalFacilities: 3,
            facilities: [
              FacilityCompliance(
                facilityId: 'fac_4',
                facilityName: 'Windsor Engine Plant',
                compliancePercentage: 91.5,
                totalAudits: 60,
                completedAudits: 60,
                pendingAudits: 0,
                lastAuditDate: DateTime.now().subtract(const Duration(hours: 2)),
                zone: 'Ontario',
              ),
            ],
          ),
        ],
      ),
    ];
  }
}

// ===========================================================================
// END OF FILE: sample_data.dart
// ============================================================================
// AUTHOR: Rahul Raja
// WEBSITE: https://www.stellantis.com/
// ============================================================================
