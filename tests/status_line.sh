# Cases for the built status line: separators between groups when a middle group is hidden

server=oasis-test-status
trap 'env -u TMUX tmux -L oasis-test-status kill-server 2>/dev/null || true' EXIT
powerline_left_cap=$'\xee\x82\xb2'

# Usage: right_bar [option=value ...] -- the unexpanded status-right built for "a | b | c", b hidden
right_bar() {
  env -u TMUX tmux -L oasis-test-status kill-server 2>/dev/null || true
  env -u TMUX tmux -L oasis-test-status -f /dev/null new -d -s t -x 200 -y 10
  env -u TMUX tmux -L oasis-test-status set -g @oasis_flavor moonlight_dark
  env -u TMUX tmux -L oasis-test-status set -g @oasis_module_a "A"
  env -u TMUX tmux -L oasis-test-status set -g @oasis_module_b "B"
  env -u TMUX tmux -L oasis-test-status set -g @oasis_module_b_when "0"
  env -u TMUX tmux -L oasis-test-status set -g @oasis_module_c "C"
  env -u TMUX tmux -L oasis-test-status set -g @oasis_status_left ""
  env -u TMUX tmux -L oasis-test-status set -g @oasis_status_right "a | b | c"
  for assignment in "$@"; do
    env -u TMUX tmux -L oasis-test-status set -g "${assignment%%=*}" "${assignment#*=}"
  done
  env -u TMUX tmux -L oasis-test-status source-file "$checkout_dir/oasis_tmux.conf"
  env -u TMUX tmux -L oasis-test-status display -p '#{T:status-right}'
}

# Output is the expanded bar, a's group first. The cap between a and c is drawn by c.
cap_between_a_and_c() {
  case $1 in
    *" A "*"$powerline_left_cap"*" C"*) printf yes ;;
    *) printf no ;;
  esac
}

# a and c are both accent groups with b hidden between them, so they only merge if their colours match
with_state=$(right_bar @oasis_module_a_state=crit)
assert_equals "crit accent group keeps a cap against a normal accent group" yes "$(cap_between_a_and_c "$with_state")"
case $with_state in
  *"#[bg=#ff7979]$powerline_left_cap"*) found=yes ;;
  *) found=no ;;
esac
assert_equals "that cap starts from the crit colour" yes "$found"

without_state=$(right_bar)
assert_equals "same-coloured accent groups merge without a cap" no "$(cap_between_a_and_c "$without_state")"
env -u TMUX tmux -L oasis-test-status kill-server 2>/dev/null || true
