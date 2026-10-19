# Cases for status/scripts/lib.sh
lib_path=$checkout_dir/status/scripts/lib.sh

# Thresholds 70 / 90: high is bad
assert_equals "high: below warn" ok "$(oasis_level 69 70 90)"
assert_equals "high: at warn" warn "$(oasis_level 70 70 90)"
assert_equals "high: between" warn "$(oasis_level 89 70 90)"
assert_equals "high: at crit" crit "$(oasis_level 90 70 90)"
assert_equals "high: above crit" crit "$(oasis_level 100 70 90)"

# Thresholds 20 / 10: low is bad
assert_equals "low: above warn" ok "$(oasis_level 21 20 10)"
assert_equals "low: at warn" warn "$(oasis_level 20 20 10)"
assert_equals "low: between" warn "$(oasis_level 11 20 10)"
assert_equals "low: at crit" crit "$(oasis_level 10 20 10)"
assert_equals "low: below crit" crit "$(oasis_level 0 20 10)"

assert_equals "decimal value, high" warn "$(oasis_level 1.23 1 2)"
assert_equals "decimal value below" ok "$(oasis_level 0.99 1 2)"
assert_equals "decimal boundary" crit "$(oasis_level 2.0 1 2)"
assert_equals "decimal thresholds, low" warn "$(oasis_level 15.5 20.5 10.5)"
assert_equals "negative value" crit "$(oasis_level -5 20 0)"

assert_equals "empty value" "" "$(oasis_level '' 70 90)"
assert_equals "missing value" "" "$(oasis_level)"
assert_equals "non-numeric value" "" "$(oasis_level abc 70 90)"
assert_equals "number with unit" "" "$(oasis_level 50% 70 90)"
assert_equals "non-numeric threshold" "" "$(oasis_level 50 x 90)"

assert_equals "padded value" warn "$(oasis_level '   70' 70 90)"
assert_equals "padded value, trailing" crit "$(oasis_level ' 95 ' ' 70' '90 ')"
assert_equals "blank value" "" "$(oasis_level '   ' 70 90)"
assert_equals "equal thresholds are high-is-bad" crit "$(oasis_level 5 5 5)"

assert_equals "linux" linux "$(OASIS_UNAME=Linux oasis_platform)"
assert_equals "macos" macos "$(OASIS_UNAME=Darwin oasis_platform)"
assert_equals "other systems" unsupported "$(OASIS_UNAME=FreeBSD oasis_platform)"

tmux() { [ "$3" = @set_option ] && printf 'from_tmux'; return 0; }
assert_equals "option set" from_tmux "$(oasis_option @set_option fallback)"
assert_equals "option unset uses default" fallback "$(oasis_option @unset_option fallback)"
assert_equals "option unset, no default" "" "$(oasis_option @unset_option)"

assert_equals "default proc root" /proc "$(env -u OASIS_PROC_ROOT bash -c '. "$0"; printf %s "$OASIS_PROC_ROOT"' "$lib_path")"
assert_equals "proc root override" /fixture "$(OASIS_PROC_ROOT=/fixture bash -c '. "$0"; printf %s "$OASIS_PROC_ROOT"' "$lib_path")"
assert_equals "default sys root" /sys "$(env -u OASIS_SYS_ROOT bash -c '. "$0"; printf %s "$OASIS_SYS_ROOT"' "$lib_path")"
