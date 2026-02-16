# ============================================================================
# PROJECT: Stellantis Dealer Hygiene App
# FILE: cleanliness_evaluator.py
# AUTHOR: Sujan Sreenivasulu
# WEBSITE: https://www.stellantis.com/
# VERSION: 1.0.0
# ============================================================================
# COPYRIGHT: © 2026 STELLANTIS N.V. - INTERNAL USE ONLY
# ============================================================================

"""
Description: Domain Service for evaluating facility cleanliness.

This module contains the `CleanlinessEvaluator` service, which is responsible for the core business logic
of translating raw computer vision detections into a definitive business status (Clean vs Not Clean).

It enforces rules regarding:
- Confidence thresholds.
- Presence of specific "negative" labels (e.g., "Trash", "Oil").
- Configurable strictness levels via `CleanlinessRules`.

WHY: This logic is too complex for a single Entity and involves multiple pieces of data
(Vision Result + Metadata + Rules), making it a perfect candidate for a Domain Service.
"""

from dataclasses import dataclass
from typing import List, Set

from ..entities import AuditResult, DetectedLabel
from ..value_objects import CleanlinessStatus, ConfidenceScore, ImageMetadata
from ..ports import VisionAnalysisResult


@dataclass
class CleanlinessRules:
    """
    Configuration object defining the strictness and criteria for cleanliness evaluation.

    This allows the system to apply different standards to different contexts without changing code.

    Attributes:
        negative_labels (Set[str]): Collection of label names that indicate a cleanliness violation.
        confidence_threshold (float): Minimum confidence required to accept an AI verdict automatically.
        max_negative_labels (int): How many negative items are allowed before failing (usually 0).
        require_review_on_low_confidence (bool): If True, low confidence results trigger a manual review
                                                 instead of an automatic pass/fail.

    WHY: Different dealer types have different standards:
    - Premium brands: stricter rules
    - Service centers: focus on safety
    - Showrooms: focus on appearance
    """
    # Labels that indicate NOT_CLEAN
    negative_labels: Set[str] = None
    
    # Minimum confidence to trust AI decision
    confidence_threshold: float = 80.0
    
    # Maximum allowed negative labels before failing
    max_negative_labels: int = 0
    
    # Enable/disable manual review triggers
    require_review_on_low_confidence: bool = True

    def __post_init__(self):
        """
        Sets default negative labels if none are provided.
        
        The default set includes common hygiene violations like dirt, pests, and hazards.
        """
        if self.negative_labels is None:
            # Default negative labels for general cleanliness
            self.negative_labels = {
                # Dirt and debris
                "Dirt", "Mud", "Debris", "Trash", "Garbage", "Litter",
                "Waste", "Rubbish", "Clutter", "Mess",
                
                # Stains and damage
                "Stain", "Graffiti", "Rust", "Corrosion", "Mold", "Mildew",
                "Decay", "Deterioration",
                
                # Pests
                "Insect", "Bug", "Rodent", "Pest", "Spider Web",
                
                # Disorganization
                "Disorder", "Disorganized", "Untidy", "Unkempt",
                
                # Hazards
                "Spill", "Leak", "Broken Glass", "Sharp Object",
            }


class CleanlinessEvaluator:
    """
    Domain Service: Encapsulates the logic for grading a facility's cleanliness.

    This service is stateless and deterministic: given the same vision results and rules,
    it will always produce the same `AuditResult`.

    WHY: Domain Service (not entity method) because:
    1. It operates on multiple objects (VisionAnalysisResult + ImageMetadata)
    2. It applies configurable business rules
    3. It doesn't have identity or lifecycle
    
    Design: Stateless and deterministic.
    WHY: Same inputs should always produce same outputs (testability + reproducibility).
    """

    def __init__(self, rules: CleanlinessRules):
        """
        Initializes the evaluator with a specific set of rules.

        Args:
            rules (CleanlinessRules): The criteria to use for this instance.
        """
        self.rules = rules

    def evaluate(
        self,
        vision_result: VisionAnalysisResult,
        image_metadata: ImageMetadata,
        manual_override: bool = None
    ) -> AuditResult:
        """
        Core Domain Logic: Converts raw vision analysis into a structured Audit Decision.

        This method orchestrates the entire grading process.

        Algorithm:
        1. Adapt: Convert provider-specific labels to domain `DetectedLabel` objects.
        2. Calculate: specific metrics like overall confidence.
        3. Filter: Identify which detected labels constitutes violations (negative labels).
        4. Decide: Apply business rules to determine the final `CleanlinessStatus`.
        5. Construct: Build and return the final `AuditResult` aggregate.
        
        Args:
            vision_result (VisionAnalysisResult): Raw output from the vision provider.
            image_metadata (ImageMetadata): Contextual data about the source image.
            manual_override (Optional[bool]): If provided, forces a specific outcome (True=Clean, False=Dirty).
        
        Returns:
            AuditResult: The fully populated domain entity representing the audit outcome.
        """
        # Step 1: Convert vision labels to domain labels
        detected_labels = self._convert_labels(vision_result.labels)
        
        # Step 2: Calculate overall confidence
        overall_confidence = self._calculate_overall_confidence(detected_labels)
        
        # Step 3: Identify negative labels
        negative_labels = self._identify_negative_labels(detected_labels)
        
        # Step 4: Determine status based on rules
        status = self._determine_status(
            negative_labels=negative_labels,
            overall_confidence=overall_confidence,
            manual_override=manual_override
        )
        
        # Step 5: Create audit result entity
        audit_result = AuditResult(
            image_metadata=image_metadata,
            detected_labels=detected_labels,
            overall_confidence=overall_confidence,
            status=status,
            negative_labels=negative_labels,
            manual_override=manual_override,
            vision_provider=vision_result.provider_name,
            model_version=vision_result.model_version,
        )
        
        return audit_result

    def _convert_labels(self, vision_labels: List) -> List[DetectedLabel]:
        """
        Adapts the `VisionLabel` DTOs into domain `DetectedLabel` entities.
        
        Verified against the negative label set during conversion to flag violations immediately.

        Args:
            vision_labels (List[VisionLabel]): The list of raw detections.

        Returns:
            List[DetectedLabel]: The list of domain-aware labels.

        WHY: Domain layer works with DetectedLabel, not VisionLabel. This is the anti-corruption layer.
        """
        return [
            DetectedLabel(
                name=label.name,
                confidence=label.confidence,
                is_negative=self._is_negative_label(label.name)
            )
            for label in vision_labels
        ]

    def _is_negative_label(self, label_name: str) -> bool:
        """
        Checks if a specific label string matches any defined negative criterion.
        
        Performs case-insensitive substring matching against the ruleset.

        Args:
            label_name (str): The name of the detected object (e.g., "Oil Stain").

        Returns:
            bool: True if it's a violation, False otherwise.

        WHY: Business rule - what constitutes "not clean"? Centralized here for consistency.
        """
        # Case-insensitive matching
        label_lower = label_name.lower()
        return any(
            neg_label.lower() in label_lower
            for neg_label in self.rules.negative_labels
        )

    def _identify_negative_labels(
        self,
        labels: List[DetectedLabel]
    ) -> List[DetectedLabel]:
        """
        Filters the full list of detections to return only the violations.

        Args:
            labels (List[DetectedLabel]): All detections.

        Returns:
            List[DetectedLabel]: Just the bad ones.

        WHY: For explainability - show WHICH issues were detected.
        """
        return [label for label in labels if label.is_negative]

    def _calculate_overall_confidence(
        self,
        labels: List[DetectedLabel]
    ) -> ConfidenceScore:
        """
        Computes a single aggregate confidence score for the entire analysis.

        Strategy: Average the confidence of the top 5 most confident detections.
        This provides a heuristic for how "sure" the model is about its findings overall.

        Args:
            labels (List[DetectedLabel]): All detections.

        Returns:
            ConfidenceScore: The aggregated score.

        WHY: Business decision - how confident are we in this analysis?
        """
        if not labels:
            return ConfidenceScore(value=0.0)
        
        # Sort by confidence, take top 5
        top_labels = sorted(
            labels,
            key=lambda x: x.confidence.value,
            reverse=True
        )[:5]
        
        avg_confidence = sum(l.confidence.value for l in top_labels) / len(top_labels)
        return ConfidenceScore(value=avg_confidence)

    def _determine_status(
        self,
        negative_labels: List[DetectedLabel],
        overall_confidence: ConfidenceScore,
        manual_override: bool = None
    ) -> CleanlinessStatus:
        """
        Applies the definitive business rules to choose the final status.

        Args:
            negative_labels (List[DetectedLabel]): Found violations.
            overall_confidence (ConfidenceScore): System confidence.
            manual_override (bool): Forced human decision.

        Returns:
            CleanlinessStatus: The final verdict (CLEAN, NOT_CLEAN, REVIEW, etc.).

        WHY: This is THE business logic for cleanliness determination.
        
        Decision Tree:
        1. Manual override wins
        2. Low confidence → Manual review
        3. Too many negative labels → Not clean
        4. Any negative labels → Not clean
        5. Otherwise → Clean
        """
        # Rule 1: Manual override has highest priority
        if manual_override is not None:
            return CleanlinessStatus.CLEAN if manual_override else CleanlinessStatus.NOT_CLEAN
        
        # Rule 2: Low confidence requires human review
        if not overall_confidence.is_above_threshold(self.rules.confidence_threshold):
            if self.rules.require_review_on_low_confidence:
                return CleanlinessStatus.REQUIRES_MANUAL_REVIEW
            else:
                return CleanlinessStatus.INSUFFICIENT_DATA
        
        # Rule 3: Check negative label count
        if len(negative_labels) > self.rules.max_negative_labels:
            return CleanlinessStatus.NOT_CLEAN
        
        # Rule 4: Any negative labels fail the audit
        if negative_labels:
            return CleanlinessStatus.NOT_CLEAN
        
        # Rule 5: Pass
        return CleanlinessStatus.CLEAN

# -------------------------------------------------------------------------------------
# End of backend/domain/services/cleanliness_evaluator.py
# -------------------------------------------------------------------------------------
