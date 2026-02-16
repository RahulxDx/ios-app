# ============================================================================
# PROJECT: Stellantis Dealer Hygiene App
# FILE: image_metadata.py
# AUTHOR: Sujan Sreenivasulu
# WEBSITE: https://www.stellantis.com/
# VERSION: 1.0.0
# ============================================================================
# COPYRIGHT: © 2026 STELLANTIS N.V. - INTERNAL USE ONLY
# ============================================================================

"""
Description: Definition of the ImageMetadata value object.

This file defines the `ImageMetadata` container, which holds all technical details about an image
processed by the system. It ensures all necessary traceability information is kept together.
"""

from dataclasses import dataclass
from datetime import datetime
from typing import Optional
from uuid import UUID


@dataclass(frozen=True)
class ImageMetadata:
    """
    Immutable Value Object containing technical metadata about an analyzed image.

    It creates a link between the abstract analysis result and the physical file stored in the cloud.

    Attributes:
        image_id (UUID): Unique ID assigned to this image ingestion event.
        dealer_id (str): ID of the dealer who owns the facility.
        checkpoint_id (str): Specific location ID (e.g., "Entrance").
        s3_bucket (str): Storage bucket name.
        s3_key (str): Storage path key.
        uploader_id (str): User ID of the person who took/uploaded the photo.
        captured_at (datetime): Time the photo was taken (if available).
        uploaded_at (datetime): Time the photo was received by the backend.
        file_size_bytes (int): Physical size.
        content_type (str): MIME type (default image/jpeg).
        width_px (Optional[int]): Image width.
        height_px (Optional[int]): Image height.

    WHY: Audit requirements demand complete traceability:
    - WHO uploaded the image (uploader_id)
    - WHEN it was captured (captured_at)
    - WHERE it's stored (s3_key)
    - WHICH dealer/checkpoint it belongs to
    """
    image_id: UUID
    dealer_id: str
    checkpoint_id: str
    s3_bucket: str
    s3_key: str
    uploader_id: str  # Mobile app user ID
    captured_at: datetime
    uploaded_at: datetime
    file_size_bytes: int
    content_type: str = "image/jpeg"
    width_px: Optional[int] = None
    height_px: Optional[int] = None

    def s3_uri(self) -> str:
        """
        Returns the standardized S3 URI for this image.

        Returns:
            str: e.g. "s3://my-bucket/folder/img.jpg"

        WHY: Standardized S3 URI for logging and debugging.
        """
        return f"s3://{self.s3_bucket}/{self.s3_key}"

    def is_valid_for_analysis(self) -> bool:
        """
        Checks if the image meets technical requirements for AI processing.

        Returns:
            bool: True if valid.

        WHY: Business rule to prevent analysis of invalid images.
        Saves Rekognition costs on obviously bad images (e.g. too small or massive).
        """
        # Max 15MB for Rekognition
        if self.file_size_bytes > 15 * 1024 * 1024:
            return False
        
        # Minimum resolution for meaningful analysis
        if self.width_px and self.height_px:
            if self.width_px < 640 or self.height_px < 480:
                return False
        
        return True

    def age_in_days(self, reference_time: datetime) -> int:
        """
        Calculates how old the image is relative to a reference time.

        Args:
            reference_time (datetime): The point in time to compare against.

        Returns:
            int: Number of days.
            
        WHY: Audit retention policies may need this (e.g., "delete images older than 90 days").
        """
        delta = reference_time - self.captured_at
        return delta.days

# -------------------------------------------------------------------------------------
# End of backend/domain/value_objects/image_metadata.py
# -------------------------------------------------------------------------------------
