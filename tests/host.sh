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
assert_equals "case-insensitive" warn "$(host_state Roberts-MacBook "roberts-*=warn")"
assert_equals "case-insensitive pattern" warn "$(host_state roberts-mac "Roberts-*=warn")"
assert_equals "pair without = is skipped" crit "$(host_state prod-1 "prod-* prod-*=crit")"
assert_equals "unknown state is skipped" crit "$(host_state prod-1 "prod-*=red prod-*=crit")"
assert_equals "only malformed pairs" ok "$(host_state prod-1 "prod-* x=")"
assert_equals "catch-all" warn "$(host_state anything "*=warn")"
assert_equals "files in the working directory do not expand globs" crit "$(cd "$checkout_dir" && host_state README.md "*=crit")"

# A hostile option value must reach host.sh as data, not run as shell in the status #() job
scratch=$(mktemp -d)
host_tmux() { env -u TMUX tmux -L oasis-test-hostssh "$@"; }
trap 'host_tmux kill-server 2>/dev/null; rm -rf "$scratch"' EXIT
host_tmux -f /dev/null new -d -s t -x 100 -y 5
host_tmux set -g status-interval 1
host_tmux set -g @oasis_flavor moonlight_dark
host_tmux set -g @oasis_status_left "host"
host_tmux set -g @oasis_status_right ""
host_tmux set -g @oasis_host_states "\$(touch $scratch/pwned) \`touch $scratch/pwned_tick\`=crit *=crit"
host_tmux source-file "$checkout_dir/oasis_tmux.conf"
(env -u TMUX timeout 4 script -qfc "stty cols 100 rows 5; env -u TMUX tmux -L oasis-test-hostssh attach -t t" "$scratch/term.log" >/dev/null 2>&1 || true)
assert_equals "hostile host_states ran nothing" "" "$(ls "$scratch" | grep '^pwned' || true)"
# moonlight_dark crit is #ff7979; the colour only appears if host.sh ran and printed crit
assert_equals "the crit colour was drawn" yes "$(grep -q '255[;:]121[;:]121' "$scratch/term.log" && echo yes || echo no)"
