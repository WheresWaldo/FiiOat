#!/bin/bash
# Script to create release page and upload files using GitHub API
# Requirement: curl and a token for GitHub
# Original code provided by kuiporro (GitHub)
#
# File must be incremented for every release
# Release note file must be available at the time of uploading

set -e

# Modify versioning for each release where required
VERSION="v17_r41"
REPO="WheresWaldo/FiiOat"
ZIP_FILE="FiiOat_v17_r41.zip"
NOTES_FILE="RELEASE_NOTES_current.md"

echo "=========================================="
echo "  Create Release via GitHub API"
echo "=========================================="
echo ""

# Verify token
if [ -z "$GITHUB_TOKEN" ]; then
    echo "ERROR: GITHUB_TOKEN hasn't been configured"
    echo ""
    echo "To create a token:"
    echo "1. Go to: https://github.com/settings/tokens"
    echo "2. Generate a new token with permissions 'repo'"
    echo "3. Execute: export GITHUB_TOKEN=tu_token"
    echo "4. Return to execute this script"
    exit 1
fi

# Verify archive
if [ ! -f "$ZIP_FILE" ]; then
    echo "ERROR: $ZIP_FILE not found"
    exit 1
fi

if [ ! -f "$NOTES_FILE" ]; then
    echo "ERROR: $NOTES_FILE not found"
    exit 1
fi

# Read notes
RELEASE_NOTES=$(cat "$NOTES_FILE" | jq -Rs .)

echo "Creating release..."
echo ""

# Create the release
RELEASE_RESPONSE=$(curl -s -X POST \
    -H "Authorization: token $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    "https://api.github.com/repos/$REPO/releases" \
    -d "{
        \"tag_name\": \"$VERSION\",
        \"target_commitish\": \"main\",
        \"name\": \"FiiOat $VERSION - Stable Release\",
        \"body\": $RELEASE_NOTES,
        \"draft\": false,
        \"prerelease\": false
    }")

# Verify response
if echo "$RELEASE_RESPONSE" | grep -q "upload_url"; then
    UPLOAD_URL=$(echo "$RELEASE_RESPONSE" | jq -r .upload_url | sed 's/{?name,label}//')
    RELEASE_ID=$(echo "$RELEASE_RESPONSE" | jq -r .id)
    
    echo "✓ Release created (ID: $RELEASE_ID)"
    echo ""
    echo "Uploading archive..."
    
    # Upload the ZIP
    UPLOAD_RESPONSE=$(curl -s -X POST \
        -H "Authorization: token $GITHUB_TOKEN" \
        -H "Accept: application/vnd.github.v3+json" \
        -H "Content-Type: application/zip" \
        --data-binary "@$ZIP_FILE" \
        "$UPLOAD_URL?name=$ZIP_FILE")
    
    if echo "$UPLOAD_RESPONSE" | grep -q "browser_download_url"; then
        echo "✅ Archive uploaded successfully!"
        echo ""
        echo "Release available at:"
        echo "https://github.com/$REPO/releases/tag/$VERSION"
    else
        echo "❌ Error uploading the archive"
        echo "GitHub: $UPLOAD_RESPONSE"
        exit 1
    fi
else
    echo "❌ Error creating the release"
    echo "GitHub: $RELEASE_RESPONSE"
    exit 1
fi
