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
