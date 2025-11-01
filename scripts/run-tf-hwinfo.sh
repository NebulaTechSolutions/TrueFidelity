#!/usr/bin/env bash
# Helper script to download and execute the tf-hwinfo binary for the current platform.
# Usage:
#   ./run-tf-hwinfo.sh [tf-hwinfo arguments]
#   TF_HWINFO_VERSION=v0.2.0 ./run-tf-hwinfo.sh collect --output hardware.json

set -euo pipefail

VERSION="${TF_HWINFO_VERSION:-latest}"
CACHE_DIR="${TF_HWINFO_CACHE_DIR:-${XDG_CACHE_HOME:-$HOME/.cache}/truefidelity/tf-hwinfo}"
FORCE_DOWNLOAD=false

print_usage() {
  cat <<'EOF'
Usage: run-tf-hwinfo.sh [options] [--] [tf-hwinfo args]

Options:
  --version <tag>    Install/use a specific release tag (default: latest)
  --cache-dir <dir>  Override download cache directory
  --force-download   Re-download binary even if cached
  --help             Show this help

All remaining arguments are passed directly to tf-hwinfo.
EOF
}

ARGS=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --version)
      VERSION="$2"
      shift 2
      ;;
    --cache-dir)
      CACHE_DIR="$2"
      shift 2
      ;;
    --force-download)
      FORCE_DOWNLOAD=true
      shift
      ;;
    --help)
      print_usage
      exit 0
      ;;
    --)
      shift
      ARGS+=("$@")
      break
      ;;
    *)
      ARGS+=("$1")
      shift
      ;;
  esac
done

if [[ ${#ARGS[@]} -eq 0 ]]; then
  ARGS+=("collect")
fi

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Error: required command '$1' not found" >&2
    exit 1
  fi
}

require_cmd curl
require_cmd tar

uname_s=$(uname -s)
uname_m=$(uname -m)

case "$uname_s" in
  Linux)
    platform="linux"
    ;;
  Darwin)
    platform="macos"
    ;;
  *)
    echo "Error: unsupported operating system '$uname_s'. Use the native tf-hwinfo binary for your platform." >&2
    exit 1
    ;;
esac

case "$uname_m" in
  x86_64|amd64)
    arch="x64"
    ;;
  arm64|aarch64)
    arch="arm64"
    ;;
  *)
    echo "Error: unsupported architecture '$uname_m'." >&2
    exit 1
    ;;
esac

if [[ "$VERSION" = "latest" ]]; then
  api_url="https://api.github.com/repos/NebulaTechSolutions/TrueFidelity/releases/latest"
  VERSION=$(curl -fsSL "$api_url" | grep '"tag_name"' | head -1 | cut -d '"' -f4)
  if [[ -z "$VERSION" ]]; then
    echo "Error: failed to resolve latest tf-hwinfo release" >&2
    exit 1
  fi
fi

if [[ "$VERSION" != v* ]]; then
  VERSION="v${VERSION}"
fi

asset_suffix="${VERSION#v}"
asset_name="tf-hwinfo-${asset_suffix}-${platform}-${arch}.tar.gz"
cache_target="$CACHE_DIR/${VERSION}/${platform}-${arch}"
binary_path="$cache_target/tf-hwinfo"

if [[ "$FORCE_DOWNLOAD" = true ]]; then
  rm -rf "$cache_target"
fi

if [[ ! -x "$binary_path" ]]; then
  echo "Downloading tf-hwinfo ($VERSION, $platform/$arch)..."
  tmp_dir=$(mktemp -d)
  trap 'rm -rf "$tmp_dir"' EXIT
  curl -fL "https://github.com/NebulaTechSolutions/TrueFidelity/releases/download/${VERSION}/${asset_name}" -o "$tmp_dir/$asset_name"
  mkdir -p "$cache_target"
  tar -xzf "$tmp_dir/$asset_name" -C "$cache_target"
  chmod +x "$binary_path"
  rm -rf "$tmp_dir"
  trap - EXIT
fi

exec "$binary_path" "${ARGS[@]}"

