# Cases for the agent icon on window tabs, fed by keeptabs' @keeptabs_state and @keeptabs_frame
. "$checkout_dir/dev/lib.sh"
settle_seconds=0.5
agents_server=oasis-test-agents
agents_viewer=oasis-test-agents-view
scratch=$(mktemp -d)
trap 'stop_server "$agents_viewer"; stop_server "$agents_server"; rm -rf "$scratch"' EXIT

# A keeptabs-status stand-in on the server's PATH that records each call
mkdir "$scratch/bin"
export PATH=$scratch/bin:$PATH
# Usage: fake_keeptabs_status TEXT -- the stand-in's script holds TEXT, which decides if it looks like it accepts --once
fake_keeptabs_status() {
  printf '#!/bin/sh\n# %s\necho "$@" >> %s/calls\n' "$1" "$scratch" > "$scratch/bin/keeptabs-status"
  chmod +x "$scratch/bin/keeptabs-status"
}
fake_keeptabs_status 'streams forever, no one-shot mode'

# Usage: start_agents_server [option=value ...] -- windows 0 running (active), 1 done, 2 waiting, 3 idle, 4 none
start_agents_server() {
  stop_server "$agents_viewer"
  stop_server "$agents_server"
  while on_server "$agents_server" has-session 2>/dev/null; do sleep 0.05; done
  start_oasis_server "$agents_server" "$checkout_dir" "$scratch" "$idle_pane_command" "$@"
  on_server "$agents_server" new-window -d -n idle "$idle_pane_command"
  on_server "$agents_server" new-window -d -n none "$idle_pane_command"
  on_server "$agents_server" set -w -t "$session_name:0" @keeptabs_state running
  on_server "$agents_server" set -w -t "$session_name:1" @keeptabs_state done
  on_server "$agents_server" set -w -t "$session_name:2" @keeptabs_state waiting
  on_server "$agents_server" set -w -t "$session_name:3" @keeptabs_state idle
  on_server "$agents_server" set -g @keeptabs_frame 0
  start_viewer "$agents_viewer" "$agents_server"
  wait_for_bar "$agents_viewer" "$agents_server"
}

# The drawn bar as one run of same-styled cells per line, without the column numbers
drawn_runs() {
  on_server "$agents_server" refresh-client -t "$(attached_client "$agents_server")" -S
  sleep "$settle_seconds"
  capture_bar "$agents_viewer" "$agents_server" > "$scratch/bar.ansi"
  python3 -B "$dev_dir/cells.py" dump "$scratch/bar.ansi" | sed -E 's/^ *[0-9]+-[0-9]+ +//; s/  +/ /g'
}

# Usage: run_after TEXT -- the run drawn right after the run ending in TEXT
run_after() {
  drawn_runs | grep -A1 -F -e "$1\"" | tail -n 1
}

robot='"<U+F06A9>"'
robot_alt='"<U+F06E3>"'
active_pill='#f0e68c'
inactive_pill='#1e2a38'
round_right_cap='fg=#1e2a38 bg=#141c24 "<U+E0B4>"'

start_agents_server
assert_equals "off by default: no icon on any tab" 0 "$(drawn_runs | grep -c -F -e '<U+F06A9>' -e '<U+F06E3>' || true)"
case $(on_server "$agents_server" show -gv window-status-current-format) in *keeptabs*) runs_keeptabs=yes ;; *) runs_keeptabs=no ;; esac
assert_equals "off by default: keeptabs-status is not called" no "$runs_keeptabs"

start_agents_server window_agents=on
assert_equals "done: green after the name" "fg=#7fcf78 bg=$inactive_pill $robot" "$(run_after ' 1 editor ')"
assert_equals "waiting: yellow" "fg=#f0e68c bg=$inactive_pill $robot" "$(run_after ' 2 logs ')"
assert_equals "idle: the border tone" "fg=#4e6578 bg=$inactive_pill $robot" "$(run_after ' 3 idle ')"
assert_equals "no agent: the cap follows the name" "$round_right_cap" "$(run_after ' 4 none')"
assert_equals "running, active tab, frame 0" "fg=#7fa3c9 bg=$active_pill bold \"<U+F06A9> \"" "$(run_after ' 0 ')"
on_server "$agents_server" set -g @keeptabs_frame 1
assert_equals "running, frame 1: the alternate icon" "fg=#7fa3c9 bg=$active_pill bold \"<U+F06E3> \"" "$(run_after ' 0 ')"
assert_equals "done ignores the frame" "fg=#7fcf78 bg=$inactive_pill $robot" "$(run_after ' 1 editor ')"

on_server "$agents_server" set -w -t "$session_name:1" @keeptabs_state running
assert_equals "running, inactive tab, frame 1" "fg=#7fa3c9 bg=$inactive_pill $robot_alt" "$(run_after ' 1 editor ')"
on_server "$agents_server" set -wu -t "$session_name:1" @keeptabs_state
assert_equals "state unset again: the icon goes" "$round_right_cap" "$(run_after ' 1 editor')"

on_server "$agents_server" set -g @oasis_agent_waiting_color '#{@thm_red}'
assert_equals "colour override" "fg=#ff7979 bg=$inactive_pill $robot" "$(run_after ' 2 logs ')"

sleep 1.5
assert_equals "a keeptabs-status without --once is never run" no "$([ -e "$scratch/calls" ] && echo yes || echo no)"
fake_keeptabs_status 'usage: keeptabs-status [--once]'
sleep 2.5
assert_equals "a keeptabs-status with --once is run with it" --once "$(sort -u "$scratch/calls" 2>/dev/null)"

start_agents_server window_agents=on window_separator=flat
assert_equals "flat: the inactive icon is padded" "fg=#7fcf78 bg=$inactive_pill \"<U+F06A9> \"" "$(run_after ' 1 editor ')"
assert_equals "flat: no agent, plain padding" "fg=#5d8bbb bg=$inactive_pill \" 4 none \"" "$(drawn_runs | grep -F -e ' 4 none')"
