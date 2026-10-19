# Cases for status/scripts/host.sh
host_script=$checkout_dir/status/scripts/host.sh
host_state() { bash "$host_script" state "$1" "$2"; }

states="prod-*=crit staging-*=warn"
assert_equals "first glob" crit "$(host_state prod-db1 "$states")"
assert_equals "second glob" warn "$(host_state staging-web "$states")"
assert_equals "no match" ok "$(host_state laptop "$states")"
assert_equals "empty list" ok "$(host_state prod-db1 "")"
assert_equals "first match wins" warn "$(host_state prod-db1 "prod-db*=warn prod-*=crit")"
assert_equals "hostname with dots" crit "$(host_state db1.prod.example.com "*.prod.example.com=crit")"
assert_equals "exact name" crit "$(host_state box "box=crit")"
assert_equals "glob does not match as a substring" ok "$(host_state my-prod-1 "prod-*=crit")"
assert_equals "question mark" warn "$(host_state web1 "web?=warn")"
assert_equals "catch-all" warn "$(host_state anything "*=warn")"
assert_equals "files in the working directory do not expand globs" crit "$(cd "$checkout_dir" && host_state README.md "*=crit")"

# A hostile option value must reach host.sh as data, not run as shell in the status #() job
scratch=$(mktemp -d)
host_tmux() { env -u TMUX tmux -L oasis-test-hostssh "$@"; }
host_tmux -f /dev/null new -d -s t -x 100 -y 5
host_tmux set -g status-interval 1
host_tmux set -g @oasis_status_left "host"
host_tmux set -g @oasis_status_right ""
host_tmux set -g @oasis_host_states "\$(touch $scratch/pwned) \`touch $scratch/pwned_tick\`=crit *=warn"
host_tmux source-file "$checkout_dir/oasis_tmux.conf"
(env -u TMUX timeout 4 script -qfc "stty cols 100 rows 5; env -u TMUX tmux -L oasis-test-hostssh attach -t t" "$scratch/term.log" >/dev/null 2>&1 || true)
assert_equals "hostile host_states ran nothing" "" "$(ls "$scratch" | grep '^pwned' || true)"
assert_equals "the status job did run" yes "$([ -s "$scratch/term.log" ] && echo yes)"
host_tmux kill-server || true
rm -rf "$scratch"
