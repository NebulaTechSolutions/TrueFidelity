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
    if command -v figlet >/dev/null 2>&1; then
        echo -e "${BLUE}"
        figlet -f slant "TF-BUILD"
        echo -e "${NC}"
    else
        echo -e "${BLUE}"
        echo "╔═══════════════════════════════════════════╗"
        echo "║        TwinForge Build Tool Setup         ║"
        echo "╚═══════════════════════════════════════════╝"
        echo -e "${NC}"
    fi
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

# Check and install prerequisites
print_status "Checking prerequisites..."

# Detect distribution
DISTRO=""
DISTRO_NAME=""
if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO=$ID
    DISTRO_NAME="${NAME:-$ID}"
elif [ -f /etc/debian_version ]; then
    DISTRO="debian"
    DISTRO_NAME="Debian"
elif [ -f /etc/fedora-release ]; then
    DISTRO="fedora"
    DISTRO_NAME="Fedora"
elif [ -f /etc/redhat-release ]; then
    DISTRO="rhel"
    DISTRO_NAME="Red Hat"
elif [ -f /etc/arch-release ]; then
    DISTRO="arch"
    DISTRO_NAME="Arch Linux"
elif [ -f /etc/alpine-release ]; then
    DISTRO="alpine"
    DISTRO_NAME="Alpine Linux"
elif [ -f /etc/gentoo-release ]; then
    DISTRO="gentoo"
    DISTRO_NAME="Gentoo"
elif [ -f /etc/SuSE-release ] || [ -f /etc/SUSE-brand ]; then
    DISTRO="opensuse"
    DISTRO_NAME="openSUSE"
elif [ "$(uname)" = "Darwin" ]; then
    DISTRO="macos"
    DISTRO_NAME="macOS"
else
    DISTRO="unknown"
    DISTRO_NAME="Unknown"
fi

print_status "Detected OS: $DISTRO_NAME"

# Essential tools that must be present
MISSING_ESSENTIAL=""
for cmd in curl tar; do
    if ! command -v $cmd &> /dev/null; then
        MISSING_ESSENTIAL="$MISSING_ESSENTIAL $cmd"
    fi
done

if [ -n "$MISSING_ESSENTIAL" ]; then
    print_error "Essential tools missing:$MISSING_ESSENTIAL"
    print_error "Please install these tools first"
    exit 1
fi

# Check for all required tools
MISSING_TOOLS=""
MISSING_PACKAGES=()

# Check each tool and build list of missing packages
if ! command -v docker &> /dev/null; then
    MISSING_TOOLS="$MISSING_TOOLS docker"
    MISSING_PACKAGES+=("docker")
fi

if ! command -v python3 &> /dev/null; then
    MISSING_TOOLS="$MISSING_TOOLS python3"
    MISSING_PACKAGES+=("python3")
fi

if ! command -v pip3 &> /dev/null && ! command -v pip &> /dev/null; then
    MISSING_TOOLS="$MISSING_TOOLS pip3"
    MISSING_PACKAGES+=("pip3")
fi

if ! command -v git &> /dev/null; then
    MISSING_TOOLS="$MISSING_TOOLS git"
    MISSING_PACKAGES+=("git")
fi

if ! command -v wget &> /dev/null && ! command -v curl &> /dev/null; then
    MISSING_TOOLS="$MISSING_TOOLS wget/curl"
    MISSING_PACKAGES+=("wget" "curl")
fi

if ! command -v cmake &> /dev/null; then
    MISSING_TOOLS="$MISSING_TOOLS cmake"
    MISSING_PACKAGES+=("cmake")
fi

if ! command -v ninja &> /dev/null; then
    MISSING_TOOLS="$MISSING_TOOLS ninja"
    MISSING_PACKAGES+=("ninja")
fi

# Build single install command based on distribution
INSTALL_COMMAND=""
if [ ${#MISSING_PACKAGES[@]} -gt 0 ]; then
    case "$DISTRO" in
        ubuntu|debian|linuxmint|pop)
            INSTALL_COMMAND="sudo apt update && sudo apt install -y"
            for pkg in "${MISSING_PACKAGES[@]}"; do
                case "$pkg" in
                    docker) INSTALL_COMMAND="$INSTALL_COMMAND docker.io" ;;
                    python3) INSTALL_COMMAND="$INSTALL_COMMAND python3" ;;
                    pip3) INSTALL_COMMAND="$INSTALL_COMMAND python3-pip" ;;
                    ninja) INSTALL_COMMAND="$INSTALL_COMMAND ninja-build" ;;
                    *) INSTALL_COMMAND="$INSTALL_COMMAND $pkg" ;;
                esac
            done
            ;;
        fedora)
            INSTALL_COMMAND="sudo dnf install -y"
            for pkg in "${MISSING_PACKAGES[@]}"; do
                case "$pkg" in
                    pip3) INSTALL_COMMAND="$INSTALL_COMMAND python3-pip" ;;
                    ninja) INSTALL_COMMAND="$INSTALL_COMMAND ninja-build" ;;
                    *) INSTALL_COMMAND="$INSTALL_COMMAND $pkg" ;;
                esac
            done
            ;;
        rhel|centos|rocky|almalinux)
            INSTALL_COMMAND="sudo yum install -y"
            for pkg in "${MISSING_PACKAGES[@]}"; do
                case "$pkg" in
                    pip3) INSTALL_COMMAND="$INSTALL_COMMAND python3-pip" ;;
                    ninja) INSTALL_COMMAND="$INSTALL_COMMAND ninja-build" ;;
                    *) INSTALL_COMMAND="$INSTALL_COMMAND $pkg" ;;
                esac
            done
            ;;
        arch|manjaro|endeavouros)
            INSTALL_COMMAND="sudo pacman -S --noconfirm"
            for pkg in "${MISSING_PACKAGES[@]}"; do
                case "$pkg" in
                    python3) INSTALL_COMMAND="$INSTALL_COMMAND python" ;;
                    pip3) INSTALL_COMMAND="$INSTALL_COMMAND python-pip" ;;
                    *) INSTALL_COMMAND="$INSTALL_COMMAND $pkg" ;;
                esac
            done
            ;;
        opensuse|suse)
            INSTALL_COMMAND="sudo zypper install -y"
            for pkg in "${MISSING_PACKAGES[@]}"; do
                case "$pkg" in
                    pip3) INSTALL_COMMAND="$INSTALL_COMMAND python3-pip" ;;
                    *) INSTALL_COMMAND="$INSTALL_COMMAND $pkg" ;;
                esac
            done
            ;;
        alpine)
            INSTALL_COMMAND="sudo apk add"
            for pkg in "${MISSING_PACKAGES[@]}"; do
                case "$pkg" in
                    pip3) INSTALL_COMMAND="$INSTALL_COMMAND py3-pip" ;;
                    ninja) INSTALL_COMMAND="$INSTALL_COMMAND samurai" ;;
                    *) INSTALL_COMMAND="$INSTALL_COMMAND $pkg" ;;
                esac
            done
            ;;
        gentoo)
            INSTALL_COMMAND="sudo emerge -av"
            for pkg in "${MISSING_PACKAGES[@]}"; do
                case "$pkg" in
                    docker) INSTALL_COMMAND="$INSTALL_COMMAND app-containers/docker" ;;
                    python3) INSTALL_COMMAND="$INSTALL_COMMAND dev-lang/python" ;;
                    pip3) INSTALL_COMMAND="$INSTALL_COMMAND dev-python/pip" ;;
                    git) INSTALL_COMMAND="$INSTALL_COMMAND dev-vcs/git" ;;
                    wget) INSTALL_COMMAND="$INSTALL_COMMAND net-misc/wget" ;;
                    curl) INSTALL_COMMAND="$INSTALL_COMMAND net-misc/curl" ;;
                    cmake) INSTALL_COMMAND="$INSTALL_COMMAND dev-util/cmake" ;;
                    ninja) INSTALL_COMMAND="$INSTALL_COMMAND dev-util/ninja" ;;
                esac
            done
            ;;
        macos)
            # Special handling for macOS
            if [[ " ${MISSING_PACKAGES[@]} " =~ " docker " ]]; then
                INSTALL_COMMAND="brew install --cask docker"
            fi
            # Remove docker from the list for brew install
            MISSING_PACKAGES=("${MISSING_PACKAGES[@]/docker}")
            if [ ${#MISSING_PACKAGES[@]} -gt 0 ]; then
                if [ -n "$INSTALL_COMMAND" ]; then
                    INSTALL_COMMAND="$INSTALL_COMMAND && brew install"
                else
                    INSTALL_COMMAND="brew install"
                fi
                for pkg in "${MISSING_PACKAGES[@]}"; do
                    if [ -n "$pkg" ]; then
                        INSTALL_COMMAND="$INSTALL_COMMAND $pkg"
                    fi
                done
            fi
            ;;
        *)
            INSTALL_COMMAND="# Please install the following packages using your package manager: ${MISSING_PACKAGES[*]}"
            ;;
    esac
fi

# Check for nice-to-have tools
OPTIONAL_MISSING=""
if ! command -v rsync &> /dev/null; then
    OPTIONAL_MISSING="$OPTIONAL_MISSING rsync"
fi
if ! command -v figlet &> /dev/null; then
    OPTIONAL_MISSING="$OPTIONAL_MISSING figlet"
fi
if ! command -v gum &> /dev/null; then
    OPTIONAL_MISSING="$OPTIONAL_MISSING gum"
fi

# Report missing tools
if [ -n "$MISSING_TOOLS" ] || [ -n "$OPTIONAL_MISSING" ]; then
    echo
    if [ -n "$MISSING_TOOLS" ]; then
        print_warning "Missing required tools:$MISSING_TOOLS"
        echo
        if [ -n "$INSTALL_COMMAND" ]; then
            echo "To install all missing packages, run:"
            echo
            echo "  $INSTALL_COMMAND"
            echo
        fi
        
        if command -v gum &> /dev/null; then
            if ! gum confirm "Continue without installing these tools?"; then
                print_status "Installation cancelled. Please install the missing tools and try again."
                exit 1
            fi
        else
            read -p "Continue without installing these tools? [y/N] " -n 1 -r
            echo ""
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                print_status "Installation cancelled. Please install the missing tools and try again."
                exit 1
            fi
        fi
    fi
    
    if [ -n "$OPTIONAL_MISSING" ]; then
        print_status "Optional tools not found:$OPTIONAL_MISSING"
        print_status "For a better experience, consider installing:"
        if [[ "$OPTIONAL_MISSING" == *"rsync"* ]]; then
            echo "  - rsync: Faster file copying (usually pre-installed)"
        fi
        if [[ "$OPTIONAL_MISSING" == *"figlet"* ]]; then
            echo "  - figlet: ASCII art headers (apt/brew install figlet)"
        fi
        if [[ "$OPTIONAL_MISSING" == *"gum"* ]]; then
            echo "  - gum: Beautiful CLI prompts (https://github.com/charmbracelet/gum)"
        fi
        echo
    fi
fi

# Special Docker checks
if command -v docker &> /dev/null; then
    if ! docker info &> /dev/null 2>&1; then
        print_warning "Docker is installed but not running or accessible."
        echo
        echo "Possible solutions:"
        echo "  1. Start Docker daemon: sudo systemctl start docker"
        echo "  2. Add user to docker group: sudo usermod -aG docker $USER"
        echo "  3. Log out and back in for group changes to take effect"
        echo
        
        if command -v gum &> /dev/null; then
            if ! gum confirm "Continue anyway?"; then
                exit 1
            fi
        else
            read -p "Continue anyway? [y/N] " -n 1 -r
            echo ""
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                exit 1
            fi
        fi
    else
        print_success "Docker is installed and running"
    fi
else
    print_warning "Docker not found - tf-build requires Docker to build firmware"
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
trap 'rm -rf "$TEMP_DIR"' EXIT INT TERM

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
if command -v figlet >/dev/null 2>&1; then
    figlet -f small "Installation"
    echo
else
    echo
    echo "=== Installation ==="
    echo
fi

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

TF_BUILD_VERSION=$(./tf-build --version)
print_success "tf-build binary verified: $TF_BUILD_VERSION"

# Copy binary to bin directory
cp tf-build "$BIN_DIR/tf-build"
chmod +x "$BIN_DIR/tf-build"
print_success "Binary installed to: $BIN_DIR/tf-build"

# Copy resources to config directory (not install directory)
if [ -d "resources" ]; then
    print_status "Installing resources..."
    cp -r resources "$CONFIG_DIR/"
    print_success "Resources installed to: $CONFIG_DIR/resources"
fi

# Install configuration
if [ -f "resources/config/tf-build.yml" ]; then
    print_status "Installing configuration..."
    cp resources/config/tf-build.yml "$CONFIG_DIR/tf-build.yml"
    print_success "Configuration installed to: $CONFIG_DIR/tf-build.yml"
fi

# OS Support Installation
cd - >/dev/null  # Return to temp directory

# Get Zephyr version from config
ZEPHYR_VERSION=""
if [ -f "$CONFIG_DIR/tf-build.yml" ]; then
    ZEPHYR_VERSION=$(grep -A1 "sdks:" "$CONFIG_DIR/tf-build.yml" | grep "zephyr_rtos_version:" | awk '{print $2}')
fi
ZEPHYR_VERSION="${ZEPHYR_VERSION:-v4.1.0}"

# Ask if user wants Zephyr support
INSTALL_ZEPHYR=false
echo
if command -v figlet >/dev/null 2>&1; then
    figlet -f small "OS Support"
    echo
fi

if command -v gum >/dev/null 2>&1; then
    gum style --foreground 212 --bold "Would you like to install Zephyr RTOS support?"
    echo ""
    gum style --foreground 99 "This will download and set up the Zephyr workspace"
    gum style --foreground 99 "Download size: ~2GB (includes all HAL modules)"
    gum style --foreground 99 "Installation time: 10-20 minutes"
    echo ""
    if gum confirm "Install Zephyr RTOS support?"; then
        INSTALL_ZEPHYR=true
    fi
else
    echo "Would you like to install Zephyr RTOS support?"
    echo ""
    echo "This will download and set up the Zephyr workspace"
    echo "Download size: ~2GB (includes all HAL modules)"
    echo "Installation time: 10-20 minutes"
    echo ""
    read -p "Install Zephyr RTOS support? [Y/n] " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        INSTALL_ZEPHYR=true
    fi
fi

# Set up Zephyr workspace if requested
if [ "$INSTALL_ZEPHYR" = true ]; then
    ZEPHYR_WORKSPACE="$CONFIG_DIR/resources/os/zephyr"
    if [ ! -d "$ZEPHYR_WORKSPACE/.west" ]; then
        print_status "Setting up Zephyr workspace (this may take a while)..."
        mkdir -p "$ZEPHYR_WORKSPACE"
        
        # Check if west is installed
        if ! command -v west >/dev/null 2>&1; then
            print_status "Installing west..."
            pip3 install --user west || {
                print_error "Failed to install west"
                exit 1
            }
        fi
        
        # Initialize Zephyr workspace
        cd "$ZEPHYR_WORKSPACE"
        print_status "Initializing Zephyr workspace for version $ZEPHYR_VERSION..."
        export GIT_CONFIG_PARAMETERS="'advice.detachedHead=false'"
        if west init -m https://github.com/zephyrproject-rtos/zephyr.git --mr "$ZEPHYR_VERSION" 2>&1 | grep -v "warning: refs/tags"; then
            print_success "Zephyr workspace initialized"
        else
            print_error "Failed to initialize Zephyr workspace"
            exit 1
        fi
        unset GIT_CONFIG_PARAMETERS
        
        # Update workspace to fetch all modules
        print_status "Fetching Zephyr modules (this will take several minutes)..."
        if west update 2>&1; then
            print_success "Zephyr modules fetched successfully"
        else
            print_error "Failed to fetch Zephyr modules"
            exit 1
        fi
        
        cd - >/dev/null
        print_success "Zephyr workspace setup complete"
    else
        print_success "Zephyr workspace already present"
    fi
else
    print_status "Skipping Zephyr RTOS installation"
fi

# Ask if user wants FreeRTOS support
INSTALL_FREERTOS=false
echo
if command -v gum >/dev/null 2>&1; then
    gum style --foreground 212 --bold "Would you like to install FreeRTOS support?"
    echo ""
    gum style --foreground 99 "This will download and set up FreeRTOS"
    gum style --foreground 99 "Download size: ~50MB"
    gum style --foreground 99 "Installation time: 1-2 minutes"
    echo ""
    if gum confirm "Install FreeRTOS support?"; then
        INSTALL_FREERTOS=true
    fi
else
    echo "Would you like to install FreeRTOS support?"
    echo ""
    echo "This will download and set up FreeRTOS"
    echo "Download size: ~50MB"
    echo "Installation time: 1-2 minutes"
    echo ""
    read -p "Install FreeRTOS support? [Y/n] " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        INSTALL_FREERTOS=true
    fi
fi

# Set up FreeRTOS if requested
if [ "$INSTALL_FREERTOS" = true ]; then
    FREERTOS_DIR="$CONFIG_DIR/resources/os/freertos"
    if [ ! -d "$FREERTOS_DIR" ]; then
        print_status "Setting up FreeRTOS..."
        mkdir -p "$FREERTOS_DIR"
        
        # Download FreeRTOS
        FREERTOS_VERSION="10.5.1"
        FREERTOS_URL="https://github.com/FreeRTOS/FreeRTOS-Kernel/archive/refs/tags/V${FREERTOS_VERSION}.tar.gz"
        FREERTOS_TARBALL="$FREERTOS_DIR/freertos-${FREERTOS_VERSION}.tar.gz"
        
        print_status "Downloading FreeRTOS v${FREERTOS_VERSION}..."
        if curl -L -o "$FREERTOS_TARBALL" "$FREERTOS_URL"; then
            print_status "Extracting FreeRTOS..."
            tar -xzf "$FREERTOS_TARBALL" -C "$FREERTOS_DIR" --strip-components=1 || {
                print_error "Failed to extract FreeRTOS"
                rm -f "$FREERTOS_TARBALL"
                exit 1
            }
            rm -f "$FREERTOS_TARBALL"
            print_success "FreeRTOS v${FREERTOS_VERSION} installed successfully"
        else
            print_error "Failed to download FreeRTOS"
            exit 1
        fi
    else
        print_success "FreeRTOS already present"
    fi
else
    print_status "Skipping FreeRTOS installation"
fi

# Download Zephyr SDK if Zephyr support was installed
if [ "$INSTALL_ZEPHYR" = true ]; then
    SDK_VERSION=""
    if [ -f "$CONFIG_DIR/tf-build.yml" ]; then
        SDK_VERSION=$(grep -A1 "sdks:" "$CONFIG_DIR/tf-build.yml" | grep "zephyr_sdk_version:" | awk '{print $2}')
    fi
    SDK_VERSION="${SDK_VERSION:-0.16.8}"
    
    if [ ! -d "$CONFIG_DIR/resources/sdks/zephyr/zephyr-sdk-$SDK_VERSION" ]; then
        print_status "Downloading Zephyr SDK v$SDK_VERSION (this may take a while)..."
        mkdir -p "$CONFIG_DIR/resources/sdks/zephyr"
        
        # Determine architecture
        ARCH=$(uname -m)
        case $ARCH in
            x86_64)
                SDK_ARCH="x86_64"
                ;;
            aarch64)
                SDK_ARCH="aarch64"
                ;;
            *)
                print_error "Unsupported architecture: $ARCH"
                exit 1
                ;;
        esac
        
        SDK_URL="https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v${SDK_VERSION}/zephyr-sdk-${SDK_VERSION}_linux-${SDK_ARCH}_minimal.tar.xz"
        SDK_TARBALL="$CONFIG_DIR/resources/sdks/zephyr/zephyr-sdk-${SDK_VERSION}.tar.xz"
        
        print_status "Downloading from: $SDK_URL"
        if curl -L -o "$SDK_TARBALL" "$SDK_URL"; then
            print_status "Extracting Zephyr SDK..."
            tar -xf "$SDK_TARBALL" -C "$CONFIG_DIR/resources/sdks/zephyr/" || {
                print_error "Failed to extract Zephyr SDK"
                rm -f "$SDK_TARBALL"
                exit 1
            }
            rm -f "$SDK_TARBALL"
            
            # Run SDK setup script
            if [ -f "$CONFIG_DIR/resources/sdks/zephyr/zephyr-sdk-$SDK_VERSION/setup.sh" ]; then
                print_status "Setting up Zephyr SDK..."
                cd "$CONFIG_DIR/resources/sdks/zephyr/zephyr-sdk-$SDK_VERSION"
                ./setup.sh -h -c || {
                    print_warning "SDK setup script failed, but continuing..."
                }
                cd - >/dev/null
            fi
            
            print_success "Zephyr SDK v$SDK_VERSION installed successfully"
        else
            print_error "Failed to download Zephyr SDK"
            exit 1
        fi
    else
        print_success "Zephyr SDK v$SDK_VERSION already present"
    fi
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
if command -v figlet >/dev/null 2>&1; then
    figlet -f small "Complete!"
    echo
fi

print_status "Installation Summary:"
echo "  Binary: $BIN_DIR/tf-build"
echo "  Config: $CONFIG_DIR/tf-build.yml"
echo "  Resources: $CONFIG_DIR/resources"
if [ -f "$CONFIG_DIR/resources/ecusim/qemu-system-arm" ]; then
    echo "  ECUSim: Installed"
fi
if [ "$INSTALL_ZEPHYR" = true ]; then
    echo "  Zephyr RTOS: Installed (v$ZEPHYR_VERSION)"
fi
if [ "$INSTALL_FREERTOS" = true ]; then
    echo "  FreeRTOS: Installed (v10.5.1)"
fi
echo
print_status "Next steps:"
echo "1. Run 'tf-build --version' to verify installation"
echo "2. Run 'tf-build init' to set up the Docker build environment"
echo "3. Run 'tf-build --help' for usage information"
echo
echo "For more information, visit: https://github.com/NebulaTechSolutions/TwinForge"