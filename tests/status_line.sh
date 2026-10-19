# Cases for the built status line: at most two groups per side, extras merged into the inner one

trap 'env -u TMUX tmux -L oasis-test-status kill-server 2>/dev/null || true' EXIT

# Usage: bar SIDE LIST [option=value ...] -- the expanded bar for SIDE built from LIST over modules a, b, c, d
bar() {
  local side=$1 list=$2; shift 2
  env -u TMUX tmux -L oasis-test-status kill-server 2>/dev/null || true
  # kill-server returns before the old server is gone; a new one started then can race it
  while env -u TMUX tmux -L oasis-test-status has-session 2>/dev/null; do sleep 0.05; done
  env -u TMUX tmux -L oasis-test-status -f /dev/null new -d -s t -x 200 -y 10
  env -u TMUX tmux -L oasis-test-status set -g @oasis_flavor moonlight_dark
  for name in a b c d; do
    env -u TMUX tmux -L oasis-test-status set -g "@oasis_module_$name" "$(printf %s "$name" | tr "[:lower:]" "[:upper:]")"
  done
  env -u TMUX tmux -L oasis-test-status set -g @oasis_status_left ""
  env -u TMUX tmux -L oasis-test-status set -g @oasis_status_right ""
  env -u TMUX tmux -L oasis-test-status set -g "@oasis_status_$side" "$list"
  for assignment in "$@"; do
    env -u TMUX tmux -L oasis-test-status set -g "${assignment%%=*}" "${assignment#*=}"
  done
  env -u TMUX tmux -L oasis-test-status source-file "$checkout_dir/oasis_tmux.conf"
  env -u TMUX tmux -L oasis-test-status display -p "#{T:status-$side}"
}

# Prints each drawn group's modules, groups in drawn order joined by "|": "A B|C".
# A group body starts after "#[bold] " and ends at the next style or the end.
groups_of() {
  printf '%s' "$1" | grep -o '#\[bold\] [^#]*' | sed -E 's/^#\[bold\] //; s/ +$//' | paste -sd '|'
}

assert_equals "right, one group" "A B" "$(groups_of "$(bar right 'a b')")"
assert_equals "right, two groups" "A|B" "$(groups_of "$(bar right 'a | b')")"
assert_equals "right, three groups: the inner groups merge, the edge group stays" "A B|C" "$(groups_of "$(bar right 'a | b | c')")"
assert_equals "right, four groups" "A B C|D" "$(groups_of "$(bar right 'a | b | c | d')")"

assert_equals "left, one group" "A B" "$(groups_of "$(bar left 'a b')")"
assert_equals "left, two groups" "A|B" "$(groups_of "$(bar left 'a | b')")"
assert_equals "left, three groups: the edge group stays, the rest merge" "A|B C" "$(groups_of "$(bar left 'a | b | c')")"
assert_equals "left, four groups" "A|B C D" "$(groups_of "$(bar left 'a | b | c | d')")"

assert_equals "a hidden module in the merged group leaves the others" "A|C" "$(groups_of "$(bar left 'a | b | c' @oasis_module_b_when=0)")"

# The warning is queued as a hook while no client is attached
warns() {
  env -u TMUX tmux -L oasis-test-status show-hooks -g | grep -c 'more than two groups' || true
}
bar right 'a | b | c' >/dev/null
assert_equals "three groups queue the warning" 1 "$(warns)"
bar right 'a | b' >/dev/null
assert_equals "two groups queue no warning" 0 "$(warns)"
bar left 'a | b | c | d' >/dev/null
assert_equals "four groups queue one warning, not one per extra" 1 "$(warns)"
env -u TMUX tmux -L oasis-test-status kill-server 2>/dev/null || true
