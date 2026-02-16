"""
============================================================================
FILE: auth.py
DESCRIPTION: Authentication Routes
             This module handles user registration and authentication endpoints.
             It provides functionality for signing up new users and signing in
             existing users to obtain access tokens.
============================================================================
PROJECT: Stellantis Dealer Hygiene App
AUTHOR: Dinesh Kumar G M
WEBSITE: https://www.stellantis.com/
VERSION: 2.4.0
============================================================================
COPYRIGHT: © 2026 STELLANTIS N.V. - INTERNAL USE ONLY
============================================================================
"""

from fastapi import APIRouter, status, Depends
from sqlalchemy.orm import Session

from ...application.dto.auth_requests import RegisterUserRequest, LoginRequest
from ...application.dto.auth_responses import TokenResponse, UserResponse
from ...application.use_cases.auth import AuthUseCase
from ...infrastructure.persistence.rds_user_repository import RDSUserRepository
from ..dependencies import get_db_session

# === Router Configuration ===
router = APIRouter(prefix="/api/v1/auth", tags=["Authentication"])


# === Dependency Injection ===

def get_auth_use_case(db: Session = Depends(get_db_session)) -> AuthUseCase:
    """
    Dependency injection for AuthUseCase with database repository.

    Args:
        db (Session): Database session from dependency injection.

    Returns:
        AuthUseCase: Configured authentication use case instance.
    """
    user_repo = RDSUserRepository(db)
    return AuthUseCase(user_repo)


# === Route Endpoints ===

@router.post("/signup", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
async def signup(
    request: RegisterUserRequest,
    auth_use_case: AuthUseCase = Depends(get_auth_use_case)
):
    """
    Register a new user in the system.

    Args:
        request (RegisterUserRequest): User registration data.
        auth_use_case (AuthUseCase): Authentication business logic.

    Returns:
        UserResponse: Created user details.
    """
    return await auth_use_case.register(request)


@router.post("/signin", response_model=TokenResponse)
async def signin(
    request: LoginRequest,
    auth_use_case: AuthUseCase = Depends(get_auth_use_case)
):
    """
    Authenticate user and return access token.

    Args:
        request (LoginRequest): User login credentials.
        auth_use_case (AuthUseCase): Authentication business logic.

    Returns:
        TokenResponse: Access token and token type.
    """
    return await auth_use_case.login(request)


"""
============================================================================
END OF FILE: auth.py
============================================================================
AUTHOR: Dinesh Kumar G M
WEBSITE: https://www.stellantis.com/
============================================================================
"""
