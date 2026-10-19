#!/usr/bin/env bash
# Usage: test.sh [name ...]
# Runs tests/<name>.sh for each name, or every tests/*.sh. Each file is sourced in
# a subshell after status/scripts/lib.sh and the assert_* helpers below, so a
# module's cases need no setup: call assert_equals and point OASIS_PROC_ROOT /
# OASIS_SYS_ROOT at a fixture tree under tests/fixtures/.
set -u
dev_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
checkout_dir=$(dirname "$dev_dir")
export fixtures_dir=$checkout_dir/tests/fixtures

results=$(mktemp)
trap 'rm -f "$results"' EXIT

# Usage: assert_equals DESCRIPTION EXPECTED ACTUAL
assert_equals() {
  if [ "$2" = "$3" ]; then
    printf 'ok\n' >> "$results"
  else
    printf 'FAIL\n' >> "$results"
    printf 'FAIL %s: %s: expected [%s], got [%s]\n' "$test_name" "$1" "$2" "$3" >&2
  fi
}

if [ $# -gt 0 ]; then
  test_files=()
  for test_name in "$@"; do test_files+=("$checkout_dir/tests/$test_name.sh"); done
else
  test_files=("$checkout_dir"/tests/*.sh)
fi

for test_file in "${test_files[@]}"; do
  [ -f "$test_file" ] || { echo "no such test file: $test_file" >&2; exit 1; }
  test_name=$(basename "$test_file" .sh)
  ( . "$checkout_dir/status/scripts/lib.sh"; . "$test_file" )
done

passed=$(grep -c '^ok$' "$results")
failed=$(grep -c '^FAIL$' "$results")
echo "$passed passed, $failed failed"
[ "$failed" -eq 0 ] && [ "$passed" -gt 0 ]
