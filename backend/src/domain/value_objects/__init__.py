# ============================================================================
# PROJECT: Stellantis Dealer Hygiene App
# FILE: __init__.py
# AUTHOR: Sujan Sreenivasulu
# WEBSITE: https://www.stellantis.com/
# VERSION: 1.0.0
# ============================================================================
# COPYRIGHT: © 2026 STELLANTIS N.V. - INTERNAL USE ONLY
# ============================================================================

"""
Filename: backend/domain/value_objects/__init__.py
Description: Initialization module for Domain Value Objects.

Value Objects are small objects that represent a simple entity whose equality is not based on identity,
but on the content of the held values. They are typically immutable.
Examples include numbers (ConfidenceScore), states (CleanlinessStatus), or attribute bundles (ImageMetadata).

Exports:
    - CleanlinessStatus: Enum representing compliance state.
    - ConfidenceScore: Validated score 0-100.
    - ImageMetadata: Technical details of an image.
"""

from .cleanliness_status import CleanlinessStatus
from .confidence_score import ConfidenceScore
from .image_metadata import ImageMetadata

__all__ = [
    "CleanlinessStatus",
    "ConfidenceScore",
    "ImageMetadata",
]

# -------------------------------------------------------------------------------------
# End of backend/domain/value_objects/__init__.py
# -------------------------------------------------------------------------------------
