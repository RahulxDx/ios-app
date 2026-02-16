# ============================================================================
# PROJECT: Stellantis Dealer Hygiene App
# FILE: __init__.py
# AUTHOR: Sujan Sreenivasulu
# WEBSITE: https://www.stellantis.com/
# VERSION: 1.0.0
# ============================================================================
# COPYRIGHT: © 2026 STELLANTIS N.V. - INTERNAL USE ONLY
# ============================================================================

"""
Filename: backend/domain/ports/__init__.py
Description: Initialization of Domain Ports (Interfaces).

This module exports the interfaces (ports) that the domain layer expects the infrastructure layer to implement.
This is a key component of Hexagonal Architecture (Ports and Adapters):
- The Domain defines the Port (e.g., "I need a way to save an audit").
- The Infrastructure implements the Adapter (e.g., "Here is a concrete class that saves audits to DynamoDB").

Exports:
    - AuditRepository: Persisting audit results.
    - StorageProvider: Saving/retrieving files from cloud storage.
    - VisionProvider: Analyzing images with AI.
"""

from .audit_repository import AuditRepository
from .storage_provider import StorageProvider, StorageMetadata
from .vision_provider import VisionProvider, VisionAnalysisResult, VisionLabel

__all__ = [
    "VisionProvider",
    "VisionAnalysisResult",
    "VisionLabel",
    "StorageProvider",
    "StorageMetadata",
    "AuditRepository",
]

# -------------------------------------------------------------------------------------
# End of backend/domain/ports/__init__.py
# -------------------------------------------------------------------------------------
