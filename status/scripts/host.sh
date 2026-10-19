#!/usr/bin/env bash
# Usage: host.sh state HOST [STATES]
# Prints ok, warn or crit for HOST. STATES is space-separated glob=state pairs
# (default: read from tmux's @oasis_host_states); the first matching glob wins.
set -u
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

host_state() {
  local states host pair pattern state
  # Hostnames differ in case between machines (macOS: Roberts-MacBook-Pro); bash 3.2 has no ${var,,}
  host=$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')
  states=$(printf '%s' "$2" | tr '[:upper:]' '[:lower:]')
  # Pairs hold glob characters: keep the shell from expanding them against the filesystem
  set -f
  for pair in $states; do
    # A malformed pair is skipped so it cannot hide the pairs after it
    case $pair in *=warn|*=crit) ;; *) continue ;; esac
    pattern=${pair%=*}
    state=${pair##*=}
    # Unquoted, so the pattern is a glob rather than a literal
    case $host in
      $pattern) printf '%s' "$state"; return ;;
    esac
  done
  printf 'ok'
}

case ${1:-} in
  state) host_state "${2:-}" "${3-$(oasis_option @oasis_host_states)}" ;;
esac
