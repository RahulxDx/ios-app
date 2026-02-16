# ============================================================================
# PROJECT: Stellantis Dealer Hygiene App
# FILE: user_repository.py
# AUTHOR: Sujan Sreenivasulu
# WEBSITE: https://www.stellantis.com/
# VERSION: 1.0.0
# ============================================================================
# COPYRIGHT: © 2026 STELLANTIS N.V. - INTERNAL USE ONLY
# ============================================================================

"""
Description: Interface definition for User persistence.

This file defines the `UserRepository` abstract base class (interface).
It facilitates the loading and saving of `User` entities, abstracting away the specifics
of the data store (e.g., SQL database, NoSQL document store, or external identity provider).
"""

from abc import ABC, abstractmethod
from typing import Optional
from uuid import UUID

from ..entities.user import User

class UserRepository(ABC):
    """
    Port (Abstract Interface) for User Persistence.
    
    Implementations of this interface are responsible for mapping domain `User` entities
    to/from the underlying database records.

    WHY: Abstract interface to decouple domain from database.
    """
    
    @abstractmethod
    async def save(self, user: User) -> User:
        """
        Persists a User entity.

        If the user does not exist, it creates a new record.
        If it exists, it updates the existing record.

        Args:
            user (User): The domain entity to save.

        Returns:
            User: The saved entity (potentially with updated fields like timestamps).
        """
        pass
    
    @abstractmethod
    async def get_by_email(self, email: str) -> Optional[User]:
        """
        Retrieves a user by their email address.

        This is commonly used during authentication to look up credentials.

        Args:
            email (str): The email address to search for.

        Returns:
            Optional[User]: The user entity if found, None otherwise.
        """
        pass
    
    @abstractmethod
    async def get_by_id(self, user_id: UUID) -> Optional[User]:
        """
        Retrieves a user by their unique UUID.

        Args:
            user_id (UUID): The unique user identifier.

        Returns:
            Optional[User]: The user entity if found, None otherwise.
        """
        pass

# -------------------------------------------------------------------------------------
# End of backend/domain/ports/user_repository.py
# -------------------------------------------------------------------------------------
