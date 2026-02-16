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
Filename: backend/domain/services/__init__.py
Description: Initialization module for Domain Services.

Domain services contain business logic that doesn't naturally fit within a single Entity or Value Object.
They typically orchestrate interactions between multiple domain objects or encapsulate complex business rules.

Exports:
    - CleanlinessEvaluator: Service determining if an image represents a clean facility.
    - CleanlinessRules: Configuration object for the evaluator.
"""

from .cleanliness_evaluator import CleanlinessEvaluator, CleanlinessRules

__all__ = [
    "CleanlinessEvaluator",
    "CleanlinessRules",
]

# -------------------------------------------------------------------------------------
# End of backend/domain/services/__init__.py
# -------------------------------------------------------------------------------------
