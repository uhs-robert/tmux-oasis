#!/usr/bin/env bash
# Usage: load.sh display|state
# 1-minute load average. State compares it to the core count: warn and crit are
# factors of it (@oasis_load_warn, @oasis_load_crit), so 4 is calm on 16 cores.
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

case "$(oasis_platform)" in
  linux)
    read -r load _ 2>/dev/null < "$OASIS_PROC_ROOT/loadavg"
    # --all: plain nproc follows OMP_NUM_THREADS and CPU affinity
    cores=$(nproc --all 2>/dev/null || getconf _NPROCESSORS_ONLN 2>/dev/null)
    ;;
  macos)
    # "{ 1.23 1.45 1.67 }"
    read -r _ load _ <<< "$(sysctl -n vm.loadavg 2>/dev/null)"
    cores=$(sysctl -n hw.ncpu 2>/dev/null)
    ;;
  *) exit 0 ;;
esac
[[ ${load:-} =~ ^[0-9]+(\.[0-9]+)?$ ]] || exit 0

if [ "${1:-}" = state ]; then
  [[ ${cores:-} =~ ^[1-9][0-9]*$ ]] || exit 0
  # %.4f absorbs float noise so 0.7 x 10 cores lands exactly on 7
  warn=$(awk -v cores="$cores" -v factor="$(oasis_option @oasis_load_warn 0.7)" 'BEGIN { printf "%.4f", cores * factor }')
  crit=$(awk -v cores="$cores" -v factor="$(oasis_option @oasis_load_crit 1.0)" 'BEGIN { printf "%.4f", cores * factor }')
  oasis_level "$load" "$warn" "$crit"
else
  oasis_report display "$load" ""
fi
