"""
============================================================================
FILE: vision.py
DESCRIPTION: Vision Analysis API Routes (Gemini-specific)
             This module defines endpoints for Gemini-powered vision analysis.
============================================================================
PROJECT: Stellantis Dealer Hygiene App
AUTHOR: GitHub Copilot
WEBSITE: https://www.stellantis.com/
VERSION: 1.0.0
============================================================================
COPYRIGHT: © 2026 STELLANTIS N.V. - INTERNAL USE ONLY
============================================================================
"""

import logging
from typing import Optional, List, Dict
from uuid import UUID

from fastapi import APIRouter, Depends, File, Form, UploadFile, HTTPException, status
from pydantic import BaseModel, Field

from ...application.use_cases.analyze_cleanliness import (
    AnalyzeCleanlinessUseCase,
    AnalyzeCleanlinessCommand
)
from ...domain.value_objects import CleanlinessStatus
from ..dependencies import get_analyze_use_case, get_current_user

# Configure logger
logger = logging.getLogger(__name__)

# === Router Configuration ===
router = APIRouter(prefix="/api/v1/vision", tags=["Vision Analysis"])


# === Data Transfer Objects (DTOs) ===

class VisionAnalysisResponse(BaseModel):
    """
    API response for Gemini vision analysis.

    WHY: Pydantic model for automatic JSON serialization and OpenAPI docs.
    """
    audit_id: UUID
    dealer_id: str
    checkpoint_id: str
    status: CleanlinessStatus
    confidence: float
    reason: str
    negative_labels: List[Dict]
    image_url: Optional[str] = None
    analyzed_at: str

    class Config:
        json_schema_extra = {
            "example": {
                "audit_id": "123e4567-e89b-12d3-a456-426614174000",
                "dealer_id": "dealer-001",
                "checkpoint_id": "reception",
                "status": "CLEAN",
                "confidence": 94.5,
                "reason": "No cleanliness issues detected",
                "negative_labels": [],
                "analyzed_at": "2024-01-15T10:30:00Z"
            }
        }


# === Route Endpoints ===

@router.post(
    "/analyze/gemini",
    response_model=VisionAnalysisResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Analyze facility cleanliness using Gemini AI",
    description="""
    Upload a facility image for automated cleanliness analysis using Google Gemini.

    **Process:**
    1. Image uploaded to S3
    2. Google Gemini analyzes image
    3. Business rules evaluate cleanliness
    4. Results stored for audit trail

    **Returns:**
    - CLEAN: Facility passes hygiene standards
    - NOT_CLEAN: Issues detected (see negative_labels for details)
    - REQUIRES_MANUAL_REVIEW: Low confidence, needs human review
    - INSUFFICIENT_DATA: Unable to analyze

    **CORS:** Enabled for all origins
    """
)
async def analyze_with_gemini(
    dealer_id: str = Form(..., description="Dealer identifier"),
    checkpoint_id: str = Form(..., description="Checkpoint/location identifier"),
    image: UploadFile = File(..., description="Facility image (JPEG/PNG, max 15MB)"),
    min_confidence: float = Form(70.0, ge=0.0, le=100.0),
    use_case: AnalyzeCleanlinessUseCase = Depends(get_analyze_use_case),
    current_user: dict = Depends(get_current_user)
):
    """
    Analyze facility image for cleanliness using Gemini AI.

    WHY: Form data (not JSON) because we're uploading a file.

    Security: Requires authentication (current_user dependency).
    WHY: Only authorized mobile app users can submit audits.
    """
    # Validation: Check file type
    if image.content_type not in ["image/jpeg", "image/png"]:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid image format. Must be JPEG or PNG."
        )

    # Validation: Check file size
    image_bytes = await image.read()
    size_mb = len(image_bytes) / (1024 * 1024)

    if size_mb > 15:
        raise HTTPException(
            status_code=status.HTTP_413_REQUEST_ENTITY_TOO_LARGE,
            detail=f"Image too large ({size_mb:.1f}MB). Maximum 15MB."
        )

    logger.info(
        f"[Gemini] Received analysis request for dealer={dealer_id}, checkpoint={checkpoint_id}",
        extra={
            "dealer_id": dealer_id,
            "checkpoint_id": checkpoint_id,
            "uploader_id": current_user['user_id'],
            "file_size_mb": size_mb
        }
    )

    try:
        # Execute use case
        command = AnalyzeCleanlinessCommand(
            dealer_id=dealer_id,
            checkpoint_id=checkpoint_id,
            uploader_id=current_user['user_id'],
            image_bytes=image_bytes,
            content_type=image.content_type,
            min_confidence=min_confidence
        )

        audit_result = await use_case.execute(command)

        # Convert domain entity to API response
        return VisionAnalysisResponse(
            audit_id=audit_result.audit_id,
            dealer_id=audit_result.image_metadata.dealer_id,
            checkpoint_id=audit_result.image_metadata.checkpoint_id,
            status=audit_result.status,
            confidence=audit_result.overall_confidence.value,
            reason=audit_result.reason,
            negative_labels=[
                {"name": label.name, "confidence": label.confidence.value}
                for label in audit_result.negative_labels
            ],
            analyzed_at=audit_result.analyzed_at.isoformat() + "Z"
        )

    except Exception as e:
        logger.error(f"[Gemini] Analysis failed: {str(e)}", exc_info=True)

        # WHY: Translate exceptions to appropriate HTTP errors
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Analysis failed: {str(e)}"
        )


"""
============================================================================
END OF FILE: vision.py
============================================================================
AUTHOR: GitHub Copilot
WEBSITE: https://www.stellantis.com/
============================================================================
"""

