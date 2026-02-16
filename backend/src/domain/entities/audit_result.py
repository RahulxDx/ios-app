# ============================================================================
# PROJECT: Stellantis Dealer Hygiene App
# FILE: audit_result.py
# AUTHOR: Sujan Sreenivasulu
# WEBSITE: https://www.stellantis.com/
# VERSION: 1.0.0
# ============================================================================
# COPYRIGHT: © 2026 STELLANTIS N.V. - INTERNAL USE ONLY
# ============================================================================

"""
Description: Definition of the AuditResult entity and related structures.

This file contains the `AuditResult` class, which is the central Aggregate Root for the hygiene audit domain.
It encapsulates the state and behavior of an audit, including vision analysis results, compliance status,
and human review details. It also includes `DetectedLabel` to represent granular findings from the vision system.

This entity enforces business invariants such as:
- How cleanliness status is determined (via delegation to services/values, or internal logic).
- How manual overrides are applied.
- The lifecycle of an audit from creation to finalization.
"""

from dataclasses import dataclass, field
from datetime import datetime
from typing import List, Optional
from uuid import UUID, uuid4

from ..value_objects import CleanlinessStatus, ConfidenceScore, ImageMetadata


@dataclass
class DetectedLabel:
    """
    Represents an individual element or object detected within an image by the vision system.

    This detection includes the name of the object (e.g., "Dirt", "Car"), a confidence score,
    and a flag indicating if this label contributes to a negative (cleanliness) assessment.

    Attributes:
        name (str): The common name of the detected object (e.g., "Oil Spill").
        confidence (ConfidenceScore): The statistical confidence of the detection (0-100).
        is_negative (bool): True if this label represents a cleanliness violation, False otherwise.

    WHY: Separated from AuditResult to support explainability.
    Auditors need to see WHICH specific labels caused a 'NOT_CLEAN' verdict to trust the system.
    """
    name: str
    confidence: ConfidenceScore
    is_negative: bool  # Indicates unclean condition

    def __str__(self) -> str:
        """
        Returns a human-readable string representation of the label.
        
        Format: "Flag Name (Confidence%)" -> "❌ Dust (95.0%)"
        """
        flag = "❌" if self.is_negative else "✓"
        return f"{flag} {self.name} ({self.confidence.as_percentage()})"


@dataclass
class AuditResult:
    """
    Core Domain Entity: Represents the definitive result of a hygiene audit analysis.
    
    This entity serves as the Aggregate Root for the audit context. It holds references to
    all supporting data (image metadata, detections) and tracks the lifecycle state of the audit.

    WHY: This is modeled as an Entity (not a Value Object) because:
    1. It has a distinct Identity (`audit_id`) that persists even if its data changes.
    2. It has a Lifecycle (CREATED -> ANALYZED -> REVIEWED -> FINALIZED).
    3. It is Mutable (a human can review and override the automated status).

    Lifecycle:
    CREATED → ANALYZED → (optionally) MANUALLY_REVIEWED → FINALIZED

    Attributes:
        image_metadata (ImageMetadata): Technical metadata about the source image.
        detected_labels (List[DetectedLabel]): Full list of all labels found in the image.
        overall_confidence (ConfidenceScore): Aggregated confidence score for the analysis.
        status (CleanlinessStatus): The current business status (e.g., CLEAN, NOT_CLEAN).
        audit_id (UUID): Unique identifier for this audit record.
        negative_labels (List[DetectedLabel]): Subset of labels that are violations.
        reason (Optional[str]): Human-readable explanation for the status.
        analyzed_at (datetime): Timestamp when the AI analysis occurred.
        reviewed_by (Optional[str]): ID of the human auditor who reviewed this (if any).
        reviewed_at (Optional[datetime]): Timestamp of the human review.
        manual_override (Optional[bool]): Explicit flag if a human overrode the AI.
        vision_provider (str): Name of the AI service used (e.g., "rekognition").
        model_version (Optional[str]): Version string of the AI model.
    """
    # Relationships (required, must be provided first)
    image_metadata: ImageMetadata
    
    # Analysis Results (required, must be provided)
    detected_labels: List[DetectedLabel]
    overall_confidence: ConfidenceScore
    status: CleanlinessStatus
    
    # Identity (has default)
    audit_id: UUID = field(default_factory=uuid4)

    # Explainability (has defaults)
    negative_labels: List[DetectedLabel] = field(default_factory=list)
    reason: Optional[str] = None
    
    # Audit Trail (has defaults)
    analyzed_at: datetime = field(default_factory=datetime.utcnow)
    reviewed_by: Optional[str] = None
    reviewed_at: Optional[datetime] = None
    manual_override: Optional[bool] = None
    
    # Technical Metadata (has defaults)
    vision_provider: str = "rekognition"  # Supports future: "tflite", "custom"
    model_version: Optional[str] = None

    def __post_init__(self):
        """
        Post-initialization hook to populate derived fields.

        This method ensures that:
        1. `negative_labels` are correctly filtered from `detected_labels` if not provided.
        2. A default `reason` is generated if one is missing, ensuring explainability.

        WHY: Separate negative labels for explainability.
        Business requirement: Show users WHY something is not clean.
        """
        # Automatically derive negative labels if not explicitly passed
        self.negative_labels = [
            label for label in self.detected_labels if label.is_negative
        ]
        
        # Ensure a reason exists for the current status
        if not self.reason:
            self.reason = self._generate_reason()

    def _generate_reason(self) -> str:
        """
        Generates a human-readable explanation for the audit's current status.

        This text is crucial for the UI to explain to users (dealers, auditors) why
        a specific grade was given.

        WHY: Explainability is critical for:
        1. Dealer dispute resolution
        2. Auditor training
        3. Regulatory compliance
        
        Returns:
            str: A descriptive reason string.
        """
        if self.status == CleanlinessStatus.CLEAN:
            return "No cleanliness issues detected"
        
        if self.status == CleanlinessStatus.INSUFFICIENT_DATA:
            return f"Confidence too low ({self.overall_confidence.as_percentage()})"
        
        if self.status == CleanlinessStatus.REQUIRES_MANUAL_REVIEW:
            return "Unclear results - manual review required"
        
        if self.negative_labels:
            label_names = [label.name for label in self.negative_labels[:3]]
            return f"Issues detected: {', '.join(label_names)}"
        
        return "Status determination unclear"

    def apply_manual_override(self, reviewer_id: str, is_clean: bool, notes: str) -> None:
        """
        Applies a manual override decision from a human auditor.

        This is a domain operation that modifies the entity's state to reflect human judgment.
        It updates the status, records the reviewer's identity, and timestamps the action.

        WHY: Humans must be able to correct AI mistakes.
        This is a domain operation with business rules.
        
        Business Rules:
        1. Override always takes precedence over AI results.
        2. Must record WHO made the decision (accountability).
        3. Must record WHEN (audit trail).
        
        Args:
            reviewer_id (str): The ID of the user performing the review.
            is_clean (bool): The manual verdict (True for CLEAN, False for NOT_CLEAN).
            notes (str): Justification for the override.
        """
        self.manual_override = is_clean
        self.status = CleanlinessStatus.CLEAN if is_clean else CleanlinessStatus.NOT_CLEAN
        self.reviewed_by = reviewer_id
        self.reviewed_at = datetime.utcnow()
        self.reason = f"Manual override: {notes}"

    def is_finalized(self) -> bool:
        """
        Checks if the audit process is considered complete.
        
        Currently defined as having been reviewed by a human.
        
        WHY: Prevent re-analysis of already-reviewed audits.
        
        Returns:
            bool: True if reviewed, False otherwise.
        """
        return self.reviewed_by is not None

    def passes_compliance(self) -> bool:
        """
        Determines if this audit represents a "passing" grade for the dealer.

        Domain method: Does this audit represent a passing grade?
        
        WHY: Business rule centralized in domain, not scattered across services.
        
        Returns:
            bool: True if the status is compliant (CLEAN).
        """
        return self.status.is_compliant()

    def requires_review(self) -> bool:
        """
        Checks if this audit requires human intervention.
        
        WHY: Workflow routing decision based on domain state. Used to filter audits
        that need to appear in the auditor's queue.
        
        Returns:
            bool: True if manual review is needed.
        """
        return self.status.requires_human_intervention()

# -------------------------------------------------------------------------------------
# End of backend/domain/entities/audit_result.py
# -------------------------------------------------------------------------------------
