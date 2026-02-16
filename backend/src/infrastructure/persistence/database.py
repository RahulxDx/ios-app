"""
============================================================================
FILE: database.py
DESCRIPTION: Database Persistence Layer
             This module provides a generic Database class for managing SQLAlchemy
             connections and sessions. It encapsulates the engine creation and
             session factory logic.
============================================================================
PROJECT: Stellantis Dealer Hygiene App
AUTHOR: Srikanth Thiyagarajan
WEBSITE: https://www.stellantis.com/
VERSION: 2.4.0
============================================================================
COPYRIGHT: © 2026 STELLANTIS N.V. - INTERNAL USE ONLY
============================================================================
"""

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base
from typing import Generator

# why: Need a centralized place for DB connections
# Base model for all ORM models
# declarative_base() allows us to create a base class that our models will inherit from.
Base = declarative_base()

class Database:
    """
    A wrapper around SQLAlchemy's engine and sessionmaker.

    This class handles the initialization of the database engine and providing
    sessions for database operations. It supports both SQLite and other
    databases (like PostgreSQL) by adjusting connection arguments.
    """

    # ==========================================================================
    # INITIALIZATION
    # ==========================================================================
    def __init__(self, db_url: str):
        """
        Initialize the Database instance.

        Args:
            db_url (str): The database connection URL (e.g., sqlite:///./test.db).
                          Supports PostgreSQL, SQLite, etc.
        """
        # Check if SQLite is being used (needs check_same_thread=False)
        # SQLite by default prevents sharing connections across threads.
        # FastAPI is multi-threaded, so we need to disable this check for SQLite.
        connect_args = {"check_same_thread": False} if "sqlite" in db_url else {}
        
        # Create the SQLAlchemy engine
        # The engine maintains a pool of connections to the database.
        self.engine = create_engine(
            db_url, 
            connect_args=connect_args
        )

        # Create the session factory
        # autocommit=False: We want to manually commit transactions to ensure atomicity.
        # autoflush=False: We want to manually flush changes to control when SQL is emitted.
        self.SessionLocal = sessionmaker(
            autocommit=False, 
            autoflush=False, 
            bind=self.engine
        )

    # ==========================================================================
    # DEPENDENCY INJECTION
    # ==========================================================================
    def get_db(self) -> Generator:
        """
        Dependency for getting a database session.
        
        Usage:
            @app.get("/items/")
            def read_items(db: Session = Depends(get_db)):
                ...

        This method is intended to be used with FastAPI's 'Depends' system.
        It yields a database session and ensures it is closed after use,
        even if an exception occurs.

        Yields:
            Session: A SQLAlchemy database session.
        """
        db = self.SessionLocal()
        try:
            yield db
        finally:
            db.close()

"""
===========================================================================
END OF FILE: database.py
============================================================================
AUTHOR: Srikanth Thiyagarajan
WEBSITE: https://www.stellantis.com/
============================================================================
"""
