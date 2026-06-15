#!/usr/bin/env bash
set -euo pipefail

REPO="${REPO:-pnstack/safe-clean}"
VERSION="${VERSION:-latest}"
BIN_NAME="${BIN_NAME:-safe-clean}"
INSTALL_DIR="${INSTALL_DIR:-$HOME/.local/bin}"

detect_asset() {
  local os
  local arch

  os="$(uname -s)"
  arch="$(uname -m)"

  case "$os" in
    Linux)
      case "$arch" in
        x86_64 | amd64)
          echo "safe-clean-linux-x86_64.tar.gz"
          ;;
        *)
          echo "Unsupported Linux arch: $arch" >&2
          exit 1
          ;;
      esac
      ;;
    Darwin)
      case "$arch" in
        x86_64 | amd64)
          echo "safe-clean-macos-x86_64.tar.gz"
          ;;
        arm64 | aarch64)
          echo "safe-clean-macos-aarch64.tar.gz"
          ;;
        *)
          echo "Unsupported macOS arch: $arch" >&2
          exit 1
          ;;
      esac
      ;;
    *)
      echo "Unsupported OS: $os" >&2
      exit 1
      ;;
  esac
}

ASSET="$(detect_asset)"

if [ "$VERSION" = "latest" ]; then
  URL="https://github.com/${REPO}/releases/latest/download/${ASSET}"
else
  URL="https://github.com/${REPO}/releases/download/${VERSION}/${ASSET}"
fi

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

mkdir -p "$INSTALL_DIR"

echo "Installing ${BIN_NAME} from ${URL}"
curl -fsSL "$URL" -o "$TMP_DIR/$ASSET"

tar -xzf "$TMP_DIR/$ASSET" -C "$TMP_DIR"

if [ ! -f "$TMP_DIR/$BIN_NAME" ]; then
  echo "Binary not found in archive: $BIN_NAME" >&2
  exit 1
fi

install -m 755 "$TMP_DIR/$BIN_NAME" "$INSTALL_DIR/$BIN_NAME"

echo "Installed: $INSTALL_DIR/$BIN_NAME"

if ! command -v "$BIN_NAME" >/dev/null 2>&1; then
  echo ""
  echo "Add this to your shell profile:"
  echo "export PATH=\"\$HOME/.local/bin:\$PATH\""
fi

"$INSTALL_DIR/$BIN_NAME" --help >/dev/null || true