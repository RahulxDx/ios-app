# ============================================================================
# PROJECT: Stellantis Dealer Hygiene App
# FILE: domain_exceptions.py
# AUTHOR: Sujan Sreenivasulu
# WEBSITE: https://www.stellantis.com/
# VERSION: 1.0.0
# ============================================================================
# COPYRIGHT: © 2026 STELLANTIS N.V. - INTERNAL USE ONLY
# ============================================================================

"""
Description: Definition of Domain Exceptions.

This file defines the custom exception hierarchy for the domain layer.
All domain-specific errors should inherit from `DomainException`.
These exceptions allow the application layer to handle business errors distinct from
infrastructure errors (like network timeouts or SQL errors).

Usage:
    raise InvalidConfidenceScoreError("Score 105.0 is out of bounds")
"""

class DomainException(Exception):
    """
    Base exception class for all domain-level errors.
    
    Catching this exception allows handlers to distinguish business logic failures
    from system/infrastructure crashes.
    """
    pass


class InvalidConfidenceScoreError(DomainException):
    """
    Raised when a `ConfidenceScore` value is instantiated with an invalid value
    (e.g., outside the 0.0 - 100.0 range).
    """
    pass


class InvalidImageError(DomainException):
    """
    Raised when an image fails domain validation rules.
    
    Examples:
    - Image file size is too large for the vision provider.
    - Image resolution is too low for accurate analysis.
    - Invalid image format.
    """
    pass


class AuditAlreadyFinalizedError(DomainException):
    """
    Raised when an attempt is made to modify an `AuditResult` that has already
    been finalized (e.g., trying to re-analyze an audit that has been manually reviewed).
    
    This enforces the immutability of historical audit records.
    """
    pass

# -------------------------------------------------------------------------------------
# End of backend/domain/exceptions/domain_exceptions.py
# -------------------------------------------------------------------------------------
