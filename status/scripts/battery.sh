#!/usr/bin/env bash
# Usage: battery.sh text|state
# Reads @oasis_battery_icons (five space-separated icons, empty to full),
# @oasis_battery_charging_icon, @oasis_battery_warn and @oasis_battery_crit.
# Both modes print nothing without a system battery (a desktop, or only a wireless mouse)
# and while fully charged.
# Runs on macOS's bash 3.2.
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

# Prints "PERCENT CHARGING" with CHARGING 1 or 0, or nothing when there is no system battery.
# The percent is the average over all system batteries weighted by capacity.
read_linux_battery() {
  local dir kind scope status now full charging=0 total_now=0 total_full=0 found=0 all_full=1
  for dir in "$OASIS_SYS_ROOT"/class/power_supply/*/; do
    [ -r "${dir}type" ] || continue
    read -r kind < "${dir}type"
    [ "$kind" = Battery ] || continue
    scope=""
    [ -r "${dir}scope" ] && read -r scope < "${dir}scope"
    [ "$scope" = Device ] && continue
    status=""
    [ -r "${dir}status" ] && read -r status < "${dir}status"
    now="" full=""
    if [ -r "${dir}energy_now" ] && [ -r "${dir}energy_full" ]; then
      read -r now < "${dir}energy_now"; read -r full < "${dir}energy_full"
    elif [ -r "${dir}charge_now" ] && [ -r "${dir}charge_full" ]; then
      read -r now < "${dir}charge_now"; read -r full < "${dir}charge_full"
    elif [ -r "${dir}capacity" ]; then
      read -r now < "${dir}capacity"; full=100
    fi
    case $now$full in *[!0-9]*|"") continue ;; esac
    [ "$full" -gt 0 ] || continue
    found=1
    total_now=$((total_now + now))
    total_full=$((total_full + full))
    [ "$status" = Charging ] && charging=1
    [ "$status" = Full ] || all_full=0
  done
  [ "$found" = 1 ] || return 0
  if [ "$all_full" = 1 ]; then printf '100 0'; return 0; fi
  printf '%s %s' $(( (total_now * 100 + total_full / 2) / total_full )) "$charging"
}

# OASIS_PMSET_OUTPUT stands in for `pmset -g batt` so tests need no Mac.
read_macos_battery() {
  local output=${OASIS_PMSET_OUTPUT-}
  [ -n "$output" ] || output=$(pmset -g batt 2>/dev/null)
  printf '%s\n' "$output" | awk -F';' '
    /[0-9]+%/ {
      match($1, /[0-9]+%/)
      total += substr($1, RSTART, RLENGTH - 1); count++
      if ($2 ~ /charging|finishing charge/ && $2 !~ /not charging|discharging/) charging = 1
      if ($2 ~ /charged/) charged++
    }
    END {
      if (!count) exit
      printf "%d %d", (charged == count) ? 100 : total / count + 0.5, charging
    }'
}

read_battery() {
  case "$(oasis_platform)" in
    linux) read_linux_battery ;;
    macos) read_macos_battery ;;
  esac
}

# Usage: read_unfinished_charge -- sets percent and charging; fails while there is nothing to show
read_unfinished_charge() {
  read -r percent charging <<< "$(read_battery)"
  [ -n "$percent" ] && [ "$percent" -lt 100 ]
}

battery_text() {
  local icons percent charging icon
  read_unfinished_charge || return 0
  if [ "$charging" = 1 ]; then
    icon=$(oasis_option @oasis_battery_charging_icon)
  else
    icons=$(oasis_option @oasis_battery_icons)
    set -- $icons
    if   [ "$percent" -le 20 ]; then icon=$1
    elif [ "$percent" -le 40 ]; then icon=$2
    elif [ "$percent" -le 60 ]; then icon=$3
    elif [ "$percent" -le 80 ]; then icon=$4
    else icon=$5
    fi
  fi
  printf '%s %s%%' "$icon" "$percent"
}

battery_state() {
  local percent charging warn crit
  read_unfinished_charge || return 0
  if [ "$charging" = 1 ]; then printf ok; return 0; fi
  warn=$(oasis_option @oasis_battery_warn 50)
  crit=$(oasis_option @oasis_battery_crit 20)
  oasis_level "$percent" "$warn" "$crit"
}

case "${1:-}" in
  text)  battery_text ;;
  state) battery_state ;;
esac
