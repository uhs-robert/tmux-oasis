#!/usr/bin/env bash
# Usage: sandbox.sh start [option=value ...] | sandbox.sh stop
set -euo pipefail
. "$(dirname "$0")/lib.sh"

sandbox_server=oasis-dev

case ${1:-} in
  start)
    shift
    check_option_args "$@"
    start_oasis_server "$sandbox_server" "$checkout_dir" "$checkout_dir" "" "$@"
    echo "Sandbox running on tmux server '$sandbox_server'. Attach from a new terminal with:"
    echo "env -u TMUX tmux -L $sandbox_server attach -t $session_name"
    ;;
  stop)
    stop_server "$sandbox_server"
    ;;
  *) die "usage: sandbox.sh start [option=value ...] | sandbox.sh stop" ;;
esac
