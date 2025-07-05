# TF-Build Installation Guide

## System Requirements

- Linux x86_64 (Ubuntu 20.04+, Fedora 35+, or similar)
- 8GB RAM minimum (16GB recommended)
- 20GB free disk space
- Docker installed and running
- Internet connection for downloading dependencies

## Quick Installation

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/NebulaTechSolutions/TwinForge/main/quick-install.sh)"
```

## What Gets Installed

During installation, tf-build automatically downloads and installs:

1. **TF-Build Binary** - The main build tool
2. **Zephyr SDK 0.16.8** - ARM toolchains for cross-compilation
3. **Zephyr RTOS v4.1.0** - Real-time operating system source
4. **HAL Modules** - Hardware abstraction layers (hal_nxp, CMSIS)
5. **ECUSim QEMU** - Custom QEMU binary for ECU simulation

All dependencies are installed to `~/.config/tf-build/resources/` by default.

## Installation Options

### Install Specific Version
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/NebulaTechSolutions/TwinForge/main/quick-install.sh)" -- --version v0.1.0
```

### Custom Installation Directory
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/NebulaTechSolutions/TwinForge/main/quick-install.sh)" -- \
  --install-dir /opt/tf-build \
  --bin-dir /usr/local/bin
```

### Manual Installation

1. Download the release tarball:
```bash
curl -L https://github.com/NebulaTechSolutions/TwinForge/releases/download/v0.1.0/tf-build-v0.1.0-linux-x64.tar.gz -o tf-build.tar.gz
```

2. Extract:
```bash
tar -xzf tf-build.tar.gz
cd tf-build-v0.1.0
```

3. Run installer:
```bash
./install.sh
```

## Post-Installation

1. Verify the installation:
```bash
tf-build --version
```

2. List supported boards:
```bash
tf-build list boards
```

3. Initialize Docker environment:
```bash
tf-build init
```

## Troubleshooting

### Permission Denied
If you get permission errors, ensure Docker is running and your user is in the docker group:
```bash
sudo usermod -aG docker $USER
newgrp docker
```

### Command Not Found
Add the installation directory to your PATH:
```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

### Docker Issues
Ensure Docker is installed and running:
```bash
docker --version
sudo systemctl status docker
```

## Uninstallation

To remove tf-build:
```bash
rm -rf ~/.config/tf-build
rm ~/.local/bin/tf-build
```