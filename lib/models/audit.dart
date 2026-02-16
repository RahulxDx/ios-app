// ============================================================================
// FILE: audit.dart
// DESCRIPTION: Data model representing an audit, including levels, compliance, and status.
// ============================================================================
// PROJECT: Stellantis Dealer Hygiene App
// AUTHOR: Rohith U
// WEBSITE: https://www.stellantis.com/
// VERSION: 1.0.0
// ============================================================================
// COPYRIGHT: © 2026 STELLANTIS N.V. - INTERNAL USE ONLY
// ============================================================================

/// Enum representing the status of an audit
enum AuditStatus {
  notStarted,
  inProgress,
  completed,
  pendingReview,
}

/// Enum representing the level of compliance for a checkpoint
enum ComplianceLevel {
  compliant,
  nonCompliant,
  partiallyCompliant,
}

/// Main class representing an Audit entity.
/// 
/// This class holds all information related to a specific audit, including
/// the facility, date, shift, and the detailed breakdown of audit levels.
class Audit {
  // TODO: Add JSON serialization methods (fromJson, toJson)
  
  final String id;
  final String facilityId;
  final String facilityName;
  final DateTime date;
  final String shift; // 'Morning' or 'Evening'
  final AuditStatus status;
  final String performedBy;
  final String performedById;
  final List<AuditLevel> levels;
  final double overallCompliance;
  final DateTime? completedAt;

  Audit({
    required this.id,
    required this.facilityId,
    required this.facilityName,
    required this.date,
    required this.shift,
    required this.status,
    required this.performedBy,
    required this.performedById,
    required this.levels,
    required this.overallCompliance,
    this.completedAt,
  });

  /// Calculates the total number of checkpoints across all levels and subcategories.
  /// 
  /// TODO: Optimize this if the number of levels/subcategories becomes large.
  int get totalCheckpoints => levels.fold(
      0,
      (sum, level) => sum +
          level.subcategories.fold(
              0, (subSum, sub) => subSum + sub.checkpoints.length));

  /// Calculates the number of completed checkpoints.
  int get completedCheckpoints => levels.fold(
      0,
      (sum, level) => sum +
          level.subcategories.fold(
              0,
              (subSum, sub) =>
                  subSum +
                  sub.checkpoints.where((c) => c.isCompleted).length));

  /// Calculates the overall progress percentage of the audit.
  double get progressPercentage =>
      totalCheckpoints > 0 ? (completedCheckpoints / totalCheckpoints) : 0;
}

/// Represents a high-level category or area within an audit (e.g., "Main Hall", "Exterior").
class AuditLevel {
  final String id;
  final String name;
  final String description;
  final List<AuditSubcategory> subcategories;

  AuditLevel({
    required this.id,
    required this.name,
    required this.description,
    required this.subcategories,
  });

  int get totalCheckpoints =>
      subcategories.fold(0, (sum, sub) => sum + sub.checkpoints.length);

  int get completedCheckpoints => subcategories.fold(
      0,
      (sum, sub) =>
          sum + sub.checkpoints.where((c) => c.isCompleted).length);

  double get compliance =>
      totalCheckpoints > 0 ? (completedCheckpoints / totalCheckpoints) : 0;
}

/// Represents a specific subcategory within an audit level.
class AuditSubcategory {
  final String id;
  final String name;
  final String description;
  final List<Checkpoint> checkpoints;

  AuditSubcategory({
    required this.id,
    required this.name,
    required this.description,
    required this.checkpoints,
  });

  int get completedCheckpoints =>
      checkpoints.where((c) => c.isCompleted).length;

  double get compliance =>
      checkpoints.isNotEmpty ? (completedCheckpoints / checkpoints.length) : 0;
}

/// Represents an individual item to be checked during the audit.
class Checkpoint {
  final String id;
  final String title;
  final String description;
  // TODO: Consider using a state machine for completion status if it gets more complex
  final bool isCompleted;
  final ComplianceLevel? complianceLevel;
  final CheckpointEvidence? evidence;
  final String? notes;
  final DateTime? completedAt;

  Checkpoint({
    required this.id,
    required this.title,
    required this.description,
    this.isCompleted = false,
    this.complianceLevel,
    this.evidence,
    this.notes,
    this.completedAt,
  });

  /// Creates a copy of this Checkpoint with the given fields replaced with the new values.
  Checkpoint copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    ComplianceLevel? complianceLevel,
    CheckpointEvidence? evidence,
    String? notes,
    DateTime? completedAt,
    String? photoPath,
  }) {
    return Checkpoint(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      complianceLevel: complianceLevel ?? this.complianceLevel,
      evidence: photoPath != null
          ? CheckpointEvidence(photoPath: photoPath)
          : (evidence ?? this.evidence),
      notes: notes ?? this.notes,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

/// Holds evidence related to a checkpoint, such as photos or AI analysis.
class CheckpointEvidence {
  final String? photoPath;
  final bool isPhotoAnalyzed;
  final AIAnalysisResult? aiAnalysis;
  final bool isManualDeclaration;
  final String? manualDeclarationReason;

  CheckpointEvidence({
    this.photoPath,
    this.isPhotoAnalyzed = false,
    this.aiAnalysis,
    this.isManualDeclaration = false,
    this.manualDeclarationReason,
  });
}

/// Result of AI analysis on an evidence photo.
class AIAnalysisResult {
  final ComplianceLevel suggestedCompliance;
  final double confidenceScore;
  final String analysisNotes;
  final List<String> detectedIssues;

  AIAnalysisResult({
    required this.suggestedCompliance,
    required this.confidenceScore,
    required this.analysisNotes,
    required this.detectedIssues,
  });
}

// ============================================================================
// END OF FILE: audit.dart
// ============================================================================
// AUTHOR: Rohith U
// WEBSITE: https://www.stellantis.com/
// ============================================================================

