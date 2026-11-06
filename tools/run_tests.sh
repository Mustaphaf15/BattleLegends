#!/usr/bin/env bash
set -euo pipefail

godot_bin=${GODOT_BIN:-godot}
test_log=$(mktemp)
trap 'rm -f "$test_log"' EXIT
for test_script in tools/test_*.gd; do
  echo "Running $test_script"
  timeout 60s "$godot_bin" --headless --path . --script "$test_script" 2>&1 | tee "$test_log"
  if grep -E 'SCRIPT ERROR|Parse Error|Failed to load script|ERROR:' "$test_log"; then
    echo "Godot errors in $test_script" >&2
    exit 1
  fi
  grep -F 'tests: PASS' "$test_log"
done
