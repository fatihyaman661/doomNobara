#!/usr/bin/env bash
# Build a self-contained Doom Emacs bundle for an air-gapped machine.
#
# Includes the doomemacs source, the doom+ module source, and every
# pre-cloned straight package repo -- so `doom sync` on the target needs no
# network. Excludes everything platform-specific (byte-code, native code,
# caches, and the Linux PATH dump in .local/env).
#
# Usage: scripts/make-offline-bundle.sh [OUTPUT_DIR]
#        OUTPUT_DIR defaults to the current directory.

set -euo pipefail

EMACSDIR="${EMACSDIR:-$HOME/.config/emacs}"
OUTDIR="${1:-$PWD}"
OUT="$OUTDIR/doom-offline-bundle.tar.zst"

die() { printf 'error: %s\n' "$1" >&2; exit 1; }

[ -d "$EMACSDIR" ] || die "no Doom install at $EMACSDIR (override with EMACSDIR=)"
[ -d "$EMACSDIR/.local/straight/repos" ] || die "no straight repos in $EMACSDIR -- run 'doom sync' first"
[ -d "$OUTDIR" ] || die "output directory does not exist: $OUTDIR"
command -v zstd >/dev/null || die "zstd not found (dnf install zstd)"

# Record exactly what is being shipped, so the target can be verified.
manifest="$EMACSDIR/BUNDLE-MANIFEST.txt"
cleanup() { rm -f "$manifest"; }
trap cleanup EXIT

{
  echo "Doom offline bundle"
  echo "built:      $(date -Is)"
  echo "from host:  $(uname -srm)"
  echo "emacs:      $(command emacs --version 2>/dev/null | head -1)"
  echo
  echo "doomemacs:  $(git -C "$EMACSDIR" describe --tags --always 2>/dev/null || echo unknown)"
  echo "            $(git -C "$EMACSDIR" rev-parse HEAD 2>/dev/null || true)"
  if [ -d "$EMACSDIR/sources/doom+" ]; then
    echo "doom+:      $(git -C "$EMACSDIR/sources/doom+" describe --tags --always 2>/dev/null || echo unknown)"
    echo "            $(git -C "$EMACSDIR/sources/doom+" rev-parse HEAD 2>/dev/null || true)"
  fi
  echo
  echo "straight repos: $(find "$EMACSDIR/.local/straight/repos" -maxdepth 1 -mindepth 1 -type d | wc -l)"
} > "$manifest"

# Shrink the git histories; 296 repos carry a lot of loose objects.
if [ "${SKIP_GC:-0}" != "1" ]; then
  echo ">> packing git repos (set SKIP_GC=1 to skip)..."
  find "$EMACSDIR/.local/straight/repos" -maxdepth 1 -mindepth 1 -type d -print0 |
    while IFS= read -r -d '' repo; do
      [ -d "$repo/.git" ] || continue
      git -C "$repo" gc --quiet --auto 2>/dev/null || true
    done
fi

echo ">> archiving (this takes a few minutes)..."
# Paths are stored relative to ~/.config, so the target extracts with
#   tar -xf doom-offline-bundle.tar.zst -C "%HOME%\.config"
# and lands at .config/emacs -- matching the paths in OFFLINE-WINDOWS.md.
tar \
  --exclude='.local/cache' \
  --exclude='.local/state' \
  --exclude='.local/etc/workspaces' \
  --exclude='.local/env' \
  --exclude='.local/straight/build-*' \
  --exclude='.local/straight/*-cache.el' \
  --exclude='eln-cache' \
  --exclude='*.elc' \
  --exclude='*.eln' \
  -C "$(dirname "$EMACSDIR")" \
  -cf - "$(basename "$EMACSDIR")" |
  zstd -T0 -3 -o "$OUT" -f

printf '\n>> done: %s (%s)\n' "$OUT" "$(du -h "$OUT" | cut -f1)"
echo ">> next: follow OFFLINE-WINDOWS.md parts 2 and 3"
