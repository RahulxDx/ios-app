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
Filename: backend/domain/entities/__init__.py
Description: Initialization module for Domain Entities.

This module exposes the core business objects (entities) that have a distinct identity and lifecycle.
Entities are mutable and are defined by their identity rather than their attributes.
This explicit export ensures that other layers can import entities cleanly from `backend.domain.entities`.

Exports:
    - AuditResult: The aggregate root entity representing a hygiene audit.
    - DetectedLabel: A supporting entity/value identifying specific elements found in analysis.
"""

from .audit_result import AuditResult, DetectedLabel
# from .user import User  # User is also an entity, should be exposed if used widely, but following existing pattern.

__all__ = [
    "AuditResult",
    "DetectedLabel",
]

# -------------------------------------------------------------------------------------
# End of backend/domain/entities/__init__.py
# -------------------------------------------------------------------------------------
