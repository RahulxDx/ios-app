"""
============================================================================
FILE: models.py
DESCRIPTION: Persistence Models
             SQLAlchemy models for general application data (like Users).
============================================================================
PROJECT: Stellantis Dealer Hygiene App
AUTHOR: Srikanth Thiyagarajan
WEBSITE: https://www.stellantis.com/
VERSION: 2.4.0
============================================================================
COPYRIGHT: © 2026 STELLANTIS N.V. - INTERNAL USE ONLY
============================================================================
"""

from sqlalchemy import Column, String, Boolean, DateTime
from datetime import datetime
from .database import Base

class UserModel(Base):
    """
    SQLAlchemy Model for Users table.
    
    WHY: Maps Python objects to SQL table rows.
    """
    __tablename__ = "users"

    # ==========================================================================
    # PRIMARY KEY
    # ==========================================================================
    user_id = Column(String, primary_key=True, index=True) # Storing UUID as string

    # ==========================================================================
    # USER INFORMATION
    # ==========================================================================
    email = Column(String, unique=True, index=True)
    password_hash = Column(String)
    full_name = Column(String)
    role = Column(String, default="user")

    # ==========================================================================
    # METADATA
    # ==========================================================================
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=datetime.utcnow)


"""
===========================================================================
END OF FILE: models.py
============================================================================
AUTHOR: Srikanth Thiyagarajan
WEBSITE: https://www.stellantis.com/
============================================================================
"""
