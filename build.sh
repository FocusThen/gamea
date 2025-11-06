#!/bin/bash

# Build script for LÖVE game distribution
# Requires love-release to be installed (luarocks install love-release)

set -e  # Exit on error

# Configuration
GAME_NAME="game1"
VERSION="1.0.0"
AUTHOR="M. Mucahit Tezcan - FocusThen"
RELEASE_DIR="releases"
# macOS identifier (reverse domain format, e.g., com.yourname.gamename)
MACOS_UTI="com.focusthen.game1"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Building ${GAME_NAME} v${VERSION}${NC}"

# Clean previous builds
echo -e "${YELLOW}Cleaning previous builds...${NC}"
rm -rf "${RELEASE_DIR}"
mkdir -p "${RELEASE_DIR}"

# Create .love file directly in releases folder
echo -e "${YELLOW}Creating .love file...${NC}"
zip -r "${RELEASE_DIR}/${GAME_NAME}.love" . \
    -x "*.git/*" \
    -x "*.git*" \
    -x "*.tiled-session" \
    -x "maps/*.tiled-session" \
    -x "releases/*" \
    -x ".DS_Store" \
    -x "*.love" \
    -x "build.sh" \
    -x ".luarc.json"

echo -e "${GREEN}✓ Created ${RELEASE_DIR}/${GAME_NAME}.love${NC}"

# Check if love-release is available
# Try to find it in common locations
LOVE_RELEASE=""
if command -v love-release &> /dev/null; then
    LOVE_RELEASE="love-release"
elif [ -f ~/.luarocks/bin/love-release ]; then
    LOVE_RELEASE="$HOME/.luarocks/bin/love-release"
    export PATH="$HOME/.luarocks/bin:$PATH"
elif [ -f /usr/local/bin/love-release ]; then
    LOVE_RELEASE="/usr/local/bin/love-release"
fi

if [ -z "$LOVE_RELEASE" ]; then
    echo -e "${YELLOW}Warning: love-release not found!${NC}"
    echo -e "${YELLOW}Creating .love file only. Install love-release for platform-specific builds:${NC}"
    echo -e "${YELLOW}  luarocks install love-release${NC}"
    echo -e "${YELLOW}  Or: npm install -g love-release${NC}"
    echo -e "${GREEN}✓ .love file is ready at: ${RELEASE_DIR}/${GAME_NAME}.love${NC}"
    exit 0
fi

echo -e "${GREEN}Found love-release at: ${LOVE_RELEASE}${NC}"

# Create platform-specific builds
echo -e "${YELLOW}Creating platform-specific builds with love-release...${NC}"

# Detect current platform and build accordingly
PLATFORM=$(uname -s)

case "$PLATFORM" in
    Darwin)
        echo -e "${GREEN}Building for macOS and Windows...${NC}"
        echo -e "${YELLOW}Note: Linux builds require fakeroot/dpkg-deb (Linux-only tools)${NC}"
        echo -e "${YELLOW}This may take a while as it downloads LÖVE binaries...${NC}"
        "$LOVE_RELEASE" -a "${AUTHOR}" -v "${VERSION}" --uti "${MACOS_UTI}" -M -W "${RELEASE_DIR}" .
        ;;
    Linux)
        echo -e "${GREEN}Building for all platforms (macOS, Windows, Linux)...${NC}"
        echo -e "${YELLOW}This may take a while as it downloads LÖVE binaries for each platform...${NC}"
        "$LOVE_RELEASE" -a "${AUTHOR}" -v "${VERSION}" --uti "${MACOS_UTI}" -M -W -D "${RELEASE_DIR}" .
        ;;
    MINGW*|MSYS*|CYGWIN*)
        echo -e "${GREEN}Building for Windows...${NC}"
        echo -e "${YELLOW}This may take a while as it downloads LÖVE binaries...${NC}"
        "$LOVE_RELEASE" -a "${AUTHOR}" -v "${VERSION}" -W "${RELEASE_DIR}" .
        ;;
    *)
        echo -e "${YELLOW}Unknown platform: ${PLATFORM}${NC}"
        echo -e "${GREEN}Attempting to build for all platforms...${NC}"
        echo -e "${YELLOW}This may take a while as it downloads LÖVE binaries for each platform...${NC}"
        "$LOVE_RELEASE" -a "${AUTHOR}" -v "${VERSION}" --uti "${MACOS_UTI}" -M -W -D "${RELEASE_DIR}" .
        ;;
esac

echo -e "${GREEN}✓ Build complete!${NC}"
echo -e "${GREEN}Release files are in: ${RELEASE_DIR}/${NC}"
echo -e "${YELLOW}Files created:${NC}"
ls -lh "${RELEASE_DIR}/"

