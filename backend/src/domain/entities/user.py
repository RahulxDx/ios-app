# ============================================================================
# PROJECT: Stellantis Dealer Hygiene App
# FILE: user.py
# AUTHOR: Sujan Sreenivasulu
# WEBSITE: https://www.stellantis.com/
# VERSION: 1.0.0
# ============================================================================
# COPYRIGHT: © 2026 STELLANTIS N.V. - INTERNAL USE ONLY
# ============================================================================

"""
Description: Definition of the User entity.

This file defines the `User` entity, which represents an authorized user of the system (e.g., an Auditor, Admin, or Manager).
It encapsulates user identity, authentication status, and role-based access control attributes.

Key considerations:
- Users are Entities because they have a persistent identity (`user_id`).
- This entity may be hydrated from various sources (SQL DB, Cognito, LDAP).
"""

from dataclasses import dataclass
from datetime import datetime
from uuid import UUID

@dataclass
class User:
    """
    User Domain Entity.

    Represents a recognized actor within the system. This entity is central to authentication
    and authorization flows.

    Attributes:
        user_id (UUID): Unique immutable identifier for the user.
        email (str): The user's email address, serving as a username.
        password_hash (str): Securely hashed password credential.
        full_name (str): Display name of the user.
        role (str): Role designation (e.g., "auditor", "admin") for RBAC.
        created_at (datetime): Timestamp when the user account was created.
        is_active (bool): Flag to indicate if the user is permitted to access the system.
                          Default is True.
    """
    user_id: UUID
    email: str
    password_hash: str
    full_name: str
    role: str
    created_at: datetime
    is_active: bool = True

# -------------------------------------------------------------------------------------
# End of backend/domain/entities/user.py
# -------------------------------------------------------------------------------------
