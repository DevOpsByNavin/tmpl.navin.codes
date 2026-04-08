#!/usr/bin/env bash
# scripts/install-yazi.sh

set -e

echo "=> Fetching latest Yazi release..."

# Grab the latest release tag from GitHub API
YAZI_VERSION=$(curl -s "https://api.github.com/repos/sxyazi/yazi/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')

if [ -z "$YAZI_VERSION" ]; then
    echo "Error: Failed to fetch Yazi version."
    exit 1
fi

echo "=> Found Yazi version v${YAZI_VERSION}"

TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"

# Target the standard Linux build
ARCHIVE_NAME="yazi-x86_64-unknown-linux-gnu.zip"
DOWNLOAD_URL="https://github.com/sxyazi/yazi/releases/latest/download/${ARCHIVE_NAME}"

echo "=> Downloading from $DOWNLOAD_URL..."
curl -sSLo "$ARCHIVE_NAME" "$DOWNLOAD_URL"

echo "=> Extracting archive..."
unzip -q "$ARCHIVE_NAME"

EXTRACTED_DIR="yazi-x86_64-unknown-linux-gnu"

# Ensure the local bin directory exists
mkdir -p ~/.local/bin

echo "=> Moving binaries to ~/.local/bin..."
mv "${EXTRACTED_DIR}/yazi" ~/.local/bin/
mv "${EXTRACTED_DIR}/ya" ~/.local/bin/

# Clean up
cd ~
rm -rf "$TMP_DIR"

echo "=> Yazi installed successfully! Ensure ~/.local/bin is in your \$PATH."
