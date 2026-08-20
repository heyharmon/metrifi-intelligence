#!/usr/bin/env bash
# Cross-compile both CLIs from the private cli-library checkout and attach the
# tarballs to a GitHub release on this (public) repo. Source stays private;
# binaries ship. Run from anywhere: release.sh v0.1.0
set -euo pipefail

VERSION="${1:?usage: release.sh vX.Y.Z}"
SRC="${CLI_LIBRARY:-$HOME/dev/cli-library}"
REPO="heyharmon/metrifi-intelligence"
OUT="$(mktemp -d)"

declare -A MODULES=(
  [ncua-pp-cli]="$SRC/library/sales-and-crm/ncua"
  [google-ads-transparency-pp-cli]="$SRC/library/marketing/google-ads-transparency"
)

for cli in "${!MODULES[@]}"; do
  for os in darwin linux; do
    for arch in arm64 amd64; do
      echo "building ${cli} ${os}/${arch}..."
      (cd "${MODULES[$cli]}" && \
        CGO_ENABLED=0 GOOS=$os GOARCH=$arch \
        go build -trimpath -ldflags "-s -w -X main.version=${VERSION}" \
        -o "$OUT/$cli" "./cmd/$cli")
      tar -czf "$OUT/${cli}_${os}_${arch}.tar.gz" -C "$OUT" "$cli"
      rm "$OUT/$cli"
    done
  done
done

gh release create "$VERSION" --repo "$REPO" \
  --title "$VERSION" --notes "CLI binaries built from cli-library @ $(git -C "$SRC" rev-parse --short HEAD)" \
  "$OUT"/*.tar.gz
echo "released $VERSION"
