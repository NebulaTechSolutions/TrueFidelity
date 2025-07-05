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
CONFIG_DIR="$HOME/.config/tf-build"

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

# Check if Docker is installed and running
if ! command -v docker &> /dev/null; then
    print_warning "Docker is not installed. tf-build requires Docker to build ECU firmware."
    print_warning "Please install Docker and ensure it's running."
    echo ""
    read -p "Continue anyway? [y/N] " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
elif ! docker info &> /dev/null; then
    print_warning "Docker is installed but not running."
    print_warning "Please start Docker before using tf-build."
    echo ""
    read -p "Continue anyway? [y/N] " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

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
mkdir -p "$INSTALL_DIR" "$BIN_DIR" "$CONFIG_DIR"

# Create temp directory for downloads
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

# Download release
DOWNLOAD_URL="https://github.com/NebulaTechSolutions/TwinForge/releases/download/$VERSION/tf-build-$VERSION-linux-x64.tar.gz"
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

# Check if ECUSim binary is included in the package
if [ -f "resources/ecusim/qemu-system-arm" ]; then
    print_success "ECUSim binary included in package"
    chmod +x resources/ecusim/qemu-system-arm
else
    print_warning "ECUSim binary not found in package"
fi

# Install tf-build
print_status "Installing tf-build..."

# Check if binary exists
if [ ! -f "tf-build" ]; then
    print_error "tf-build binary not found in release package"
    exit 1
fi

# Verify binary works
if ! ./tf-build --version >/dev/null 2>&1; then
    print_error "tf-build binary is not executable or corrupted"
    exit 1
fi

# Copy binary to bin directory
cp tf-build "$BIN_DIR/tf-build"
chmod +x "$BIN_DIR/tf-build"
print_success "Binary installed to: $BIN_DIR/tf-build"

# Copy resources to install directory
if [ -d "resources" ]; then
    print_status "Installing resources..."
    cp -r resources "$INSTALL_DIR/"
    print_success "Resources installed to: $INSTALL_DIR/resources"
fi

# Install configuration
if [ -f "resources/config/tf-build.yml" ]; then
    print_status "Installing configuration..."
    cp resources/config/tf-build.yml "$CONFIG_DIR/tf-build.yml"
    print_success "Configuration installed to: $CONFIG_DIR/tf-build.yml"
fi

print_success "tf-build installed successfully!"
echo

# Setup PATH in shell profile if needed
if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
    print_status "Setting up PATH..."
    
    # Detect shell and update profile
    SHELL_PROFILE=""
    CURRENT_SHELL=$(basename "$SHELL" 2>/dev/null || echo "")
    
    if [ "$CURRENT_SHELL" = "zsh" ] && [ -f "$HOME/.zshrc" ]; then
        SHELL_PROFILE="$HOME/.zshrc"
    elif [ "$CURRENT_SHELL" = "bash" ] && [ -f "$HOME/.bashrc" ]; then
        SHELL_PROFILE="$HOME/.bashrc"
    elif [ -f "$HOME/.profile" ]; then
        SHELL_PROFILE="$HOME/.profile"
    elif [ -f "$HOME/.bash_profile" ]; then
        SHELL_PROFILE="$HOME/.bash_profile"
    fi
    
    if [ -n "$SHELL_PROFILE" ]; then
        echo "" >> "$SHELL_PROFILE"
        echo "# TwinForge tf-build environment" >> "$SHELL_PROFILE"
        echo "export PATH=\"$BIN_DIR:\$PATH\"" >> "$SHELL_PROFILE"
        echo "export TF_BUILD_CONFIG_DIR=\"$CONFIG_DIR\"" >> "$SHELL_PROFILE"
        print_success "Added tf-build to PATH in $SHELL_PROFILE"
        echo
        print_warning "Please run: source $SHELL_PROFILE"
        print_warning "Or restart your terminal for PATH changes to take effect"
    else
        print_warning "Could not detect shell profile. Please add $BIN_DIR to your PATH manually."
    fi
else
    print_success "tf-build is already in your PATH"
fi

echo
print_status "Installation Summary:"
echo "  Binary: $BIN_DIR/tf-build"
echo "  Config: $CONFIG_DIR/tf-build.yml"
echo "  Resources: $INSTALL_DIR"
if [ -f "$INSTALL_DIR/resources/ecusim/qemu-system-arm" ]; then
    echo "  ECUSim: Installed"
fi
echo
print_status "Next steps:"
echo "1. Run 'tf-build --version' to verify installation"
echo "2. Run 'tf-build init' to set up the build environment"
echo "3. Run 'tf-build --help' for usage information"
echo
echo "For more information, visit: https://github.com/NebulaTechSolutions/TwinForge"