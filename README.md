# 🚀 TrueFidelity: High-Fidelity Digital Twin Platform

**TrueFidelity is a cloud-native platform designed to replicate full embedded systems virtually, enabling scalable, deterministic testing and validation for automotive OEMs.**

Physical test benches are expensive, limited, and hard to automate. TrueFidelity addresses these challenges by providing:

* **High-Fidelity Replication:** Run actual ECU binaries on virtual hardware
* **Cloud-Native Scalability:** Launch and manage virtual test benches on demand
* **Deterministic Execution:** Achieve timing accuracy with dedicated cloud resources
* **Infrastructure as Code (IaC):** Define and version your systems using YAML
* **Integrated Tooling:** Web UI, CLI, and monitoring in one platform

## 🚀 Quick Start

### Install TrueFidelity Desktop

Grab the platform installer from the latest release and run it locally. Each script automatically detects whether it should use the public (`NebulaTechSolutions/TrueFidelity`) or private (`NebulaTechSolutions/TrueFidelity-private`) repository and supports installing multiple versions side-by-side.

**Linux**
```bash
curl -fsSLO https://github.com/NebulaTechSolutions/TrueFidelity/releases/latest/download/install-linux.sh
chmod +x install-linux.sh
./install-linux.sh --yes
```

**macOS**
```bash
curl -fsSLO https://github.com/NebulaTechSolutions/TrueFidelity/releases/latest/download/install-macos.sh
chmod +x install-macos.sh
./install-macos.sh --scope user --yes
```

**Windows (PowerShell)**
```powershell
Invoke-WebRequest -Uri "https://github.com/NebulaTechSolutions/TrueFidelity/releases/latest/download/install-windows.ps1" -OutFile install-windows.ps1
Set-ExecutionPolicy Bypass -Scope Process -Force
./install-windows.ps1 -Yes
```

> **Tip:** Use `--install-dir`/`--bin-name` (Linux), `--app-name`/`--bin-name` (macOS), or `-InstallDirectory`/`-LauncherName` (Windows) to install different channels alongside each other (e.g., `truefidelity-beta`).

### Hardware Info Helper (tf-hwinfo)

Users only need the hardware info helper when requesting node-locked licenses. A convenience script downloads the correct binary, caches it locally, and forwards any arguments to `tf-hwinfo`.

```bash
curl -fsSLO https://raw.githubusercontent.com/NebulaTechSolutions/TrueFidelity/main/scripts/run-tf-hwinfo.sh
chmod +x run-tf-hwinfo.sh
./run-tf-hwinfo.sh collect --output hardware-info.json
```

The script accepts `--version <tag>` to pin a specific release and stores binaries under `~/.cache/truefidelity/tf-hwinfo` by default. On Windows, download the appropriate `tf-hwinfo-windows-*.exe` asset from the latest release and run it from PowerShell.

### Installing TF-Build (Optional)

`tf-build` is the firmware build tool for TrueFidelity. It is distributed separately from the desktop installers.

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/NebulaTechSolutions/TrueFidelity/main/quick-install.sh)"
```

Once installed, verify the tool:
```bash
tf-build --version
tf-build --help
```

## 📦 Releases

All releases are available in the [Releases](https://github.com/NebulaTechSolutions/TrueFidelity/releases) section.

## 📚 Documentation

For more information about TrueFidelity, visit our [documentation](https://nebulatechsolutions.github.io/TrueFidelity/) site

## 🔧 Support

For support and questions:
- Open an issue in this repository
- Contact us at support@nebula-automotive.com

## 📄 License

TrueFidelity is proprietary software. Contact us for licensing information.

---

© 2025 Nebula Tech Solutions. All rights reserved.
