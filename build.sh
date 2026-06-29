#!/usr/bin/env bash
#
# Build novalic.xyz correctly for deployment to Dokku.
#
#   Usage:   ./build.sh
#   Then:    git add -A && git commit -m "your message" && git push dokku master
#
# Why this script exists (two things that have broken the live site before):
#   1. The system `hugo` is too new (0.16x) and CANNOT build this theme — it
#      removed `resources.ToCSS`, so the CSS fails to compile. We pin Hugo 0.128.
#   2. `hugo server` bakes `http://localhost:1313` into every link. NEVER deploy
#      a server build. This script always does a proper production build and
#      refuses to finish if localhost URLs leak into public/.
#
set -euo pipefail
cd "$(dirname "$0")"

HUGO_VERSION="0.128.0"
HUGO_BIN="$HOME/bin/hugo-${HUGO_VERSION%.*}"   # ~/bin/hugo-0.128

# 1. Make sure the correct Hugo is available (auto-download if missing).
if [ ! -x "$HUGO_BIN" ]; then
  echo "→ Hugo $HUGO_VERSION not found; downloading the pinned version..."
  mkdir -p "$HOME/bin"
  URL="https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_darwin-universal.tar.gz"
  curl -fsSL "$URL" -o "$HOME/bin/_hugo.tgz"
  tar -xzf "$HOME/bin/_hugo.tgz" -C "$HOME/bin" hugo
  mv -f "$HOME/bin/hugo" "$HUGO_BIN"
  rm -f "$HOME/bin/_hugo.tgz"
fi

# 2. Make sure the theme submodules are checked out.
git submodule update --init >/dev/null 2>&1 || true

# 3. Clean production build. baseURL comes from config.toml (https://novalic.xyz).
echo "→ Building with $("$HUGO_BIN" version | cut -d'+' -f1)"
"$HUGO_BIN" --cleanDestinationDir --gc

# 4. Safety net: never ship a preview/localhost build.
if grep -rq "localhost:1313" public/ 2>/dev/null; then
  echo "✗ ERROR: public/ contains localhost URLs (a 'hugo server' build leaked in). Aborting." >&2
  exit 1
fi

echo ""
echo "✅ Build OK — public/ is ready to deploy. Next:"
echo "     git add -A && git commit -m \"your message\" && git push dokku master"
