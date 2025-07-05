#!/bin/bash
# Quick install script for tf-build
# Usage: bash -c "$(curl -fsSL https://raw.githubusercontent.com/NebulaTechSolutions/TwinForge/main/quick-install.sh)"

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m'

print_banner() {
    echo -e "${BLUE}"
    echo "╔═══════════════════════════════════════════╗"
    echo "║        TwinForge Build Tool Setup         ║"
    echo "╚═══════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_status() { echo -e "${BLUE}[*]${NC} $1"; }
print_success() { echo -e "${GREEN}[✓]${NC} $1"; }
print_error() { echo -e "${RED}[✗]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[!]${NC} $1"; }

# Default values
VERSION="latest"
INSTALL_DIR="$HOME/.local/share/tf-build"
BIN_DIR="$HOME/.local/bin"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --version)
            VERSION="$2"
            shift 2
            ;;
        --install-dir)
            INSTALL_DIR="$2"
            shift 2
            ;;
        --bin-dir)
            BIN_DIR="$2"
            shift 2
            ;;
        *)
            print_error "Unknown option: $1"
            exit 1
            ;;
    esac
done

print_banner

# Check prerequisites
for cmd in curl tar; do
    if ! command -v $cmd &> /dev/null; then
        print_error "$cmd is required but not installed"
        exit 1
    fi
done

# Determine latest version if not specified
if [ "$VERSION" = "latest" ]; then
    print_status "Fetching latest version..."
    VERSION=$(curl -s https://api.github.com/repos/NebulaTechSolutions/TwinForge/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    if [ -z "$VERSION" ]; then
        print_error "Failed to determine latest version"
        exit 1
    fi
fi

print_status "Installing tf-build $VERSION"

# Create directories
mkdir -p "$INSTALL_DIR" "$BIN_DIR"

# Download release
DOWNLOAD_URL="https://github.com/NebulaTechSolutions/TwinForge/releases/download/$VERSION/tf-build-$VERSION-linux-x64.tar.gz"
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

print_status "Downloading from: $DOWNLOAD_URL"
cd "$TEMP_DIR"
if ! curl -fsSL "$DOWNLOAD_URL" -o tf-build.tar.gz; then
    print_error "Failed to download tf-build"
    exit 1
fi

# Extract
print_status "Extracting..."
tar -xzf tf-build.tar.gz
cd tf-build-*

# Run the full install script
print_status "Running installer..."
if [ -f "install.sh" ]; then
    chmod +x install.sh
    ./install.sh --custom "$INSTALL_DIR" "$BIN_DIR"
else
    print_error "Install script not found in release package"
    exit 1
fi

print_success "tf-build installed successfully!"
echo
print_status "Next steps:"
echo "1. Add $BIN_DIR to your PATH if not already done"
echo "2. Run 'tf-build --version' to verify installation"
echo "3. Run 'tf-build --help' for usage information"
echo
echo "For more information, visit: https://github.com/NebulaTechSolutions/TwinForge"