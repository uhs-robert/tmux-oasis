# Cases for status/modules/application.conf (pure tmux formats, so display -p evaluates them)
app_tmux() { env -u TMUX tmux -L oasis-test-application "$@"; }
trap 'app_tmux kill-server 2>/dev/null' EXIT
app_tmux -f /dev/null new -d -s t -x 100 -y 5 "exec sleep 60"
app_tmux source-file "$checkout_dir/status/modules/application.conf"

app_eval() { app_tmux display -p -t t: "$1"; }

sleep 0.3
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
trap 'app_tmux kill-server 2>/dev/null; rm -rf "$scratch"' EXIT
ln -s "$(command -v sleep)" "$scratch/verylongprogramname"
app_tmux respawn-pane -k -t t: "exec $scratch/verylongprogramname 60"
sleep 0.3
assert_equals "text is cut at 15 characters" $'\xf3\xb0\xa3\x86 verylongprogram' "$(app_eval '#{E:@oasis_module_application}')"
