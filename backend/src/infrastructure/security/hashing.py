"""
============================================================================
FILE: hashing.py
DESCRIPTION: Password Hashing Utility
             This module handles secure password hashing and verification using
             the Passlib library. It specifically uses the 'bcrypt_sha256'
             scheme to overcome the 72-byte limit of standard bcrypt.
============================================================================
PROJECT: Stellantis Dealer Hygiene App
AUTHOR: Srikanth Thiyagarajan
WEBSITE: https://www.stellantis.com/
VERSION: 2.4.0
============================================================================
COPYRIGHT: © 2026 STELLANTIS N.V. - INTERNAL USE ONLY
============================================================================
"""

from __future__ import annotations

from passlib.context import CryptContext

# ============================================================================
# PASSWORD HASHING CONTEXT
# ============================================================================

# Use bcrypt_sha256 to avoid bcrypt's 72-byte password truncation/limit.
# This hashes the password with SHA-256 first, then bcrypts the digest.
# This configuration ensures compatibility and security.
pwd_context = CryptContext(schemes=["bcrypt_sha256"], deprecated="auto")


# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

def _bcrypt_compatible_password(password: str) -> str:
    """
    Normalize password for hashing/verification.

    Standard bcrypt has a 72-byte password limit.
    With bcrypt_sha256 there is no 72-byte password limit, so we can pass
    the password through unchanged. However, we handle None values safely.

    Args:
        password (str): The raw password string.

    Returns:
        str: The normalized password string (empty string if None).
    """
    return "" if password is None else password


class Hasher:
    """
    Utility class for password hashing and verification.
    """

    @staticmethod
    def verify_password(plain_password: str, hashed_password: str) -> bool:
        """
        Verify that a plain-text password matches a hashed password.

        Args:
            plain_password (str): The password provided by the user.
            hashed_password (str): The stored hashed password.

        Returns:
            bool: True if passwords match, False otherwise.
        """
        # pwd_context.verify automatically handles salting and algorithm checking
        return pwd_context.verify(_bcrypt_compatible_password(plain_password), hashed_password)

    @staticmethod
    def get_password_hash(password: str) -> str:
        """
        Generate a secure hash for a password.

        Args:
            password (str): The plain-text password to hash.

        Returns:
            str: The resulting hash string including algorithm and salt.
        """
        # Generates a hash using the configured scheme (bcrypt_sha256)
        return pwd_context.hash(_bcrypt_compatible_password(password))


"""
===========================================================================
END OF FILE: hashing.py
============================================================================
AUTHOR: Srikanth Thiyagarajan
WEBSITE: https://www.stellantis.com/
============================================================================
"""
