#!/bin/bash
# Script to create a release page on GitHub
# Require: curl, jq (optional), and a GitHub token
# Original code provided by kuiporro (GitHub)

set -e

# Modify versioning for each release where required
VERSION="v17_r39"
REPO="WheresWaldo/FiiOat"
ZIP_FILE="FiiOat_v17_r39.zip"
NOTES_FILE="RELEASE_NOTES_current.md"

echo "=========================================="
echo "  Create Release on GitHub"
echo "=========================================="
echo ""
echo "Version: $VERSION"
echo "Repository: $REPO"
echo ""

# Verify that the ZIP exists
if [ ! -f "$ZIP_FILE" ]; then
    echo "ERROR: $ZIP_FILE not found"
    echo "Execute: ./build_module.sh"
    exit 1
fi

# Verify that the release notes exist
if [ ! -f "$NOTES_FILE" ]; then
    echo "ERROR: $NOTES_FILE not found"
    exit 1
fi

# Read the release notes file
RELEASE_NOTES=$(cat "$NOTES_FILE")

echo "Archive ready:"
echo "  - $ZIP_FILE ($(du -h "$ZIP_FILE" | cut -f1))"
echo "  - $NOTES_FILE"
echo ""

# Verify gh CLI exists
if command -v gh &> /dev/null; then
    echo "✓ GitHub CLI (gh) found"
    echo ""
    echo "Creating release with GitHub CLI..."
    echo ""
    
    gh release create "$VERSION" \
        "$ZIP_FILE" \
        --title "FiiOat $VERSION - Stable Release" \
        --notes-file "$NOTES_FILE" \
        --target main
    
    if [ $? -eq 0 ]; then
        echo ""
        echo "✅ Release created successfully!"
        echo ""
        echo "View release at: https://github.com/$REPO/releases/tag/$VERSION"
    else
        echo ""
        echo "❌ Error creating release"
        exit 1
    fi
else
    echo "GitHub CLI (gh) not found"
    echo ""
    echo "Options to create release:"
    echo ""
    echo "1. Instalar GitHub CLI:"
    echo "   - Arch: sudo pacman -S github-cli"
    echo "   - Ubuntu/Debian: sudo apt install gh"
    echo "   - Then: gh auth login"
    echo ""
    echo "2. Create release manually:"
    echo "   - Go to: https://github.com/$REPO/releases/new"
    echo "   - Tag: $VERSION"
    echo "   - Title: FiiOat $VERSION - Stable Release"
    echo "   - Description: Copy the contents of $NOTES_FILE"
    echo "   - Attach: $ZIP_FILE"
    echo "   - Publish release"
    echo ""
    echo "3. Use GitHub API (requires token):"
    echo "   export GITHUB_TOKEN=tu_token"
    echo "   ./create_release_api.sh"
    echo ""
    echo "Archive ready to upload:"
    echo "  - $ZIP_FILE"
    echo "  - $NOTES_FILE (for complete release notes)"
fi
