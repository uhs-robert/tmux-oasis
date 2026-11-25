# Cases for status/scripts/uptime.sh
. "$fixtures_dir/stubs.sh"
mkdir "$stub_data/proc"

uptime_text() { run_script uptime text OASIS_UNAME=Linux OASIS_PROC_ROOT="$stub_data/proc" "$@"; }
set_uptime() { printf '%s 99999.99\n' "$1" > "$stub_data/proc/uptime"; }

set_uptime 0.50;      assert_equals "under a minute" "0m" "$(uptime_text)"
set_uptime 59.99;     assert_equals "59 seconds" "0m" "$(uptime_text)"
set_uptime 60.00;     assert_equals "one minute" "1m" "$(uptime_text)"
set_uptime 3599.00;   assert_equals "just under an hour" "59m" "$(uptime_text)"
set_uptime 3600.00;   assert_equals "one hour" "1h 0m" "$(uptime_text)"
set_uptime 15120.00;  assert_equals "4h 12m" "4h 12m" "$(uptime_text)"
set_uptime 86399.00;  assert_equals "just under a day" "23h 59m" "$(uptime_text)"
set_uptime 86400.00;  assert_equals "one day" "1d 0h" "$(uptime_text)"
set_uptime 273600.12; assert_equals "3d 4h" "3d 4h" "$(uptime_text)"
set_uptime 10454400.00; assert_equals "over 100 days" "121d 0h" "$(uptime_text)"

rm "$stub_data/proc/uptime"
assert_equals "missing file hides" "" "$(uptime_text)"
printf 'garbage\n' > "$stub_data/proc/uptime"
assert_equals "unparsable file hides" "" "$(uptime_text)"

macos() { run_script uptime text OASIS_UNAME=Darwin "$@"; }
cp "$fixtures_dir/macos/sysctl.kern.boottime" "$stub_data/"
assert_equals "macos 3d 4h" "3d 4h" "$(macos OASIS_NOW=$(( 1700000000 + 273600 )))"
assert_equals "macos under an hour" "12m" "$(macos OASIS_NOW=$(( 1700000000 + 720 )))"
assert_equals "macos bad clock hides" "" "$(macos OASIS_NOW=x)"
printf 'garbage\n' > "$stub_data/sysctl.kern.boottime"
assert_equals "macos unparsable boottime hides" "" "$(macos)"
rm "$stub_data/sysctl.kern.boottime"
assert_equals "macos missing data hides" "" "$(macos)"

assert_equals "other systems hide" "" "$(run_script uptime text OASIS_UNAME=FreeBSD)"
