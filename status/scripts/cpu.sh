#!/usr/bin/env bash
# Usage: cpu.sh display|state
# CPU busy percent since the previous refresh. Linux diffs /proc/stat against the sample
# the last run left behind, so there is nothing to sleep on and the first run prints nothing.
#
# display and state are different #() commands, so one refresh runs the script at least
# twice. The sample file therefore also keeps the last result: a run less than half a
# second after the sample reuses it, so both modes (and several clients) agree instead of
# the second one seeing a near-empty delta.
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

reuse_window=0.5

# Prints the percent, or nothing without a usable previous sample.
linux_percent() {
  local dir=${XDG_RUNTIME_DIR:-${TMPDIR:-/tmp}}/oasis-tmux
  local file=$dir/cpu
  local now cpu_line
  read -r now _ 2>/dev/null < "$OASIS_PROC_ROOT/uptime" || return 0
  read -r cpu_line 2>/dev/null < "$OASIS_PROC_ROOT/stat" || return 0
  mkdir -p "$dir" 2>/dev/null || return 0

  # The file is "uptime busy_plus_idle idle percent". Uptime restarting at boot reads as no sample.
  local result
  result=$(awk -v now="$now" -v window="$reuse_window" -v line="$cpu_line" '
    BEGIN {
      split(line, field, " ")
      for (i = 2; i <= 9; i++) total += field[i]
      idle = field[5] + field[6]
      if (field[1] != "cpu" || total == 0) exit
      has_previous = (getline previous_line < ARGV[1]) > 0
      split(previous_line, previous, " ")
      age = now - previous[1]
      if (has_previous && age >= 0 && age < window) { print "keep", previous[4]; exit }
      percent = "-"
      busy_delta = total - previous[2]
      if (has_previous && age >= 0 && busy_delta > 0)
        percent = sprintf("%d", (busy_delta - (idle - previous[3])) * 100 / busy_delta + 0.5)
      print "store", percent, now, total, idle
    }' "$file" 2>/dev/null)

  # "-" stands for no percent so word splitting keeps the fields in place
  set -- $result
  if [ "${1:-}" = store ]; then
    # Rename so a concurrent reader never sees half a file
    printf '%s %s %s %s\n' "$3" "$4" "$5" "$2" > "$file.$$" && mv "$file.$$" "$file"
  fi
  [ "${2:--}" = - ] || printf '%s' "$2"
}

case "$(oasis_platform)" in
  linux) used=$(linux_percent) ;;
  macos)
    # ps reports decayed per-process figures, but unlike top -l it returns at once
    used=$(ps -A -o %cpu= 2>/dev/null | awk -v cores="$(sysctl -n hw.ncpu 2>/dev/null)" '
      { sum += $1 }
      END { if (cores > 0 && NR > 0) { percent = sum / cores; printf "%d", (percent > 100 ? 100 : percent) + 0.5 } }')
    ;;
  *) exit 0 ;;
esac

oasis_report "${1:-}" "$used" "%" "$(oasis_option @oasis_cpu_warn 70)" "$(oasis_option @oasis_cpu_crit 90)"
