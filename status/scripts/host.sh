#!/usr/bin/env bash
# Usage: host.sh state HOST [STATES]
# Prints ok, warn or crit for HOST. STATES is space-separated glob=state pairs
# (default: read from tmux's @oasis_host_states); the first matching glob wins.
set -u
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

host_state() {
  local host=$1 states=$2 pair pattern state
  # Pairs hold glob characters: keep the shell from expanding them against the filesystem
  set -f
  for pair in $states; do
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
