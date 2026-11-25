#!/usr/bin/env bash
# Usage: uptime.sh text
# System uptime in two units: 3d 4h, 4h 12m, 12m. Prints nothing when unreadable.
# OASIS_NOW overrides the current time for the macOS path (tests only).
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

case "$(oasis_platform)" in
  linux)
    # "351735.47 1234567.89": whole seconds only
    read -r seconds _ 2>/dev/null < "$OASIS_PROC_ROOT/uptime"
    seconds=${seconds%%.*}
    ;;
  macos)
    # "{ sec = 1700000000, usec = 123 } Mon Nov 13 ..."
    boot=$(sysctl -n kern.boottime 2>/dev/null)
    [[ $boot =~ sec\ =\ ([0-9]+) ]] || exit 0
    boot=${BASH_REMATCH[1]}
    # date, not printf '%(%s)T': macOS ships bash 3.2
    now=${OASIS_NOW:-$(date +%s)}
    [[ $now =~ ^[0-9]+$ ]] || exit 0
    seconds=$(( now - boot ))
    ;;
  *) exit 0 ;;
esac
[[ ${seconds:-} =~ ^[0-9]+$ ]] || exit 0

days=$(( seconds / 86400 ))
hours=$(( seconds % 86400 / 3600 ))
minutes=$(( seconds % 3600 / 60 ))
if (( days > 0 )); then
  printf '%dd %dh' "$days" "$hours"
elif (( hours > 0 )); then
  printf '%dh %dm' "$hours" "$minutes"
else
  printf '%dm' "$minutes"
fi
