# Cases for status/scripts/load.sh
. "$fixtures_dir/stubs.sh"
mkdir "$stub_data/proc"

# 16 cores: warn from 11.2, crit from 16
cp "$fixtures_dir/linux/nproc" "$stub_data/nproc"
set_load() { printf '%s 19.80 19.80 12/2368 228639\n' "$1" > "$stub_data/proc/loadavg"; }
load() { run_script load "$1" OASIS_UNAME=Linux OASIS_PROC_ROOT="$stub_data/proc" "${@:2}"; }

cp "$fixtures_dir/linux/loadavg" "$stub_data/proc/loadavg"
assert_equals "linux display" 15.46 "$(load display)"
assert_equals "linux real sample is warn on 16 cores" warn "$(load state)"
set_load 0.00;  assert_equals "idle display" 0.00 "$(load display)"
set_load 11.19; assert_equals "below warn" ok "$(load state)"
set_load 11.20; assert_equals "at warn" warn "$(load state)"
set_load 15.99; assert_equals "below crit" warn "$(load state)"
set_load 16.00; assert_equals "at crit" crit "$(load state)"
set_load 4.00
assert_equals "factors are options" crit "$(load state opt_oasis_load_warn=0.1 opt_oasis_load_crit=0.25)"
assert_equals "display ignores thresholds" 4.00 "$(load display opt_oasis_load_warn=0.1)"

printf '1\n' > "$stub_data/nproc"
set_load 0.70; assert_equals "one core, at warn" warn "$(load state)"
set_load 0.69; assert_equals "one core, below warn" ok "$(load state)"
set_load 1.00; assert_equals "one core, at crit" crit "$(load state)"
printf '10\n' > "$stub_data/nproc"
set_load 7.00; assert_equals "float factor lands on the boundary" warn "$(load state)"

rm "$stub_data/proc/loadavg"
assert_equals "missing loadavg hides" "" "$(load display)"
assert_equals "missing loadavg has no state" "" "$(load state)"
printf 'garbage\n' > "$stub_data/proc/loadavg"
assert_equals "unparsable loadavg hides" "" "$(load display)"
set_load 1.00; rm "$stub_data/nproc"
assert_equals "unknown core count has no state" "" "$(load state)"
assert_equals "unknown core count still displays" 1.00 "$(load display)"

macos() { run_script load "$1" OASIS_UNAME=Darwin "${@:2}"; }
cp "$fixtures_dir/macos/sysctl.vm.loadavg" "$fixtures_dir/macos/sysctl.hw.ncpu" "$stub_data/"
assert_equals "macos display" 1.23 "$(macos display)"
assert_equals "macos state on 8 cores" ok "$(macos state)"
printf '{ 5.60 1.45 1.67 }\n' > "$stub_data/sysctl.vm.loadavg"
assert_equals "macos at warn (0.7 x 8)" warn "$(macos state)"
printf '{ 8.00 1.45 1.67 }\n' > "$stub_data/sysctl.vm.loadavg"
assert_equals "macos at crit" crit "$(macos state)"
rm "$stub_data/sysctl.vm.loadavg"
assert_equals "macos missing data hides" "" "$(macos display)"

assert_equals "other systems hide" "" "$(run_script load display OASIS_UNAME=FreeBSD)"
