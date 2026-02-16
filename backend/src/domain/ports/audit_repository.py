# ============================================================================
# PROJECT: Stellantis Dealer Hygiene App
# FILE: audit_repository.py
# AUTHOR: Sujan Sreenivasulu
# WEBSITE: https://www.stellantis.com/
# VERSION: 1.0.0
# ============================================================================
# COPYRIGHT: © 2026 STELLANTIS N.V. - INTERNAL USE ONLY
# ============================================================================

"""
Description: Interface definition for Audit Persistence.

This file defines the `AuditRepository` abstract base class (interface).
It follows the Repository Pattern, acting as a collection-like interface for accessing domain objects.

WHY:
- Decouples the domain from the persistence mechanism (DynamoDB, SQL, etc.).
- Allows for easy mocking in unit tests.
- Enables switching database technologies without changing business logic.
"""

from abc import ABC, abstractmethod
from typing import List, Optional
from uuid import UUID

from ..entities import AuditResult


class AuditRepository(ABC):
    """
    Port (Abstract Interface) for audit result persistence.
    
    The infrastructure layer must implement this class (e.g., `DynamoDBAuditRepository`).
    
    WHY: Domain defines WHAT it needs to persist, not HOW.
    Infrastructure decides whether to use DynamoDB, Postgres, etc.
    """

    @abstractmethod
    async def save(self, audit: AuditResult) -> None:
        """
        Persists an `AuditResult` entity to the underlying storage.

        This operation must be idempotent: saving the same audit multiple times
        should update the existing record rather than create duplicates.

        Args:
            audit (AuditResult): The domain entity to save.

        Raises:
            RepositoryError: If the persistence operation fails due to technical errors.
        """
        pass

    @abstractmethod
    async def find_by_id(self, audit_id: UUID) -> Optional[AuditResult]:
        """
        Retrieves a single audit record by its unique identifier.

        Args:
            audit_id (UUID): The unique ID of the audit.

        Returns:
            Optional[AuditResult]: The reconstituted entity if found, None otherwise.
        """
        pass

    @abstractmethod
    async def find_by_dealer_and_checkpoint(
        self,
        dealer_id: str,
        checkpoint_id: str,
        limit: int = 100
    ) -> List[AuditResult]:
        """
        Retrieves a list of audits for a specific checkpoint within a dealer facility.
        
        Useful for viewing the history of a specific location.

        Args:
            dealer_id (str): ID of the dealer.
            checkpoint_id (str): ID of the specific checkpoint (e.g., "Service Bay 1").
            limit (int): Max number of records to return.

        Returns:
            List[AuditResult]: A list of matching audits, potentially empty.
        """
        pass

    @abstractmethod
    async def find_pending_reviews(self, limit: int = 100) -> List[AuditResult]:
        """
        Retrieves a list of audits that require manual human review.

        These are audits with status `REQUIRES_MANUAL_REVIEW` or `INSUFFICIENT_DATA`.
        This powers the auditor's "To-Do" queue.

        Args:
            limit (int): Max number of items to fetch.

        Returns:
            List[AuditResult]: Audits pending review.
        """
        pass

    @abstractmethod
    async def count_by_status(self, dealer_id: str) -> dict:
        """
        Aggregates audit counts grouped by their cleanliness status for a specific dealer.

        Used for generating compliance dashboards and high-level metrics.

        Args:
            dealer_id (str): The dealer to get metrics for.

        Returns:
            dict: A dictionary mapping status strings to counts.
                  Example: {'CLEAN': 150, 'NOT_CLEAN': 20, 'REQUIRES_MANUAL_REVIEW': 5}
        """
        pass

# -------------------------------------------------------------------------------------
# End of backend/domain/ports/audit_repository.py
# -------------------------------------------------------------------------------------
