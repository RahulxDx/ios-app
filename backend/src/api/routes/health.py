"""
============================================================================
FILE: health.py
DESCRIPTION: Health Check Endpoint
             This module provides a health check endpoint to verify the API status.
             It is used by load balancers and orchestrators to ensure availability.
============================================================================
PROJECT: Stellantis Dealer Hygiene App
AUTHOR: Dinesh Kumar G M
WEBSITE: https://www.stellantis.com/
VERSION: 2.4.0
============================================================================
COPYRIGHT: © 2026 STELLANTIS N.V. - INTERNAL USE ONLY
============================================================================
"""

from fastapi import APIRouter

# === Router Configuration ===
router = APIRouter(tags=["Health"])


# === Route Endpoints ===

@router.get("/health")
async def health_check():
    """
    Health check endpoint.

    Returns:
        dict: Status information about the API.
    """
    return {
        "status": "healthy",
        "version": "1.0.0",
        "message": "API is running"
    }


"""
============================================================================
END OF FILE: health.py
============================================================================
AUTHOR: Dinesh Kumar G M
WEBSITE: https://www.stellantis.com/
============================================================================
"""
