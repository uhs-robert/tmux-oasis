# Cases for status/modules/application.conf (pure tmux formats, so display -p evaluates them)
app_tmux() { env -u TMUX tmux -L oasis-test-application "$@"; }
trap 'app_tmux kill-server 2>/dev/null' EXIT
app_tmux -f /dev/null new -d -s t -x 100 -y 5 "exec sleep 60"
app_tmux source-file "$checkout_dir/status/modules/application.conf"

app_eval() { app_tmux display -p -t t: "$1"; }
# Usage: wait_for_command NAME -- poll up to 2 s for the pane's command to become NAME
wait_for_command() {
  local tries=0
  until [ "$(app_eval '#{pane_current_command}')" = "$1" ] || [ $tries -ge 20 ]; do sleep 0.1; tries=$((tries + 1)); done
}

wait_for_command sleep
# The running pane command is "sleep": hidden only when the regex names it
assert_equals "program is shown" 1 "$(app_eval '#{E:@oasis_module_application_when}')"
assert_equals "text is icon and command" $'\xf3\xb0\xa3\x86 sleep' "$(app_eval '#{E:@oasis_module_application}')"

app_tmux set -g @oasis_application_hidden_regex '^sleep$'
assert_equals "matching regex hides" 0 "$(app_eval '#{E:@oasis_module_application_when}')"
app_tmux set -g @oasis_application_hidden_regex '^-?(bash|sleep)$'
assert_equals "custom list hides" 0 "$(app_eval '#{E:@oasis_module_application_when}')"
app_tmux set -g @oasis_application_hidden_regex '^bash$'
assert_equals "non-matching regex shows" 1 "$(app_eval '#{E:@oasis_module_application_when}')"
app_tmux set -g @oasis_application_hidden_regex ''
assert_equals "empty regex shows everything" 1 "$(app_eval '#{E:@oasis_module_application_when}')"

# The default regex against shell names, a login shell on macOS and lookalikes
app_tmux set -g @oasis_application_hidden_regex '^-?(bash|zsh|fish|sh|dash)$'
for name in bash zsh fish sh dash -zsh -bash; do
  assert_equals "default hides $name" 0 "$(app_eval "#{?#{m/r:#{@oasis_application_hidden_regex},$name},0,1}")"
done
for name in nvim ssh shell bashful zsh-5 claude; do
  assert_equals "default shows $name" 1 "$(app_eval "#{?#{m/r:#{@oasis_application_hidden_regex},$name},0,1}")"
done

scratch=$(mktemp -d)
trap 'app_tmux kill-server 2>/dev/null || true; rm -rf "$scratch"' EXIT
ln -s "$(command -v sleep)" "$scratch/verylongprogramname"
app_tmux respawn-pane -k -t t: "exec $scratch/verylongprogramname 60"
wait_for_command verylongprogramname
assert_equals "text is cut at 15 characters" $'\xf3\xb0\xa3\x86 verylongprogram' "$(app_eval '#{E:@oasis_module_application}')"

# Commas, braces and #{} in the regex reach the match intact, inline and through #{E:}
wait_for_command verylongprogramname
app_tmux set -g @oasis_application_hidden_regex '^(a,b|very.{1,1}ongprogramname)$'
assert_equals "comma and braces in the regex still match" 0 "$(app_eval '#{E:@oasis_module_application_when}')"
app_tmux set -g @oasis_application_hidden_regex '^(a,b|x{2,3})$'
assert_equals "comma and braces in the regex still miss" 1 "$(app_eval '#{E:@oasis_module_application_when}')"

# The real module wiring, drawn: a shell-named pane hides the group and its separators
# Usage: draw_bar PROGRAM -- the text of a bar with the application module, in a pane running PROGRAM
draw_bar() {
  local draw_tmux="oasis-test-application-draw"
  ln -sf "$(command -v sleep)" "$scratch/$1"
  env -u TMUX tmux -L $draw_tmux kill-server 2>/dev/null || true
  env -u TMUX tmux -L $draw_tmux -f /dev/null new -d -s t -x 100 -y 5 "exec $scratch/$1 60"
  env -u TMUX tmux -L $draw_tmux set -g status-interval 1
  env -u TMUX tmux -L $draw_tmux set -g @oasis_application_icon 'APPICON '
  env -u TMUX tmux -L $draw_tmux set -g @oasis_status_left session
  env -u TMUX tmux -L $draw_tmux set -g @oasis_status_right "application | clock"
  env -u TMUX tmux -L $draw_tmux source-file "$checkout_dir/oasis_tmux.conf"
  local tries=0
  until [ "$(env -u TMUX tmux -L $draw_tmux display -p -t t: '#{pane_current_command}')" = "$1" ] || [ $tries -ge 20 ]; do sleep 0.1; tries=$((tries + 1)); done
  (env -u TMUX timeout 4 script -qfc "stty cols 100 rows 5; env -u TMUX tmux -L $draw_tmux attach -t t" "$scratch/term.log" >/dev/null 2>&1 || true)
  env -u TMUX tmux -L $draw_tmux kill-server 2>/dev/null || true
  sed 's/\x1b\[[0-9;?]*[a-zA-Z]//g' "$scratch/term.log"
}
bar=$(draw_bar sleep)
case $bar in *"APPICON sleep"*) shown=yes ;; *) shown=no ;; esac
assert_equals "a program pane draws the module" yes "$shown"
right_separator=$'\xee\x82\xb2'
shown_separators=$(printf %s "$bar" | grep -o "$right_separator" | wc -l | tr -d ' ')
bar=$(draw_bar zsh)
case $bar in *APPICON*) shown=yes ;; *) shown=no ;; esac
assert_equals "a shell pane hides the module" no "$shown"
hidden_separators=$(printf %s "$bar" | grep -o "$right_separator" | wc -l | tr -d ' ')
assert_equals "a shell pane draws fewer separators" yes "$([ "$hidden_separators" -lt "$shown_separators" ] && echo yes || echo no)"
