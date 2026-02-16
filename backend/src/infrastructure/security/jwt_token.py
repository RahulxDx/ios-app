"""
============================================================================
FILE: jwt_token.py
DESCRIPTION: JWT Token Management
             This module provides utilities for creating and verifying JSON Web Tokens (JWT).
             It handles token encoding with expiration times and decoding/validation.
============================================================================
PROJECT: Stellantis Dealer Hygiene App
AUTHOR: Srikanth Thiyagarajan
WEBSITE: https://www.stellantis.com/
VERSION: 2.4.0
============================================================================
COPYRIGHT: © 2026 STELLANTIS N.V. - INTERNAL USE ONLY
============================================================================
"""

from datetime import datetime, timedelta
from typing import Optional
from jose import jwt
import os

# ============================================================================
# JWT CONFIGURATION
# ============================================================================

# Secret key used for signing the JWT. 
# In production, this must be set via environment variable.
SECRET_KEY = os.getenv("SECRET_KEY", "your-secret-key-change-me")
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30

# ============================================================================
# TOKEN GENERATION & VERIFICATION
# ============================================================================

def create_access_token(data: dict, expires_delta: Optional[timedelta] = None):
    """
    Create a new JWT access token.

    Args:
        data (dict): Payload data to include in the token (e.g., user_id).
        expires_delta (Optional[timedelta]): Custom expiration duration. 
                                             If None, defaults to 15 minutes.

    Returns:
        str: Encoded JWT string.
    """
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=15)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

def decode_access_token(token: str):
    """
    Decode and verify a JWT access token.

    Args:
        token (str): The JWT string to decode.

    Returns:
        dict: The decoded payload if valid.
        None: If the token is invalid or expired.
    """
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        return payload
    except jwt.JWTError:
        return None

"""
===========================================================================
END OF FILE: jwt_token.py
============================================================================
AUTHOR: Srikanth Thiyagarajan
WEBSITE: https://www.stellantis.com/
============================================================================
"""
