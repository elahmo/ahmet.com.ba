#!/usr/bin/env bash
#
# Preview novalic.xyz locally at http://localhost:1313
#
#   Usage:  ./preview.sh      (press Ctrl+C to stop)
#
# Safe by design: the live-reload server bakes `localhost` URLs into public/,
# so when you stop it this script automatically rebuilds public/ with the real
# production URLs. A preview build can therefore never be committed/pushed by
# accident. Always deploy via ./build.sh afterwards anyway.
#
set -euo pipefail
cd "$(dirname "$0")"

HUGO_BIN="$HOME/bin/hugo-0.128"
if [ ! -x "$HUGO_BIN" ]; then
  echo "Hugo not found — run ./build.sh once first (it downloads the pinned Hugo)."
  exit 1
fi

restore() {
  echo ""
  echo "→ Rebuilding public/ with production URLs (https://novalic.xyz)..."
  "$HUGO_BIN" --cleanDestinationDir --gc >/dev/null 2>&1 || true
  echo "✅ public/ restored to a clean production build — safe to commit & push."
}
trap restore EXIT

echo "→ Preview at http://localhost:1313/   (Ctrl+C to stop)"
echo "    English: /     Bosanski: /bs/     Deutsch: /de/"
"$HUGO_BIN" server --bind 127.0.0.1 --port 1313 --baseURL http://localhost
