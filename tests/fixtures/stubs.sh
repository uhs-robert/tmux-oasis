# Helpers for the metric script tests. Sourced after status/scripts/lib.sh.
# The scripts run with tests/fixtures/bin first on PATH: stand-ins for tmux, nproc,
# df, sysctl, vm_stat and ps that print files from $stub_data. That keeps the tests
# off the real tmux server (a bare tmux would read the owner's options) and lets
# Linux hosts exercise the macOS parsing.
stub_data=$(mktemp -d)
trap 'rm -rf "$stub_data"' EXIT
export OASIS_STUB_DATA=$stub_data

# Usage: run_script NAME MODE [VAR=value ...]
run_script() {
  local name=$1 mode=$2
  shift 2
  env -u TMUX -u XDG_RUNTIME_DIR PATH="$fixtures_dir/bin:$PATH" OASIS_STUB_DATA="$stub_data" "$@" \
    bash "$checkout_dir/status/scripts/$name.sh" "$mode"
}
