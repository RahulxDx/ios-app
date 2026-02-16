#!/bin/bash
# ============================================================================
# BUILD AND DEPLOY APK - Stellantis Dealer Hygiene App
# ============================================================================

echo "============================================"
echo "  Stellantis APK Build Script"
echo "  EC2 Backend: http://52.90.100.90:8000"
echo "============================================"
echo ""

# Step 1: Clean
echo "[1/4] Cleaning previous builds..."
flutter clean

# Step 2: Get dependencies
echo ""
echo "[2/4] Getting dependencies..."
flutter pub get

# Step 3: Build APK
echo ""
echo "[3/4] Building release APK..."
echo "This may take 2-5 minutes..."
flutter build apk --release

# Step 4: Locate APK
echo ""
echo "[4/4] Build complete!"
echo ""
echo "============================================"
echo "  APK Location:"
echo "  build/app/outputs/flutter-apk/app-release.apk"
echo "============================================"
echo ""
echo "File size:"
ls -lh build/app/outputs/flutter-apk/app-release.apk

echo ""
echo "Next steps:"
echo "1. Copy app-release.apk to your phone"
echo "2. Install using APK Extractor or file manager"
echo "3. Open app and test!"
echo ""
echo "Backend configured: http://52.90.100.90:8000"
echo "============================================"

