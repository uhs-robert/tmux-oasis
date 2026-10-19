# Cases for status/scripts/battery.sh
script=$checkout_dir/status/scripts/battery.sh
icons=$'a b c d e'
bat() { OASIS_SYS_ROOT=$fixtures_dir/$1 bash "$script" "${@:2}"; }
text() { bat "$1" text "x$icons" xP; }
state() { bat "$1" state x50 x20; }

assert_equals "full real laptop is hidden" "" "$(text sys_laptop)"
assert_equals "full real laptop has no state" "" "$(state sys_laptop)"
assert_equals "desktop is hidden" "" "$(text sys_desktop)"
assert_equals "mouse alone is hidden" "" "$(text sys_mouse_only)"
assert_equals "mouse alone has no state" "" "$(state sys_mouse_only)"
assert_equals "missing sys root is hidden" "" "$(text sys_nowhere)"

assert_equals "two batteries are capacity-weighted" "d 80%" "$(text sys_two_batteries)"
assert_equals "capacity file is the fallback" "d 73%" "$(text sys_capacity_only)"
assert_equals "charging shows the charging icon" "P 50%" "$(text sys_charging)"
assert_equals "charging is always ok" ok "$(state sys_charging)"
assert_equals "full with status Full is hidden" "" "$(text sys_full)"

assert_equals "icon at 20" "a 20%" "$(text sys_level_20)"
assert_equals "icon at 21" "b 21%" "$(text sys_level_21)"
assert_equals "icon at 40" "b 40%" "$(text sys_level_40)"
assert_equals "icon at 41" "c 41%" "$(text sys_level_41)"
assert_equals "icon at 50" "c 50%" "$(text sys_level_50)"
assert_equals "icon at 80" "d 80%" "$(text sys_level_80)"
assert_equals "icon at 81" "e 81%" "$(text sys_level_81)"

assert_equals "state at 51" ok "$(state sys_level_51)"
assert_equals "state at 50" warn "$(state sys_level_50)"
assert_equals "state at 21" warn "$(state sys_level_21)"
assert_equals "state at 20" crit "$(state sys_level_20)"
assert_equals "custom thresholds" crit "$(bat sys_level_50 state x60 x50)"

mac() { OASIS_UNAME=Darwin OASIS_PMSET_OUTPUT=$(cat "$fixtures_dir/pmset/$1.txt") bash "$script" "${@:2}"; }
assert_equals "macos discharging" "e 85%" "$(mac discharging text "x$icons" xP)"
assert_equals "macos discharging state" ok "$(mac discharging state x50 x20)"
assert_equals "macos charging" "P 85%" "$(mac charging text "x$icons" xP)"
assert_equals "macos charging state" ok "$(mac charging state x90 x50)"
assert_equals "macos AC attached, not charging" "d 78%" "$(mac held text "x$icons" xP)"
assert_equals "macos charged is hidden" "" "$(mac charged text "x$icons" xP)"
assert_equals "macos without battery is hidden" "" "$(mac none text "x$icons" xP)"
assert_equals "unsupported system is hidden" "" "$(OASIS_UNAME=FreeBSD bash "$script" text "x$icons" xP)"
