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
Filename: backend/domain/exceptions/__init__.py
Description: Initialization module for Domain Exceptions.

This module exposes the exception hierarchy used throughout the domain layer.
These exceptions represent business-level error conditions (e.g., "Audit already finalized")
rather than technical faults (e.g., "Database connection failed").
"""

from .domain_exceptions import (
    AuditAlreadyFinalizedError,
    DomainException,
    InvalidConfidenceScoreError,
    InvalidImageError,
)

__all__ = [
    "DomainException",
    "InvalidConfidenceScoreError",
    "InvalidImageError",
    "AuditAlreadyFinalizedError",
]

# -------------------------------------------------------------------------------------
# End of backend/domain/exceptions/__init__.py
# -------------------------------------------------------------------------------------
