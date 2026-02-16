# ============================================================================
# PROJECT: Stellantis Dealer Hygiene App
# FILE: confidence_score.py
# AUTHOR: Sujan Sreenivasulu
# WEBSITE: https://www.stellantis.com/
# VERSION: 1.0.0
# ============================================================================
# COPYRIGHT: © 2026 STELLANTIS N.V. - INTERNAL USE ONLY
# ============================================================================

"""
Description: Definition of the ConfidenceScore value object.

This file defines the `ConfidenceScore` wrapper, which ensures that all confidence values
flowing through the domain are valid (0.0 to 100.0) and handled consistently.
"""

from dataclasses import dataclass


@dataclass(frozen=True)
class ConfidenceScore:
    """
    Immutable Value Object representing a statistical confidence percentage (0-100).

    Attributes:
        value (float): The numeric score.
    
    WHY frozen=True: Value objects should be immutable to prevent
    accidental state mutations that violate business invariants.
    """
    value: float

    def __post_init__(self):
        """
        Validates the score upon creation.

        Raises:
            ValueError: If value is not between 0 and 100 inclusive.

        WHY: Fail-fast validation at domain boundaries.
        Invalid data should never enter the domain model.
        """
        if not 0.0 <= self.value <= 100.0:
            raise ValueError(f"Confidence score must be between 0 and 100, got {self.value}")

    def is_above_threshold(self, threshold: float) -> bool:
        """
        Checks if the score meets or exceeds a certain requirement.

        Args:
            threshold (float): The minimum acceptable score.

        Returns:
            bool: True if sufficient.

        WHY: Domain method encapsulates comparison logic.
        Prevents scattered threshold checks across codebase (e.g. avoiding floating point errors manually).
        """
        return self.value >= threshold

    def as_percentage(self) -> str:
        """
        Formats the score as a human-readable string.

        Returns:
            str: e.g., "95.50%"
            
        WHY: Presentation concern, but useful for logging/debugging consistently.
        """
        return f"{self.value:.2f}%"

    @classmethod
    def from_rekognition(cls, score: float) -> "ConfidenceScore":
        """
        Factory method creates a score from an AWS Rekognition result.
        
        Rekognition returns 0-100 floats directly.

        Args:
            score (float): Raw score from AWS.

        Returns:
            ConfidenceScore: Domain object.

        WHY: Explicit conversion from infrastructure format to domain format.
        Different vision providers may use different scales (0-1, 0-100, etc).
        """
        return cls(value=score)

    @classmethod
    def from_normalized(cls, score: float) -> "ConfidenceScore":
        """
        Factory method creates a score from a 0.0-1.0 float.

        Args:
            score (float): Normalized score (e.g., 0.95).

        Returns:
            ConfidenceScore: Domain object (converted to 0-100 range).

        WHY: Some models (TFLite, custom) return 0-1 scores.
        This factory handles the conversion explicitly.
        """
        return cls(value=score * 100.0)

# -------------------------------------------------------------------------------------
# End of backend/domain/value_objects/confidence_score.py
# -------------------------------------------------------------------------------------
