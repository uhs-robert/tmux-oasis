#!/usr/bin/env bash
# Prints the sandbox's drawn status bar as runs of cells
set -euo pipefail
. "$(dirname "$0")/lib.sh"

sandbox_server=oasis-dev
viewer_server=oasis-dev-view

on_server "$sandbox_server" has-session -t "$session_name" 2>/dev/null ||
  die "no sandbox running; start one with \`just sandbox\`"

scratch=$(mktemp -d)
trap 'stop_server "$viewer_server"; rm -rf "$scratch"' EXIT

start_viewer "$viewer_server" "$sandbox_server"
wait_for_bar "$viewer_server" "$sandbox_server"
capture_bar "$viewer_server" "$sandbox_server" > "$scratch/bar.ansi"
python3 -B "$dev_dir/cells.py" dump "$scratch/bar.ansi"
