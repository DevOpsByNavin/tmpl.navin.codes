#!/bin/bash
set -e

# Define installation directory
INSTALL_DIR="$HOME/.local/bin"

# Create the directory if it doesn't exist
mkdir -p "$INSTALL_DIR"

echo "Starting lazygit installation to $INSTALL_DIR..."

# 1. Detect Operating System
OS="$(uname -s)"
case "${OS}" in
    Linux*)     MACHINE=Linux;;
    Darwin*)    MACHINE=Darwin;;
    *)          echo "Error: Unsupported OS: ${OS}"; exit 1;;
esac

# 2. Detect Architecture
ARCH="$(uname -m)"
case "${ARCH}" in
    x86_64|amd64)   ARCH=x86_64;;
    aarch64|arm64)  ARCH=arm64;;
    *)              echo "Error: Unsupported architecture: ${ARCH}"; exit 1;;
esac

# 3. Fetch the latest version tag
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')

if [ -z "$LAZYGIT_VERSION" ]; then
    echo "Error: Failed to fetch version. Check internet connection."
    exit 1
fi

# 4. Construct URL and Temporary Directory
TARBALL="lazygit_${LAZYGIT_VERSION}_${MACHINE}_${ARCH}.tar.gz"
DOWNLOAD_URL="https://github.com/jesseduffield/lazygit/releases/latest/download/${TARBALL}"
TMP_DIR=$(mktemp -d)

# 5. Download and Extract
echo "Downloading v${LAZYGIT_VERSION}..."
curl -L -s -o "${TMP_DIR}/${TARBALL}" "${DOWNLOAD_URL}"
tar xf "${TMP_DIR}/${TARBALL}" -C "${TMP_DIR}" lazygit

# 6. Move binary (No sudo needed)
mv "${TMP_DIR}/lazygit" "$INSTALL_DIR/lazygit"
chmod +x "$INSTALL_DIR/lazygit"

# 7. Cleanup
rm -rf "${TMP_DIR}"

echo "Installation complete! lazygit is located in $INSTALL_DIR"

# 8. Path Check
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo -e "\n--- IMPORTANT ---"
    echo "It looks like $HOME/.local/bin is not in your PATH."
    echo "Add this line to your ~/.bashrc or ~/.zshrc file:"
    echo 'export PATH="$HOME/.local/bin:$PATH"'
else
    echo -e "\nVerification:"
    lazygit --version
fi
