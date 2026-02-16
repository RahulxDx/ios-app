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
Filename: backend/domain/__init__.py
Description: Initialization of the Domain Layer.

The Domain Layer is the heart of the application, encapsulating the core business logic, rules, and entities.
It is designed to be completely independent of external frameworks, databases, or infrastructure details.
This isolation ensures that the business logic remains pure, testable, and stable regardless of changes in the technical stack.

By strict enforcement of the Dependency Rule, no outer layer (like Infrastructure or API) can be imported here.
This file serves as the entry point for the domain module, though it typically exposes nothing itself,
serving mainly as a documentation marker for the layer's boundaries.

Dependencies: None (Strictly pure Python)
"""

"""
WHY: The domain layer is the CORE of the application.
It contains zero infrastructure dependencies - only pure business logic.

This layer can be tested WITHOUT:
- AWS credentials
- Database connections
- Network access
- External services

If you import boto3, requests, or any infrastructure library here,
you've violated Clean Architecture.
"""

# -------------------------------------------------------------------------------------
# End of backend/domain/__init__.py
# -------------------------------------------------------------------------------------
