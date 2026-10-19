# Cases for status/scripts/ram.sh
. "$fixtures_dir/stubs.sh"
mkdir "$stub_data/proc"
ram() { run_script ram "$1" OASIS_UNAME=Linux OASIS_PROC_ROOT="$stub_data/proc" "${@:2}"; }
set_meminfo() { printf 'MemTotal: 1000 kB\nMemFree: 5 kB\nMemAvailable: %s kB\n' "$1" > "$stub_data/proc/meminfo"; }

cp "$fixtures_dir/linux/meminfo" "$stub_data/proc/meminfo"
assert_equals "linux display" "21%" "$(ram display)"
assert_equals "linux state" ok "$(ram state)"

set_meminfo 201; assert_equals "79.9 rounds to 80 and warns" warn "$(ram state)"
assert_equals "display matches the state" "80%" "$(ram display)"
set_meminfo 210; assert_equals "79.0 is ok" ok "$(ram state)"
set_meminfo 101; assert_equals "89.9 rounds to 90 and is crit" crit "$(ram state)"
set_meminfo 110; assert_equals "89.0 is warn" warn "$(ram state)"
set_meminfo 0;   assert_equals "full" "100%" "$(ram display)"
set_meminfo 1000; assert_equals "empty" "0%" "$(ram display)"
set_meminfo 500
assert_equals "thresholds are options" crit "$(ram state opt_oasis_ram_warn=10 opt_oasis_ram_crit=50)"

printf 'MemTotal: 1000 kB\n' > "$stub_data/proc/meminfo"
assert_equals "no MemAvailable hides" "" "$(ram display)"
printf 'MemAvailable: 10 kB\n' > "$stub_data/proc/meminfo"
assert_equals "no MemTotal hides" "" "$(ram display)"
rm "$stub_data/proc/meminfo"
assert_equals "missing meminfo hides" "" "$(ram display)"
assert_equals "missing meminfo has no state" "" "$(ram state)"

macos() { run_script ram "$1" OASIS_UNAME=Darwin "${@:2}"; }
cp "$fixtures_dir/macos/vm_stat" "$fixtures_dir/macos/sysctl.hw.memsize" "$stub_data/"
assert_equals "macos display (active + wired + compressed)" "37%" "$(macos display)"
assert_equals "macos state at warn" warn "$(macos state opt_oasis_ram_warn=37)"
assert_equals "macos 4096-byte pages" "9%" "$(sed 's/16384/4096/' "$fixtures_dir/macos/vm_stat" > "$stub_data/vm_stat"; macos display)"
rm "$stub_data/vm_stat"
assert_equals "macos missing vm_stat hides" "" "$(macos display)"

assert_equals "other systems hide" "" "$(run_script ram display OASIS_UNAME=FreeBSD)"
