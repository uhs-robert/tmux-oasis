# Shared helpers for the dev/ scripts. Sourced, not run.
#
# Every tmux call goes through on_server with a fixed -L name and TMUX unset:
# agent shells run inside the owner's tmux, and a bare `tmux` would reach it.
#
# The drawn bar is read by attaching a client to the themed server from inside a
# pane of a second "viewer" server, then `capture-pane -e` on that pane. Unlike
# `display -p`, this runs #() jobs, and unlike `script` it yields clean SGR lines.

dev_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
checkout_dir=$(dirname "$dev_dir")

default_flavor=moonlight_dark
session_name=oasis
bar_width=${OASIS_DEV_WIDTH:-160}
settle_seconds=${OASIS_DEV_SETTLE:-1.5}
# Holds a pane open in its directory without a shell's startup files and prompt
idle_pane_command=cat

die() {
  printf '%s\n' "$*" >&2
  exit 1
}

on_server() {
  local server=$1
  shift
  env -u TMUX tmux -L "$server" "$@"
}

stop_server() {
  on_server "$1" kill-server 2>/dev/null || true
}

# "separator" and "@oasis_separator" both name @oasis_separator
option_name() {
  case $1 in
    @*) printf '%s' "$1" ;;
    *) printf '@oasis_%s' "$1" ;;
  esac
}

check_option_args() {
  local assignment
  for assignment in "$@"; do
    case $assignment in
      ?*=*) ;;
      *) die "expected option=value, got '$assignment'" ;;
    esac
  done
}

# Options must be set before oasis_tmux.conf is sourced: its own defaults use
# `set -o`, which keeps whatever is already there.
set_options() {
  local server=$1 assignment
  shift
  on_server "$server" set -g @oasis_flavor "$default_flavor"
  for assignment in "$@"; do
    on_server "$server" set -g "$(option_name "${assignment%%=*}")" "${assignment#*=}"
  done
}

# Usage: start_oasis_server SERVER CHECKOUT WORKING_DIR PANE_COMMAND [option=value ...]
# An empty PANE_COMMAND runs the default shell. Windows: "Window" (active, a
# name windows.conf special-cases), "editor" and "logs".
start_oasis_server() {
  local server=$1 checkout=$2 working_dir=$3 pane_command=$4
  shift 4
  stop_server "$server"
  on_server "$server" -f /dev/null new-session -d -s "$session_name" -n Window \
    -x "$bar_width" -y 10 -c "$working_dir" ${pane_command:+"$pane_command"}
  on_server "$server" set -g status-interval 1
  on_server "$server" set -as terminal-features ',*:RGB'
  set_options "$server" "$@"
  on_server "$server" source-file "$checkout/oasis_tmux.conf"
  on_server "$server" new-window -d -n editor -c "$working_dir" ${pane_command:+"$pane_command"}
  on_server "$server" new-window -d -n logs -c "$working_dir" ${pane_command:+"$pane_command"}
}

viewer_terminal() {
  if infocmp tmux-256color >/dev/null 2>&1; then
    printf 'tmux-256color'
  else
    printf 'screen-256color'
  fi
}

# Usage: start_viewer VIEWER SERVER
start_viewer() {
  local viewer=$1 server=$2
  stop_server "$viewer"
  on_server "$viewer" -f /dev/null start-server \; \
    set -g status off \; \
    set -g default-terminal "$(viewer_terminal)" \; \
    new-session -d -s view -x "$bar_width" -y 6 \
    "env -u TMUX tmux -L $server attach -t $session_name"
}

attached_client() {
  on_server "$1" list-clients -F '#{client_name}' | head -n 1
}

# Usage: capture_bar VIEWER SERVER -- prints the status line as drawn, with SGR codes
capture_bar() {
  local viewer=$1 server=$2
  local viewer_screen
  viewer_screen=$(on_server "$viewer" capture-pane -e -p -N -t view)
  if [ "$(on_server "$server" show -gv status-position)" = top ]; then
    printf '%s\n' "$viewer_screen" | head -n 1
  else
    printf '%s\n' "$viewer_screen" | tail -n 1
  fi
}

# Waits until the attached client has drawn something, then lets #() jobs land
wait_for_bar() {
  local viewer=$1 server=$2 attempts=0
  until [ -n "$(attached_client "$server")" ] && capture_bar "$viewer" "$server" | grep -q '[^[:space:]]'; do
    attempts=$((attempts + 1))
    [ "$attempts" -gt 50 ] && die "no status bar drawn on tmux server '$server' after 5s"
    sleep 0.1
  done
  sleep "$settle_seconds"
}
