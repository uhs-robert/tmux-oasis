# Cases for status/modules/user.conf
user_tmux() { env -u TMUX tmux -L oasis-test-user "$@"; }
trap 'user_tmux kill-server 2>/dev/null' EXIT
user_tmux -f /dev/null new -d -s t -x 100 -y 5
user_tmux set -g @oasis_flavor moonlight_dark
user_tmux set -g @oasis_status_left "user"
user_tmux set -g @oasis_status_right ""
user_tmux source-file "$checkout_dir/oasis_tmux.conf"

icon=$(printf '\363\260\200\204 ')
login=$(id -un)
module() { user_tmux display -p "#{E:@oasis_module_user}"; }

assert_equals "icon and login" "$icon$login" "$(module)"
assert_equals "shown when the user is known" "1" "$(user_tmux display -p "#{E:@oasis_module_user_when}")"

user_tmux set -g @oasis_user_icon "U:"
assert_equals "icon override" "U:$login" "$(module)"

# Swap #{user} in the shipped condition for a format that expands empty, as on a tmux without it
user_tmux set -g @oasis_user_when_probe "$(user_tmux show -gv @oasis_module_user_when | sed "s/{user}/{no_such_format}/")"
assert_equals "empty user is hidden" "0" "$(user_tmux display -p "#{E:@oasis_user_when_probe}")"
