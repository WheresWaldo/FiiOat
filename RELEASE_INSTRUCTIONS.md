# Release Creation Instructions for v17_r40

## Option 1: Using GitHub CLI (Recommended)

### Prerequisites:
```bash
# Install GitHub CLI (if you don't have it)
# Arch Linux:
sudo pacman -S github-cli

# Ubuntu/Debian:
sudo apt install gh

# Authenticate
gh auth login
```

### Create Release:
```bash
cd /path/to/FiiOat
./create_release.sh
```

The script automatically:
- Verifies the ZIP exists
- Creates the release with notes
- Uploads the ZIP file

## Option 2: Manually from GitHub Web

1. **Go to releases page**:
   https://github.com/WheresWaldo/FiiOat/releases/new

2. **Fill the form**:
   - **Tag**: `v17_r40` (must match exactly)
   - **Target**: `main`
   - **Release title**: `FiiOat v17_r40 - Stable Release`
   - **Description**: Copy the complete content from `RELEASE_NOTES_current.md`

3. **Attach file**:
   - Click "Attach binaries"
   - Select: `FiiOat_v17_r40.zip`

4. **Publish**:
   - Make sure it's NOT marked as "Pre-release"
   - Click "Publish release"

## Option 3: Using GitHub API

### Prerequisites:
```bash
# You need a GitHub token with 'repo' permissions
# Create token: https://github.com/settings/tokens
export GITHUB_TOKEN=your_token_here
```

### Create Release:
```bash
cd /path/to/FiiOat
./create_release_api.sh
```

## Verification

After creating the release, verify:

1. **Release URL**: https://github.com/WheresWaldo/FiiOat/releases/tag/v17_r40
2. **ZIP file**: Must be available for download
3. **Notes**: Must display correctly formatted

## Release Content

- **Tag**: v17_r40
- **Title**: FiiOat v17_r40 - Stable Release
- **File**: FiiOat_v17_r40.zip
- **Notes**: Content from RELEASE_NOTES_current.md

## Important Notes

- The tag `v17_r40` already exists in the repository (was created earlier)
- If GitHub asks if you want to use the existing tag, select "Use existing tag"
- Make sure the release is marked as "Latest release" if it's the most recent version

