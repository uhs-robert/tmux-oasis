#!/usr/bin/env bash
# Usage: screenshot.sh [out.png] [option=value ...]
# Renders the bar on its own server, so the sandbox and its options are left alone.
set -euo pipefail
. "$(dirname "$0")/lib.sh"

shot_server=oasis-shot-$$
viewer_server=oasis-shot-view-$$
bar_width=${OASIS_DEV_WIDTH:-120}

out_path=${TMPDIR:-/tmp}/oasis-screenshot.png
case ${1:-} in
  *.png) out_path=$1; shift ;;
esac
check_option_args "$@"

scratch=$(mktemp -d)
trap 'stop_server "$viewer_server"; stop_server "$shot_server"; rm -rf "$scratch"' EXIT

start_oasis_server "$shot_server" "$checkout_dir" "$checkout_dir" "$idle_pane_command" "$@"
start_viewer "$viewer_server" "$shot_server"
wait_for_bar "$viewer_server" "$shot_server"
capture_bar "$viewer_server" "$shot_server" > "$scratch/bar.ansi"
python3 -B "$dev_dir/ansi_to_png.py" "$scratch/bar.ansi" "$out_path"
echo "$out_path"
