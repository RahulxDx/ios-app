"""
============================================================================
FILE: manual_audit_db.py
DESCRIPTION: Database Configuration for Manual Audit
             This module handles the database configuration for the manual audit system.
             It establishes a connection to the PostgreSQL database using SQLAlchemy,
             manages the session lifecycle, and provides utility functions for
             creating tables and testing the connection.
============================================================================
PROJECT: Stellantis Dealer Hygiene App
AUTHOR: Srikanth Thiyagarajan
WEBSITE: https://www.stellantis.com/
VERSION: 2.4.0
============================================================================
COPYRIGHT: © 2026 STELLANTIS N.V. - INTERNAL USE ONLY
============================================================================
"""

import os
import logging
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, Session
from sqlalchemy.pool import QueuePool
from contextlib import contextmanager
from typing import Generator

from src.infrastructure.database.manual_audit_models import Base

# Configure logger for this module
logger = logging.getLogger(__name__)

# ============================================================================
# DATABASE CONFIGURATION
# ============================================================================

# AWS RDS PostgreSQL connection string
# Format: postgresql://username:password@host:port/database
# The DATABASE_URL environment variable is used to configure the connection.
# If not set, it defaults to a local development database.
DATABASE_URL = os.getenv(
    'DATABASE_URL',
    'postgresql://postgres:password@localhost:5432/stellantis_hygiene'
)

# Fix for Render or other cloud platforms that provide postgres:// URLs
# SQLAlchemy requires the protocol to be 'postgresql://' instead of 'postgres://'
if DATABASE_URL.startswith('postgres://'):
    DATABASE_URL = DATABASE_URL.replace('postgres://', 'postgresql://', 1)

# ============================================================================
# SQLALCHEMY ENGINE
# ============================================================================

# Create SQLAlchemy engine
# The engine is the starting point for any SQLAlchemy application.
# It manages the connection pool and dialect.
engine = create_engine(
    DATABASE_URL,
    poolclass=QueuePool,
    pool_size=10,        # The size of the pool to be maintained
    max_overflow=20,     # The maximum overflow size of the pool
    pool_pre_ping=True,  # Verify connections before using them to avoid stale connections
    echo=False,          # Set to True for SQL query logging (useful for debugging)
)

# ============================================================================
# SESSION FACTORY
# ============================================================================

# Create session factory
# SessionLocal is a factory for creating new Session objects.
# autocommit=False: Changes are not committed automatically.
# autoflush=False: Changes are not flushed to the database automatically.
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


def create_tables():
    """
    Create all tables in the database based on the defined models.

    This function inspects the metadata of the Base class and issues
    CREATE statements for all tables that do not exist.
    It is typically run on application startup to ensure the schema exists.

    Raises:
        Exception: If there is an error during table creation.
    """
    try:
        logger.info("Attempting to create database tables...")
        Base.metadata.create_all(bind=engine)
        print("✅ Database tables created successfully")
        logger.info("Database tables created successfully.")
    except Exception as e:
        print(f"❌ Error creating database tables: {e}")
        logger.error(f"Error creating database tables: {e}", exc_info=True)
        raise


def get_db() -> Generator[Session, None, None]:
    """
    Dependency function to get a database session.

    This function creates a new database session for a request and guarantees
    that the session is closed after the request is processed, even if an
    exception occurs. It is designed to be used with FastAPI's dependency injection system.

    Yields:
        Session: A SQLAlchemy database session.

    Usage in FastAPI endpoints:
        @app.post("/endpoint")
        def endpoint(db: Session = Depends(get_db)):
            ...
    """
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


@contextmanager
def get_db_context():
    """
    Context manager for database session management.

    This utility allows using a database session within a 'with' statement.
    It automatically handles committing the transaction on success and
    rolling back on failure, ensuring data integrity. The session is always
    closed at the end of the block.

    Yields:
        Session: A SQLAlchemy database session.

    Usage:
        with get_db_context() as db:
            db.add(new_object)
            # Commit happens automatically if no exception is raised
    """
    db = SessionLocal()
    try:
        yield db
        db.commit()
    except Exception:
        db.rollback()
        raise
    finally:
        db.close()


def test_connection() -> bool:
    """
    Test the database connection.

    This function attempts to execute a simple 'SELECT 1' query to verify
    that the application can successfully communicate with the database.

    Returns:
        bool: True if the connection is successful, False otherwise.
    """
    try:
        with engine.connect() as conn:
            conn.execute("SELECT 1")
        print("✅ Database connection successful")
        return True
    except Exception as e:
        print(f"❌ Database connection failed: {e}")
        return False


"""
===========================================================================
END OF FILE: manual_audit_db.py
============================================================================
AUTHOR: Srikanth Thiyagarajan
WEBSITE: https://www.stellantis.com/
============================================================================
"""
