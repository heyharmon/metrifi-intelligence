#!/usr/bin/env bash
# Push the local mirror + screenshot cache to the viewer host after a sync
# session. Idempotent; run as often as you like. Set VIEWER_HOST in your env
# or pass it as $1 (e.g. push.sh intelligence@my-vps).
set -euo pipefail
HOST="${1:-${VIEWER_HOST:?set VIEWER_HOST or pass user@host}}"

# One consistent snapshot of the SQLite mirror, WAL folded in.
SNAP="$(mktemp -d)/data.db"
sqlite3 "$HOME/.local/share/google-ads-transparency-pp-cli/data.db" ".backup '$SNAP'"

rsync -az "$SNAP" "$HOST:/var/lib/metrifi-intelligence/data.db"
rsync -az --delete "$HOME/.cache/google-ads-transparency-pp-cli/" \
  "$HOST:/home/intelligence/.cache/google-ads-transparency-pp-cli/"
echo "pushed mirror + screenshots to $HOST"
