# Cases for status/scripts/disk.sh
. "$fixtures_dir/stubs.sh"
disk() { run_script disk "$1" OASIS_UNAME=Linux "${@:2}"; }
set_capacity() { printf 'Filesystem 1024-blocks Used Available Capacity Mounted on\n/dev/x 100 1 1 %s /\n' "$1" > "$stub_data/df"; }

cp "$fixtures_dir/linux/df_root" "$stub_data/df"
assert_equals "linux display" "7%" "$(disk display)"
assert_equals "linux state" ok "$(disk state)"
assert_equals "default path is /" "-P /" "$(cat "$stub_data/df.args")"
disk display opt_oasis_disk_path=/home/me >/dev/null
assert_equals "path option is passed to df" "-P /home/me" "$(cat "$stub_data/df.args")"

set_capacity 79%;  assert_equals "below warn" ok "$(disk state)"
set_capacity 80%;  assert_equals "at warn" warn "$(disk state)"
set_capacity 89%;  assert_equals "below crit" warn "$(disk state)"
set_capacity 90%;  assert_equals "at crit" crit "$(disk state)"
set_capacity 100%; assert_equals "full" "100%" "$(disk display)"
set_capacity 0%;   assert_equals "empty" "0%" "$(disk display)"
set_capacity 50%
assert_equals "thresholds are options" crit "$(disk state opt_oasis_disk_warn=10 opt_oasis_disk_crit=50)"

printf 'Filesystem 1024-blocks Used Available Capacity Mounted on\n//srv/My Share 100 1 1 5%% /mnt/x\n' > "$stub_data/df"
assert_equals "device name with spaces" "5%" "$(disk display)"
set_capacity "-"
assert_equals "no capacity hides" "" "$(disk display)"
printf 'df: /nope: No such file or directory\n' > "$stub_data/df"
assert_equals "df failure hides" "" "$(disk display)"
rm "$stub_data/df"
assert_equals "no output hides" "" "$(disk display)"
assert_equals "no output has no state" "" "$(disk state)"

macos() { run_script disk "$1" OASIS_UNAME=Darwin "${@:2}"; }
mkdir "$stub_data/data_volume"
macos_df() { cp "$fixtures_dir/macos/$1" "$stub_data/df"; }
macos_df df_system
assert_equals "macos without a data volume reads /" "5%" "$(macos display OASIS_MACOS_DATA_VOLUME="$stub_data/missing")"
assert_equals "macos reads /" "-P /" "$(cat "$stub_data/df.args")"
macos_df df_data
assert_equals "macos / switches to the data volume" "83%" "$(macos display OASIS_MACOS_DATA_VOLUME="$stub_data/data_volume")"
assert_equals "macos asks df for the data volume" "-P $stub_data/data_volume" "$(cat "$stub_data/df.args")"
assert_equals "macos state" warn "$(macos state OASIS_MACOS_DATA_VOLUME="$stub_data/data_volume")"
macos display opt_oasis_disk_path=/Volumes/x OASIS_MACOS_DATA_VOLUME="$stub_data/data_volume" >/dev/null
assert_equals "macos keeps an explicit path" "-P /Volumes/x" "$(cat "$stub_data/df.args")"

assert_equals "other systems hide" "" "$(run_script disk display OASIS_UNAME=FreeBSD)"
