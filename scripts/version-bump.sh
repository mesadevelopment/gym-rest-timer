#!/bin/bash

# Version Bump Script for Gym Rest Timer
# Usage: ./scripts/version-bump.sh [major|minor|patch] [message]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if version type is provided
if [ -z "$1" ]; then
    echo -e "${RED}Error: Version type required (major|minor|patch)${NC}"
    echo "Usage: ./scripts/version-bump.sh [major|minor|patch] [message]"
    exit 1
fi

VERSION_TYPE=$1
MESSAGE=${2:-"Bump version"}

# Read current version
CURRENT_VERSION=$(cat VERSION 2>/dev/null || echo "0.0.0")
IFS='.' read -ra VERSION_PARTS <<< "$CURRENT_VERSION"
MAJOR=${VERSION_PARTS[0]:-0}
MINOR=${VERSION_PARTS[1]:-0}
PATCH=${VERSION_PARTS[2]:-0}

# Bump version based on type
case $VERSION_TYPE in
    major)
        MAJOR=$((MAJOR + 1))
        MINOR=0
        PATCH=0
        ;;
    minor)
        MINOR=$((MINOR + 1))
        PATCH=0
        ;;
    patch)
        PATCH=$((PATCH + 1))
        ;;
    *)
        echo -e "${RED}Error: Invalid version type. Use major, minor, or patch${NC}"
        exit 1
        ;;
esac

NEW_VERSION="$MAJOR.$MINOR.$PATCH"

echo -e "${YELLOW}Current version: $CURRENT_VERSION${NC}"
echo -e "${GREEN}New version: $NEW_VERSION${NC}"

# Update VERSION file
echo "$NEW_VERSION" > VERSION
echo -e "${GREEN}✓ Updated VERSION file${NC}"

# Update CHANGELOG.md (add unreleased section if needed)
if ! grep -q "## \[Unreleased\]" CHANGELOG.md; then
    sed -i '' '1i\
## [Unreleased]\
\
### Added\
- TBD\
\
' CHANGELOG.md
fi

# Add version entry to CHANGELOG.md
sed -i '' "/^## \[Unreleased\]/a\\
\\
## [$NEW_VERSION] - $(date +%Y-%m-%d)\\
\\
### Added\\
- TBD\\
\\
" CHANGELOG.md

echo -e "${GREEN}✓ Updated CHANGELOG.md${NC}"

# Note about Xcode project
echo -e "${YELLOW}⚠ Remember to update Xcode project settings:${NC}"
echo -e "  - MARKETING_VERSION: $NEW_VERSION"
echo -e "  - CURRENT_PROJECT_VERSION: (increment if needed)"

# Git operations (optional - uncomment if you want auto-commit)
# git add VERSION CHANGELOG.md
# git commit -m "chore: $MESSAGE - bump version to $NEW_VERSION"
# echo -e "${GREEN}✓ Committed version changes${NC}"

echo -e "${GREEN}Version bump complete!${NC}"

