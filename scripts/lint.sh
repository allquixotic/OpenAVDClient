#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

js_files=(
  src/main.js
  src/app-metadata.js
  src/input-guard.js
  tests/app-metadata.test.js
  tests/input-guard.test.js
)

for file in "${js_files[@]}"; do
  node --check "$file"
done

shell_files=(
  setup.sh
  scripts/build-snap.sh
  scripts/lint.sh
  scripts/macos-release.sh
)

for file in "${shell_files[@]}"; do
  bash -n "$file"
done

if command -v shellcheck >/dev/null 2>&1; then
  shellcheck "${shell_files[@]}"
fi
