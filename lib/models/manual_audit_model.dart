// ============================================================================
// FILE: manual_audit_model.dart
// DESCRIPTION: Model for manual audit data submission
// ============================================================================
// PROJECT: Stellantis Dealer Hygiene App
// AUTHOR: AI Assistant
// WEBSITE: https://www.stellantis.com/
// VERSION: 1.0.0
// ============================================================================
// COPYRIGHT: © 2026 STELLANTIS N.V. - INTERNAL USE ONLY
// ============================================================================

/// Manual Audit Data Model
///
/// Represents all fields required for manual audit submission
/// Maps to PostgreSQL schema in backend
class ManualAuditModel {
  final String dealerId;
  final String dealerName;
  final DateTime date;
  final String month;
  final String complianceStatus;
  final String shift;
  final String dealerConsolidatedSummary;
  final String level1;
  final String subCategory;
  final String checkpoint;
  final String? photoUrl;
  final double confidenceLevel;
  final String feedback;
  final String language;
  final String country;
  final String dealerDetails;
  final String zone;
  final String email;
  final String password;
  final DateTime time;

  ManualAuditModel({
    required this.dealerId,
    required this.dealerName,
    required this.date,
    required this.month,
    required this.complianceStatus,
    required this.shift,
    required this.dealerConsolidatedSummary,
    required this.level1,
    required this.subCategory,
    required this.checkpoint,
    this.photoUrl,
    required this.confidenceLevel,
    required this.feedback,
    required this.language,
    required this.country,
    required this.dealerDetails,
    required this.zone,
    required this.email,
    required this.password,
    required this.time,
  });

  /// Convert model to JSON for API submission
  Map<String, dynamic> toJson() {
    return {
      'dealer_id': dealerId,
      'dealer_name': dealerName,
      'date': date.toIso8601String().split('T')[0], // YYYY-MM-DD
      'month': month,
      'compliance_status': complianceStatus,
      'shift': shift,
      'dealer_consolidated_summary': dealerConsolidatedSummary,
      'level_1': level1,
      'sub_category': subCategory,
      'checkpoint': checkpoint,
      'photo_url': photoUrl,
      'confidence_level': confidenceLevel,
      'feedback': feedback,
      'language': language,
      'country': country,
      'dealer_details': dealerDetails,
      'zone': zone,
      'email': email,
      'password': password,
      'time': time.toIso8601String(),
    };
  }

  /// Create model from JSON response
  factory ManualAuditModel.fromJson(Map<String, dynamic> json) {
    return ManualAuditModel(
      dealerId: json['dealer_id'] ?? '',
      dealerName: json['dealer_name'] ?? '',
      date: DateTime.parse(json['date']),
      month: json['month'] ?? '',
      complianceStatus: json['compliance_status'] ?? '',
      shift: json['shift'] ?? '',
      dealerConsolidatedSummary: json['dealer_consolidated_summary'] ?? '',
      level1: json['level_1'] ?? '',
      subCategory: json['sub_category'] ?? '',
      checkpoint: json['checkpoint'] ?? '',
      photoUrl: json['photo_url'],
      confidenceLevel: (json['confidence_level'] ?? 0).toDouble(),
      feedback: json['feedback'] ?? '',
      language: json['language'] ?? '',
      country: json['country'] ?? '',
      dealerDetails: json['dealer_details'] ?? '',
      zone: json['zone'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      time: DateTime.parse(json['time']),
    );
  }
}

