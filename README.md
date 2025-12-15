# 🚀 TrueFidelity: High-Fidelity Digital Twin Platform

**TrueFidelity is a cloud-native platform designed to replicate full embedded systems virtually, enabling scalable, deterministic testing and validation for automotive OEMs.**

Physical test benches are expensive, limited, and hard to automate. TrueFidelity addresses these challenges by providing:

* **High-Fidelity Replication:** Run actual ECU binaries on virtual hardware
* **Cloud-Native Scalability:** Launch and manage virtual test benches on demand
* **Deterministic Execution:** Achieve timing accuracy with dedicated cloud resources
* **Infrastructure as Code (IaC):** Define and version your systems using YAML
* **Integrated Tooling:** Web UI, CLI, and monitoring in one platform

## 🚀 Quick Start

To get up and running:
1. Install the TrueFidelity Desktop app for your platform.
2. Activate your license (see [Getting a License](#-getting-a-license)).

### Before You Begin

- 64-bit Linux, macOS, or Windows 10/11
- Administrator/root privileges (required by the installers)
- Active internet connection to download installers and updates
- License file or license server credentials

### Installing TrueFidelity Desktop

The TrueFidelity Desktop application provides a GUI for managing virtual ECUs, CAN network simulation, and data playback/injection.

#### Prerequisites before launch
- Docker installed on the client
  
**Prerequisites Windows**
- Docker Desktop app
- WSL2 with custom kernel provided by Nebula
```powershell
wsl --install
```

#### Linux Installation

**Latest Release**
```bash
curl -fsSL https://github.com/NebulaTechSolutions/TrueFidelity/releases/latest/download/install-linux.sh | bash -s -- --yes
```

**Specific Version**
```bash
curl -fsSL https://github.com/NebulaTechSolutions/TrueFidelity/releases/download/v0.1.4/install-linux.sh | bash -s -- --version v0.1.4 --yes
```

**Custom Installation Directory**
```bash
curl -fsSL https://github.com/NebulaTechSolutions/TrueFidelity/releases/latest/download/install-linux.sh -o /tmp/install-linux.sh
chmod +x /tmp/install-linux.sh
/tmp/install-linux.sh \
  --install-dir "$HOME/.local/share/truefidelity" \
  --bin-name truefidelity \
  --yes
```

#### Windows Installation

PowerShell can be run normally (per-user install) or as Administrator (all-users install + system PATH). We recommend running as Administrator when possible; without elevation the installer falls back to your user profile and only updates the user PATH (open a new PowerShell session afterward).

**All users (recommended, run PowerShell as Administrator)**

**Latest Release**
```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
Invoke-WebRequest -Uri "https://github.com/NebulaTechSolutions/TrueFidelity/releases/latest/download/install-windows.ps1" -OutFile "$env:TEMP\install-windows.ps1"
& "$env:TEMP\install-windows.ps1" -Yes
```

**Specific Version**
```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
Invoke-WebRequest -Uri "https://github.com/NebulaTechSolutions/TrueFidelity/releases/download/v0.1.4/install-windows.ps1" -OutFile "$env:TEMP\install-windows.ps1"
& "$env:TEMP\install-windows.ps1" -Version v0.1.4 -Yes
```

**Per-user install (no admin rights)**
```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
Invoke-WebRequest -Uri "https://github.com/NebulaTechSolutions/TrueFidelity/releases/latest/download/install-windows.ps1" -OutFile "$env:TEMP\install-windows.ps1"
& "$env:TEMP\install-windows.ps1" -Yes
```
Installs to `%LOCALAPPDATA%\TrueFidelity` and adds that to your user PATH; restart PowerShell to pick up the change.

#### macOS Installation (coming soon)

#### Verify & Launch

Run the CLI to confirm the install and open the desktop app:

```bash
truefidelity --version
truefidelity
```

You can also start TrueFidelity from your system's application menu or Start menu.

## 📦 Releases

All releases are available in the [Releases](https://github.com/NebulaTechSolutions/TrueFidelity/releases) section.

Each release includes:
- **Desktop application** for your platform (Linux, macOS, Windows)
- **Platform-specific installers** (`install-linux.sh`, `install-macos.sh`, `install-windows.ps1`)
- **Version manifest** with Docker image tags and configuration

## 📚 Documentation (coming soon)

For more information about TrueFidelity, there will soon be a site here with documentation and examples

## 🔐 Getting a License

TrueFidelity Desktop requires a valid license to run. Choose the track that matches your entitlement.

**Node-Locked License (single machine)**

1. Install and launch the TrueFidelity Desktop app.
2. When the License dialog appears, click **Collect Hardware Info**. The fingerprint is displayed immediately.
3. Click **Save to File** to export `hardware-info.json`.
4. Send the file to your TrueFidelity representative or support@nebula-automotive.com along with the desired edition (for example, Professional or Enterprise).
5. We will return a signed license file. Load it from the same License dialog (you can reopen it later from the menu).

**Floating/Server License**

1. Launch the TrueFidelity Desktop app and open the License dialog.
2. Enter the license server URL (and API key if required) provided by your administrator or TrueFidelity representative.
3. Click **Validate License** to complete activation.

Need to switch license types later? Reopen the License dialog from the menu to update the configuration.

## 🔧 Support

For support and questions:
- Open an issue in this repository
- Contact us at support@nebula-automotive.com

## 📄 License

TrueFidelity is proprietary software. Contact us for licensing information.

---

© 2025 Nebula Automotive Ltd. All rights reserved.
