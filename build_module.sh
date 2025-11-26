#!/bin/bash
# Script para crear el ZIP del módulo FiiOat para Magisk

set -e

MODULE_NAME="FiiOat"
VERSION=$(grep "^version=" module.prop | cut -d'=' -f2)
BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
ZIP_NAME="${MODULE_NAME}-${VERSION}-${BRANCH}.zip"

echo "=========================================="
echo "  Building FiiOat Module for Magisk"
echo "=========================================="
echo ""
echo "Version: $VERSION"
echo "Branch: $BRANCH"
echo "Output: $ZIP_NAME"
echo ""

# Limpiar ZIP anterior si existe
if [ -f "$ZIP_NAME" ]; then
    echo "Removing old ZIP file..."
    rm "$ZIP_NAME"
fi

# Verificar que los archivos necesarios existan
echo "Checking required files..."
REQUIRED_FILES=(
    "META-INF/com/google/android/update-binary"
    "META-INF/com/google/android/updater-script"
    "FiiOat.sh"
    "service.sh"
    "module.prop"
    "customize.sh"
)

MISSING_FILES=()
for file in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        MISSING_FILES+=("$file")
    fi
done

if [ ${#MISSING_FILES[@]} -ne 0 ]; then
    echo "ERROR: Missing required files:"
    for file in "${MISSING_FILES[@]}"; do
        echo "  - $file"
    done
    exit 1
fi

echo "All required files found!"
echo ""

# Crear el ZIP
echo "Creating ZIP file..."

# Intentar usar zip, luego 7z, luego Python
if command -v zip &> /dev/null; then
    zip -r "$ZIP_NAME" \
        META-INF/ \
        FiiOat.sh \
        service.sh \
        module.prop \
        customize.sh \
        > /dev/null
    ZIP_RESULT=$?
elif command -v 7z &> /dev/null; then
    7z a -tzip "$ZIP_NAME" \
        META-INF/ \
        FiiOat.sh \
        service.sh \
        module.prop \
        customize.sh \
        > /dev/null
    ZIP_RESULT=$?
elif command -v python3 &> /dev/null; then
    python3 << 'PYTHON_SCRIPT'
import zipfile
import os
import sys

zip_name = sys.argv[1]
files = [
    'META-INF/com/google/android/update-binary',
    'META-INF/com/google/android/updater-script',
    'FiiOat.sh',
    'service.sh',
    'module.prop',
    'customize.sh'
]

with zipfile.ZipFile(zip_name, 'w', zipfile.ZIP_DEFLATED) as zipf:
    for file in files:
        if os.path.exists(file):
            if os.path.isdir(file):
                for root, dirs, filenames in os.walk(file):
                    for filename in filenames:
                        file_path = os.path.join(root, filename)
                        arcname = os.path.relpath(file_path, '.')
                        zipf.write(file_path, arcname)
            else:
                zipf.write(file, file)
        else:
            print(f"Warning: {file} not found", file=sys.stderr)
            sys.exit(1)

sys.exit(0)
PYTHON_SCRIPT
    "$ZIP_NAME"
    ZIP_RESULT=$?
else
    echo "ERROR: No ZIP tool found (zip, 7z, or python3 required)"
    exit 1
fi

if [ $ZIP_RESULT -eq 0 ]; then
    ZIP_SIZE=$(du -h "$ZIP_NAME" | cut -f1)
    echo "✓ ZIP created successfully!"
    echo "  File: $ZIP_NAME"
    echo "  Size: $ZIP_SIZE"
    echo ""
    echo "=========================================="
    echo "  Module ready for installation!"
    echo "=========================================="
    echo ""
    echo "Next steps:"
    echo "1. Transfer $ZIP_NAME to your device"
    echo "2. Install via Magisk Manager"
    echo "3. Reboot your device"
    echo ""
else
    echo "ERROR: Failed to create ZIP file"
    exit 1
fi

