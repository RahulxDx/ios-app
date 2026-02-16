"""
============================================================================
FILE: __init__.py
DESCRIPTION: Vision Adapters Initialization
             Export vision adapters for easier access.
============================================================================
PROJECT: Stellantis Dealer Hygiene App
AUTHOR: Srikanth Thiyagarajan
WEBSITE: https://www.stellantis.com/
VERSION: 2.4.0
============================================================================
COPYRIGHT: © 2026 STELLANTIS N.V. - INTERNAL USE ONLY
============================================================================
"""

"""Vision adapters initialization"""

from .rekognition_adapter import RekognitionAdapter
from .tflite_adapter import TFLiteAdapter
from .gemini_adapter import GeminiAdapter
from .fallback_vision_provider import FallbackVisionProvider

"""
===========================================================================
END OF FILE: __init__.py
============================================================================
AUTHOR: Srikanth Thiyagarajan
WEBSITE: https://www.stellantis.com/
============================================================================
"""
