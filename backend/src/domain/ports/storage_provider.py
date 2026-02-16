# ============================================================================
# PROJECT: Stellantis Dealer Hygiene App
# FILE: storage_provider.py
# AUTHOR: Sujan Sreenivasulu
# WEBSITE: https://www.stellantis.com/
# VERSION: 1.0.0
# ============================================================================
# COPYRIGHT: © 2026 STELLANTIS N.V. - INTERNAL USE ONLY
# ============================================================================

"""
Description: Interface definition for Cloud Storage operations.

This file defines the `StorageProvider` interface for binary file storage (blob storage).
It abstracts the details of systems like AWS S3, Google Cloud Storage, or Azure Blob Storage.
The domain layer uses this to request image uploads and downloads without knowing the underlying implementation.

WHY:
- Keeps the domain layer free of boto3 or other vendor-specific SDKs.
- Simplifies testing by allowing mocking of storage operations.
"""

from abc import ABC, abstractmethod
from dataclasses import dataclass
from typing import Optional


@dataclass
class StorageMetadata:
    """
    Data Transfer Object (DTO) containing metadata about a stored file.
    
    This information is returned after a successful upload and is persisted in the domain entity
    to maintain a link to the physical file.

    Attributes:
        bucket (str): The logical container name (S3 bucket).
        key (str): The unique path/identifier for the file within the bucket.
        version_id (Optional[str]): The version identifier (if versioning is enabled).
        etag (Optional[str]): The entity tag (checksum) of the stored object.
        size_bytes (int): Size of the file in bytes.

    WHY: Domain needs to know WHERE the image is stored for audit trail.
    """
    bucket: str
    key: str
    version_id: Optional[str] = None
    etag: Optional[str] = None
    size_bytes: int = 0


class StorageProvider(ABC):
    """
    Port (Abstract Interface) for cloud storage operations.
    
    Follows Hexagonal Architecture:
    - Domain defines the contract ('upload_image', 'delete_image').
    - Infrastructure provides the adapter (e.g., 'S3StorageAdapter').
    """

    @abstractmethod
    async def upload_image(
        self,
        image_bytes: bytes,
        destination_key: str,
        content_type: str = "image/jpeg",
        metadata: Optional[dict] = None
    ) -> StorageMetadata:
        """
        Uploads a raw image file to the storage provider.

        Args:
            image_bytes (bytes): The raw binary content of the image.
            destination_key (str): The desired path key (e.g., "dealer-1/audits/img.jpg").
            content_type (str): The MIME type of the file.
            metadata (Optional[dict]): Custom key-value pairs to tag the object with.

        Returns:
            StorageMetadata: Details about the successfully stored object.

        Raises:
            StorageError: If the upload fails due to network or permission issues.
            
        WHY: Centralized upload logic with consistent error handling.
        """
        pass

    @abstractmethod
    async def download_image(self, bucket: str, key: str) -> bytes:
        """
        Retrieves the raw bytes of an image from storage.

        Args:
            bucket (str): The bucket name.
            key (str): The object key.

        Returns:
            bytes: The raw file content.

        WHY: Sometimes need to retrieve images (e.g., for TFLite local analysis).
        """
        pass

    @abstractmethod
    async def generate_presigned_url(
        self,
        bucket: str,
        key: str,
        expiration_seconds: int = 3600
    ) -> str:
        """
        Generates a temporary, secure URL to access the private file.

        This is used to allow a frontend client or mobile app to view the image
        without needing permanent credentials or routing traffic through the backend.

        Args:
            bucket (str): The bucket name.
            key (str): The object key.
            expiration_seconds (int): How long the URL remains valid (default 1 hour).

        Returns:
            str: The full URL.
            
        WHY: Mobile app or auditors may need direct image access. Presigned URLs avoid exposing credentials.
        """
        pass

    @abstractmethod
    async def delete_image(self, bucket: str, key: str) -> bool:
        """
        Permanently removes an image from storage.

        Args:
            bucket (str): The bucket name.
            key (str): The object key.

        Returns:
            bool: True if deletion was successful.

        WHY: GDPR/retention policies may require deletion.
        """
        pass

    @abstractmethod
    def get_storage_uri(self, bucket: str, key: str) -> str:
        """
        Constructs a standardized URI string for the stored object.

        This is useful for logging and referencing the object in a provider-agnostic way
        (though often defaults to s3:// format).

        Args:
            bucket (str): The bucket name.
            key (str): The object key.

        Returns:
            str: The URI (e.g., "s3://my-bucket/my-key").
        """
        pass

# -------------------------------------------------------------------------------------
# End of backend/domain/ports/storage_provider.py
# -------------------------------------------------------------------------------------
