# Cases for status/scripts/temp.sh
script=$checkout_dir/status/scripts/temp.sh
# Scripts read their options with `tmux show`, which would reach the owner's server from here
tmux() { case $3 in @oasis_temp_warn) printf '%s' "${fake_warn:-}" ;; @oasis_temp_crit) printf '%s' "${fake_crit:-}" ;; esac; }
export -f tmux
temp() { OASIS_SYS_ROOT=$fixtures_dir/$1 bash "$script" "${@:2}"; }
text() { temp "$1" text; }
state() { temp "$1" state; }
deg=$'\xc2\xb0C'

assert_equals "k10temp rounds to nearest" "62$deg" "$(text sys_temp_k10temp)"
assert_equals "k10temp below warn" ok "$(state sys_temp_k10temp)"
assert_equals "coretemp at warn trips" "70$deg" "$(text sys_temp_coretemp)"
assert_equals "coretemp state at warn" warn "$(state sys_temp_coretemp)"
assert_equals "thermal zone fallback" "80$deg" "$(text sys_temp_thermal_only)"
assert_equals "state at crit" crit "$(state sys_temp_thermal_only)"
assert_equals "raspberry pi name below warn" "4$deg" "$(text sys_temp_cool_pi)"
assert_equals "below warn is ok" ok "$(state sys_temp_cool_pi)"
assert_equals "acpitz alone is hidden" "" "$(text sys_temp_none)"
assert_equals "acpitz alone has no state" "" "$(state sys_temp_none)"
assert_equals "cpu sensor is found past a non-cpu hwmon" "55$deg" "$(text sys_temp_two_hwmon)"
assert_equals "hwmon wins over thermal zone" "50$deg" "$(text sys_temp_hwmon_first)"
assert_equals "non-numeric reading is hidden" "" "$(text sys_temp_bad)"
assert_equals "missing reading file is hidden" "" "$(text sys_temp_unreadable)"
assert_equals "missing sys root is hidden" "" "$(text sys_nowhere)"

assert_equals "thresholds are options" crit "$(fake_warn=40 fake_crit=60 state sys_temp_k10temp)"
assert_equals "text ignores thresholds" "62$deg" "$(fake_warn=40 fake_crit=60 text sys_temp_k10temp)"
assert_equals "macos is hidden" "" "$(OASIS_UNAME=Darwin text sys_temp_k10temp)"
assert_equals "unsupported system is hidden" "" "$(OASIS_UNAME=FreeBSD text sys_temp_k10temp)"

assert_equals "Tdie is preferred over Tctl" "55$deg" "$(text sys_temp_tdie)"
assert_equals "zenpower is a cpu sensor" "58$deg" "$(text sys_temp_zenpower)"
assert_equals "thermal zone type cpu-thermal" "48$deg" "$(text sys_temp_cpu_dash)"
assert_equals "69499 rounds down and is ok" ok "$(state sys_temp_69499)"
assert_equals "69500 rounds up and is warn" warn "$(state sys_temp_69500)"
assert_equals "79499 is still warn" warn "$(state sys_temp_79499)"
assert_equals "79500 rounds up and is crit" crit "$(state sys_temp_79500)"
assert_equals "negative reading is hidden" "" "$(text sys_temp_negative)"
