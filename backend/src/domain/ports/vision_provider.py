# ============================================================================
# PROJECT: Stellantis Dealer Hygiene App
# FILE: vision_provider.py
# AUTHOR: Sujan Sreenivasulu
# WEBSITE: https://www.stellantis.com/
# VERSION: 1.0.0
# ============================================================================
# COPYRIGHT: © 2026 STELLANTIS N.V. - INTERNAL USE ONLY
# ============================================================================

"""
Description: Interface for computer vision analysis services.

This file defines the abstract contract for any service that analyzes images to detect objects.
It uses the Strategy Pattern to allow swapping between different providers (e.g., AWS Rekognition,
Google Vision, Custom TFLite models) without affecting the core domain logic.

The `VisionProvider` is the "Port" in the Hexagonal Architecture, and the `VisionAnalysisResult`
is the normalized DTO that the domain layer consumes.
"""

from abc import ABC, abstractmethod
from dataclasses import dataclass
from typing import List

from ..value_objects import ConfidenceScore


@dataclass
class VisionLabel:
    """
    Normalized representation of a single object/concept detected in an image.

    Different providers return data in different shapes (e.g., JSON keys, list formats).
    This class serves as a canonical format for the domain to use universally.

    Attributes:
        name (str): The label/class name (e.g., "Car", "Rust").
        confidence (ConfidenceScore): Normalized confidence 0-100.
        category (str): Optional grouping (e.g., "cleanliness", "safety").

    WHY: Different vision providers return different formats:
    - Rekognition: {'Name': 'Dirt', 'Confidence': 95.5}
    - TFLite: {0: 0.955, 1: 0.045} (index-based)
    - Custom: varies
    
    This dataclass normalizes ALL formats into domain language.
    """
    name: str
    confidence: ConfidenceScore
    category: str = "general"  # e.g., "cleanliness", "safety", "equipment"


@dataclass
class VisionAnalysisResult:
    """
    Aggregate result container for a complete vision analysis session.

    It holds the list of all detected labels and metadata about the analysis process itself.

    Attributes:
        labels (List[VisionLabel]): All detected objects.
        moderation_labels (List[VisionLabel]): Content safety warnings (optional).
        text_detections (List[str]): OCR results (optional, for future use).
        provider_name (str): Identifier of the service used (e.g. "rekognition").
        model_version (str): Version of the model used.
        processing_time_ms (int): Time taken for the analysis.
    
    WHY: Encapsulates everything a vision provider returns.
    Domain uses this to make business decisions.
    """
    labels: List[VisionLabel]
    moderation_labels: List[VisionLabel] = None  # e.g., explicit content detection
    text_detections: List[str] = None  # OCR results (future use)
    provider_name: str = "unknown"
    model_version: str = "unknown"
    processing_time_ms: int = 0

    @property
    def highest_confidence_label(self) -> VisionLabel:
        """
        Convenience property to get the single most likely detection.
        
        WHY: Often need the most confident prediction for summary displays.
        """
        return max(self.labels, key=lambda x: x.confidence.value)


class VisionProvider(ABC):
    """
    Port (Abstract Interface) for vision analysis providers.
    
    This interface defines the operations available for analyzing images.
    Implementations (Adapters) usually wrap external API client libraries (like boto3).

    WHY: Strategy Pattern implementation.
    - Application layer depends on THIS interface, not concrete implementations.
    - Infrastructure layer provides adapters (RekognitionAdapter, TFLiteAdapter).
    - We can swap providers without touching domain/application code.
    
    Design Decision: async/await for I/O-bound operations.
    WHY: Rekognition API calls are network I/O - async enables concurrency.
    """

    @abstractmethod
    async def analyze_image(
        self,
        image_bytes: bytes,
        max_labels: int = 50,
        min_confidence: float = 70.0
    ) -> VisionAnalysisResult:
        """
        Analyzes a raw image payload to detect labels.

        Args:
            image_bytes (bytes): The raw binary content of the image (JPEG/PNG).
            max_labels (int): limit the number of returned labels.
            min_confidence (float): filter out predictions below this threshold.

        Returns:
            VisionAnalysisResult: The normalized findings.

        Raises:
            VisionProviderError: If the analysis service fails.

        WHY async: Network calls to Rekognition/external services are I/O-bound.
        """
        pass

    @abstractmethod
    async def analyze_image_from_s3(
        self,
        bucket: str,
        key: str,
        max_labels: int = 50,
        min_confidence: float = 70.0
    ) -> VisionAnalysisResult:
        """
        Analyzes an image that is already stored in S3.

        This is an optimization to avoid downloading the image to the backend 
        just to re-upload it to the vision service (if they are in the same cloud).

        Args:
            bucket (str): S3 bucket name.
            key (str): S3 object key.
            max_labels (int): Limit returned labels.
            min_confidence (float): Confidence threshold.

        Returns:
            VisionAnalysisResult: The normalized findings.

        WHY: Rekognition supports S3 URIs directly - avoids downloading images.
        Saves bandwidth and latency.
        """
        pass

    @abstractmethod
    def get_provider_name(self) -> str:
        """
        Returns the unique identifier of this provider implementation.
        
        WHY: Audit trail - record which provider generated results.
        """
        pass

    @abstractmethod
    def get_model_version(self) -> str:
        """
        Returns the version string of the underlying model.
        
        WHY: Different model versions may have different accuracy.
        Required for tracking model drift or performance changes over time.
        """
        pass

# -------------------------------------------------------------------------------------
# End of backend/domain/ports/vision_provider.py
# -------------------------------------------------------------------------------------
