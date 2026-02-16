# ============================================================================
# PROJECT: Stellantis Dealer Hygiene App
# FILE: cleanliness_status.py
# AUTHOR: Sujan Sreenivasulu
# WEBSITE: https://www.stellantis.com/
# VERSION: 1.0.0
# ============================================================================
# COPYRIGHT: © 2026 STELLANTIS N.V. - INTERNAL USE ONLY
# ============================================================================

"""
Description: Definition of the CleanlinessStatus value object.

This file defines the Enum responsible for tracking the business state of a hygiene audit.
It encapsulates the logic for transitions and queries about the status (e.g., "Is this compliant?").
"""

from enum import Enum
from typing import List, Optional


class CleanlinessStatus(str, Enum):
    """
    Enumeration representing the official business outcome of a facility audit.
    
    Members:
        CLEAN: Facility passed all checks.
        NOT_CLEAN: Violations were found.
        REQUIRES_MANUAL_REVIEW: AI was unsure, human must decide.
        INSUFFICIENT_DATA: Technical issues prevented a clear result (e.g., blur).

    WHY: Using Enum ensures type safety and prevents invalid states.
    Inheriting from str makes it JSON serializable for FastAPI automatically.
    """
    CLEAN = "CLEAN"
    NOT_CLEAN = "NOT_CLEAN"
    REQUIRES_MANUAL_REVIEW = "REQUIRES_MANUAL_REVIEW"
    INSUFFICIENT_DATA = "INSUFFICIENT_DATA"

    def is_compliant(self) -> bool:
        """
        Checks if this status represents a passing grade.

        Returns:
            bool: True only if status is CLEAN.
            
        WHY: Business rule - only CLEAN facilities pass audit.
        """
        return self == CleanlinessStatus.CLEAN

    def requires_human_intervention(self) -> bool:
        """
        Checks if this status demands an auditor's attention.

        Returns:
            bool: True for partial/uncertain states.
            
        WHY: These statuses need auditor review before final decision.
        """
        return self in {
            CleanlinessStatus.REQUIRES_MANUAL_REVIEW,
            CleanlinessStatus.INSUFFICIENT_DATA
        }

    @staticmethod
    def from_evaluation(
        negative_labels: List[str],
        confidence_below_threshold: bool,
        manual_override: Optional[bool] = None
    ) -> "CleanlinessStatus":
        """
        Factory method to determine status from evaluation criteria.
        
        This encapsulates the logic for which combination of factors leads to which status.

        Args:
            negative_labels (List[str]): List of detected violations.
            confidence_below_threshold (bool): True if analysis confidence was low.
            manual_override (Optional[bool]): True/False if human overrode, None otherwise.

        Returns:
            CleanlinessStatus: The calculated status.

        WHY: Centralizes business logic for status determination.
        This is a domain rule that should NEVER live in a controller.
        
        Business Rules:
        1. Manual override always wins (for auditor corrections).
        2. Low confidence triggers manual review.
        3. Presence of negative labels = NOT_CLEAN.
        4. Otherwise = CLEAN.
        """
        if manual_override is not None:
            return CleanlinessStatus.CLEAN if manual_override else CleanlinessStatus.NOT_CLEAN
        
        if confidence_below_threshold:
            return CleanlinessStatus.REQUIRES_MANUAL_REVIEW
        
        if negative_labels:
            return CleanlinessStatus.NOT_CLEAN
        
        return CleanlinessStatus.CLEAN

# -------------------------------------------------------------------------------------
# End of backend/domain/value_objects/cleanliness_status.py
# -------------------------------------------------------------------------------------
