#!/usr/bin/env bash
# Usage: compare.sh [ref] [option=value ...]
# Draws the bar of `ref` (default main) and of the working tree under the same
# options, in each scenario below, and compares them cell by cell.
set -euo pipefail
. "$(dirname "$0")/lib.sh"

scenario_settle_seconds=${OASIS_DEV_SCENARIO_SETTLE:-0.5}

ref=main
case ${1:-} in
  *=*) ;;
  ?*) ref=$1; shift ;;
esac
check_option_args "$@"
git -C "$checkout_dir" rev-parse --verify --quiet "$ref^{commit}" >/dev/null || die "unknown ref '$ref'"

scratch=$(mktemp -d)
# $$ repeats across PID namespaces that share one tmux socket directory
run_token=$(basename "$scratch")
ref_server=oasis-compare-ref-$run_token
work_server=oasis-compare-work-$run_token
ref_viewer=oasis-compare-ref-view-$run_token
work_viewer=oasis-compare-work-view-$run_token
ref_checkout=$scratch/ref
cleanup() {
  local server
  for server in "$ref_viewer" "$work_viewer" "$ref_server" "$work_server"; do stop_server "$server"; done
  git -C "$checkout_dir" worktree remove --force "$ref_checkout" 2>/dev/null || true
  rm -rf "$scratch"
}
trap cleanup EXIT
trap 'exit 1' INT TERM

git -C "$checkout_dir" worktree add --quiet --detach "$ref_checkout" "$ref"

# Both panes sit in one directory so the folder module matches
project_dir=$scratch/project
mkdir "$project_dir"

# Replacing % with $ turns strftime codes into plain text, so the clock module
# still draws its own format and icon on each side but stops ticking between
# captures. %% would not do: tmux runs strftime more than once on #{E:} content.
freeze_time() {
  local server=$1 name value
  for name in $(on_server "$server" show -g | awk '$1 ~ /^@oasis_module_/ {print $1}'); do
    value=$(on_server "$server" show -gv "$name")
    on_server "$server" set -g "$name" "${value//\%/\$}"
  done
}

start_oasis_server "$ref_server" "$ref_checkout" "$project_dir" "$idle_pane_command" "$@"
start_oasis_server "$work_server" "$checkout_dir" "$project_dir" "$idle_pane_command" "$@"
freeze_time "$ref_server"
freeze_time "$work_server"
start_viewer "$ref_viewer" "$ref_server"
start_viewer "$work_viewer" "$work_server"
wait_for_bar "$ref_viewer" "$ref_server"
wait_for_bar "$work_viewer" "$work_server"

apply_scenario() {
  local server=$1 active_window=$2 sync=$3 key_table=$4 client
  client=$(attached_client "$server")
  on_server "$server" select-window -t "$session_name:$active_window"
  on_server "$server" set -wg synchronize-panes "$sync"
  on_server "$server" switch-client -c "$client" -T "$key_table"
  on_server "$server" refresh-client -t "$client" -S
}

failed=0
for active_window in editor Window; do
  for sync in off on; do
    for key_table in root prefix; do
      label="active=$active_window sync=$sync keys=$key_table"
      apply_scenario "$ref_server" "$active_window" "$sync" "$key_table"
      apply_scenario "$work_server" "$active_window" "$sync" "$key_table"
      sleep "$scenario_settle_seconds"
      capture_bar "$ref_viewer" "$ref_server" > "$scratch/ref.ansi"
      capture_bar "$work_viewer" "$work_server" > "$scratch/work.ansi"
      if python3 -B "$dev_dir/cells.py" diff "$scratch/ref.ansi" "$scratch/work.ansi" "$label"; then
        echo "same: $label"
      else
        failed=1
      fi
    done
  done
done

if [ "$failed" -eq 1 ]; then
  echo "FAIL: the drawn bar differs from $ref" >&2
  exit 1
fi
echo "OK: the drawn bar matches $ref in every scenario"
