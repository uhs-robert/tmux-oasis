#!/usr/bin/env bash
# Usage: temp.sh text|state
# CPU temperature in whole degrees Celsius, warn and crit from @oasis_temp_warn and
# @oasis_temp_crit. Prints nothing (the module hides) on macOS, which has no sensor
# readable without root, and on hosts without a recognised CPU sensor.
# Runs on macOS's bash 3.2.
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

# Prints the sensor reading in millidegrees, or nothing. hwmon goes first: it is the
# only place AMD hosts (k10temp) expose the CPU, and thermal zones often hold only ACPI.
read_cpu_millidegrees() {
  local dir name millidegrees
  for dir in "$OASIS_SYS_ROOT"/class/hwmon/hwmon*/; do
    [ -r "${dir}name" ] || continue
    read -r name < "${dir}name"
    case $name in k10temp|coretemp|zenpower|cpu_thermal) ;; *) continue ;; esac
    millidegrees=""
    [ -r "${dir}temp1_input" ] && read -r millidegrees < "${dir}temp1_input"
    case $millidegrees in ""|*[!0-9]*) continue ;; esac
    printf '%s' "$millidegrees"; return 0
  done
  for dir in "$OASIS_SYS_ROOT"/class/thermal/thermal_zone*/; do
    [ -r "${dir}type" ] || continue
    read -r name < "${dir}type"
    case $name in x86_pkg_temp|cpu-thermal|cpu_thermal) ;; *) continue ;; esac
    millidegrees=""
    [ -r "${dir}temp" ] && read -r millidegrees < "${dir}temp"
    case $millidegrees in ""|*[!0-9]*) continue ;; esac
    printf '%s' "$millidegrees"; return 0
  done
}

degrees=""
if [ "$(oasis_platform)" = linux ]; then
  millidegrees=$(read_cpu_millidegrees)
  [ -n "$millidegrees" ] && degrees=$(( (millidegrees + 500) / 1000 ))
fi
oasis_report "${1:-}" "$degrees" $'\xc2\xb0C' temp 70 80
