#!/usr/bin/env bash
# sync-upstream.sh — pulls upstream realworld-angular into realworld-angular/
# (the only copy of the app, gitignored, re-cloned on every run).
#
# Idempotent. Safe to re-run.

set -euo pipefail

REPO_URL="https://github.com/realworld-angular/realworld-angular"
CLONE_DIR="realworld-angular"

echo "[sync-upstream] wiping previous clone..."
rm -rf "$CLONE_DIR"

echo "[sync-upstream] cloning upstream (depth=1)..."
git clone --depth=1 "$REPO_URL" "$CLONE_DIR"

NEW_SHA=$(git -C "$CLONE_DIR" rev-parse HEAD)
echo
echo "[sync-upstream] done."
echo "  Upstream HEAD: $NEW_SHA"
echo
echo "Next steps:"
echo "  1. Update SYNC-NOTES.md 'Current pinned upstream SHA' to: $NEW_SHA"
echo "  2. Add a row to SYNC-NOTES.md 'Sync log' table."
echo "  3. Optional verification:"
echo "       cd $CLONE_DIR && pnpm install --trust-lockfile && pnpm run build"
