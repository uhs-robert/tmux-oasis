# Cases for status/scripts/cpu.sh
. "$fixtures_dir/stubs.sh"
mkdir "$stub_data/proc" "$stub_data/run"
cpu() { run_script cpu "$1" OASIS_UNAME=Linux OASIS_PROC_ROOT="$stub_data/proc" XDG_RUNTIME_DIR="$stub_data/run" "${@:2}"; }
# Usage: sample UPTIME_SECONDS BUSY_TICKS IDLE_TICKS (cumulative since an arbitrary start, like /proc/stat)
sample() {
  printf '%s 0.00\n' "$1" > "$stub_data/proc/uptime"
  printf 'cpu  %s 0 0 %s 0 0 0 0 0 0\ncpu0 1 1 1 1 1 1 1 1 1 1\n' "$(($2 + 1000))" "$(($3 + 1000))" > "$stub_data/proc/stat"
}
forget() { rm -rf "$stub_data/run/oasis-tmux"; }

# Real kernel samples 1 s apart
cp "$fixtures_dir/linux/stat1" "$stub_data/proc/stat"; echo "1000.00 1.00" > "$stub_data/proc/uptime"
assert_equals "first run prints nothing" "" "$(cpu display)"
assert_equals "first run has no state" "" "$(cpu state)"
cp "$fixtures_dir/linux/stat2" "$stub_data/proc/stat"; echo "1001.00 1.00" > "$stub_data/proc/uptime"
assert_equals "second run is the delta" "36%" "$(cpu display)"
assert_equals "state within the same refresh agrees" ok "$(cpu state)"
assert_equals "display again in the same refresh agrees" "36%" "$(cpu display)"

# Both modes in one refresh must report one value: the later call must not diff against a sample taken ms ago
forget
sample 100.00 0 100;   cpu display >/dev/null
sample 101.00 75 125;  assert_equals "display after a delta" "75%" "$(cpu display)"
sample 101.05 76 125;  assert_equals "state reuses the value within half a second" warn "$(cpu state)"
sample 101.10 77 126;  assert_equals "display reuses it too" "75%" "$(cpu display)"
sample 101.60 100 125; assert_equals "a later refresh recomputes" "100%" "$(cpu display)"

# iowait can run backwards, which must not leave 0..100
forget; sample 100.00 100 100; cpu display >/dev/null
sample 101.00 200 90
assert_equals "negative idle delta clamps to 100" "100%" "$(cpu display)"
forget; sample 100.00 100 100; cpu display >/dev/null
sample 101.00 90 200
assert_equals "negative busy delta clamps to 0" "0%" "$(cpu display)"

# Without XDG_RUNTIME_DIR the samples live in a private per-user directory under TMPDIR
no_xdg() { run_script cpu display OASIS_UNAME=Linux OASIS_PROC_ROOT="$stub_data/proc" TMPDIR="$stub_data/tmp"; }
mkdir "$stub_data/tmp"
sample 1.00 1 1; no_xdg >/dev/null
private_dir=$stub_data/tmp/oasis-tmux-$(id -u)
assert_equals "private dir mode" 700 "$(stat -c %a "$private_dir" 2>/dev/null || stat -f %Lp "$private_dir")"
sample 2.00 51 51
assert_equals "private dir caches" "50%" "$(no_xdg)"
rm -rf "$private_dir"; mkdir "$stub_data/elsewhere"; ln -s "$stub_data/elsewhere" "$private_dir"
sample 1.00 1 1; no_xdg >/dev/null; sample 2.00 51 51
assert_equals "symlinked dir is not used" "" "$(no_xdg)"
assert_equals "and nothing is written through it" "" "$(ls "$stub_data/elsewhere")"

# The refresh after a first run
forget
sample 100.00 0 100
assert_equals "first run" "" "$(cpu display)"
sample 100.10 50 150
assert_equals "second call in the first refresh stays empty" "" "$(cpu state)"
sample 101.00 70 130
assert_equals "next refresh has a delta" "70%" "$(cpu display)"

# Thresholds: 100 ticks per refresh
for pair in "69 ok" "70 warn" "89 warn" "90 crit" "100 crit"; do
  forget
  sample 10.00 0 0; cpu display >/dev/null
  sample 11.00 "${pair% *}" "$((100 - ${pair% *}))"
  assert_equals "state at ${pair% *}%" "${pair#* }" "$(cpu state)"
done
forget; sample 10.00 0 0; cpu display >/dev/null
sample 11.00 10 90
assert_equals "thresholds are options" crit "$(cpu state opt_oasis_cpu_warn=5 opt_oasis_cpu_crit=10)"
assert_equals "idle machine shows 0%" "0%" "$(forget; sample 10.00 0 0; cpu display >/dev/null; sample 11.00 0 100; cpu display)"

# Iowait counts as idle; steal counts as busy
forget
printf '10.00 0\n' > "$stub_data/proc/uptime"; printf 'cpu  100 0 0 100 0 0 0 0\n' > "$stub_data/proc/stat"; cpu display >/dev/null
printf '11.00 0\n' > "$stub_data/proc/uptime"; printf 'cpu  100 0 0 150 50 0 0 0\n' > "$stub_data/proc/stat"
assert_equals "iowait is idle" "0%" "$(cpu display)"
forget
printf '10.00 0\n' > "$stub_data/proc/uptime"; printf 'cpu  100 0 0 100 0 0 0 0\n' > "$stub_data/proc/stat"; cpu display >/dev/null
printf '11.00 0\n' > "$stub_data/proc/uptime"; printf 'cpu  100 0 0 150 0 0 0 50\n' > "$stub_data/proc/stat"
assert_equals "steal is busy" "50%" "$(cpu display)"

# Unusable input
forget; sample 100.00 50 50; cpu display >/dev/null
sample 100.90 60 60
assert_equals "no ticks passed since the sample" "" "$(sample 101.00 50 50; cpu display)"
forget; sample 5000.00 50 50; cpu display >/dev/null
assert_equals "uptime reset (reboot) restarts the sample" "" "$(sample 3.00 60 60; cpu display)"
assert_equals "then recovers" "50%" "$(sample 4.00 90 90; cpu display)"
forget; rm "$stub_data/proc/stat"
assert_equals "missing stat hides" "" "$(cpu display)"
printf 'nonsense\n' > "$stub_data/proc/stat"
assert_equals "unparsable stat hides" "" "$(cpu display)"
forget; sample 1.00 1 1; rm "$stub_data/proc/uptime"
assert_equals "missing uptime hides" "" "$(cpu display)"

macos() { run_script cpu "$1" OASIS_UNAME=Darwin "${@:2}"; }
cp "$fixtures_dir/macos/ps" "$fixtures_dir/macos/sysctl.hw.ncpu" "$stub_data/"
assert_equals "macos sums ps over the core count" "13%" "$(macos display)"
assert_equals "macos state" ok "$(macos state)"
printf ' 400.0\n 400.0\n' > "$stub_data/ps"
assert_equals "macos over 100% is clamped" "100%" "$(macos display)"
assert_equals "macos crit" crit "$(macos state)"
printf ' 280.0\n' > "$stub_data/ps"
assert_equals "macos 280% over 8 cores is 35%, ok" ok "$(macos state)"
rm "$stub_data/ps"
assert_equals "macos missing ps hides" "" "$(macos display)"

assert_equals "other systems hide" "" "$(run_script cpu display OASIS_UNAME=FreeBSD)"
