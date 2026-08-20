#!/usr/bin/env bash
# Install the MetriFi Intelligence CLIs into ~/.local/bin.
set -euo pipefail

REPO="heyharmon/metrifi-intelligence"   # binaries attached to this repo's releases
BIN_DIR="$HOME/.local/bin"
CLIS=(ncua-pp-cli google-ads-transparency-pp-cli)

case "$(uname -s)" in
  Darwin) OS=darwin ;;
  Linux)  OS=linux ;;
  *) echo "unsupported OS: $(uname -s)" >&2; exit 1 ;;
esac
case "$(uname -m)" in
  arm64|aarch64) ARCH=arm64 ;;
  x86_64)        ARCH=amd64 ;;
  *) echo "unsupported arch: $(uname -m)" >&2; exit 1 ;;
esac

mkdir -p "$BIN_DIR"
for cli in "${CLIS[@]}"; do
  asset="${cli}_${OS}_${ARCH}.tar.gz"
  url="https://github.com/${REPO}/releases/latest/download/${asset}"
  echo "installing ${cli} (${OS}/${ARCH})..."
  curl -fsSL "$url" | tar -xz -C "$BIN_DIR" "$cli"
  chmod +x "$BIN_DIR/$cli"
done

case ":$PATH:" in
  *":$BIN_DIR:"*) ;;
  *) echo "NOTE: add $BIN_DIR to your PATH." ;;
esac

for cli in "${CLIS[@]}"; do
  "$BIN_DIR/$cli" version
done
echo "done. next: run each CLI's 'doctor' command, then seed the NCUA mirror."
