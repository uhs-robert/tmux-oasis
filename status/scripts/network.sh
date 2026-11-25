#!/usr/bin/env bash
# Usage: network.sh text   the main IPv4 address, then a VPN marker while a WireGuard or Tailscale interface is up
# Prints nothing without an address. Offline: only the local routing table is read, no packet is sent.
set -u
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

# The interface and address the default route would use, as two words: "wlan0 192.168.1.170".
# Taken from the route rather than the interface list so docker bridges and tunnels do not win.
linux_main_address() {
  local out word previous='' interface='' address=''
  # 1.1.1.1 only selects the route; `ip route get` sends nothing
  out=$(ip -4 route get 1.1.1.1 2>/dev/null) || return 0
  for word in $out; do
    case $previous in
      dev) interface=$word ;;
      src) address=$word ;;
    esac
    previous=$word
  done
  [ -n "$address" ] && printf '%s %s' "$interface" "$address"
}

# An interface is a VPN when it is up and is a WireGuard device or named tailscale*.
# operstate reads "unknown" for both, so the up flag (bit 0x1) is used.
linux_vpn_up() {
  local dir name flags line
  for dir in "$OASIS_SYS_ROOT"/class/net/*/; do
    [ -d "$dir" ] || continue
    name=$(basename "$dir")
    flags=
    read -r flags < "$dir/flags" 2>/dev/null
    [ -n "$flags" ] && [ $(( flags & 1 )) -eq 1 ] || continue
    case $name in tailscale*) return 0 ;; esac
    while read -r line; do
      [ "$line" = DEVTYPE=wireguard ] && return 0
    done < "$dir/uevent" 2>/dev/null
  done
  return 1
}

macos_main_address() {
  local interface address
  interface=$(route -n get default 2>/dev/null | awk '$1 == "interface:" { print $2; exit }')
  [ -n "$interface" ] || return 0
  address=$(ipconfig getifaddr "$interface" 2>/dev/null)
  [ -n "$address" ] && printf '%s %s' "$interface" "$address"
}

# wg-quick on macOS leaves a NAME.name file per tunnel; Tailscale has no fixed
# interface name, so it is the utun carrying an address in 100.64.0.0/10. ifconfig only runs when no WireGuard file matched.
macos_vpn_up() {
  local file line
  for file in "${OASIS_WIREGUARD_RUN_DIR:-/var/run/wireguard}"/*.name; do
    [ -e "$file" ] && return 0
  done
  while read -r line; do
    case $line in
      'inet 100.6'[4-9].*|'inet 100.'[7-9][0-9].*|'inet 100.1'[01][0-9].*|'inet 100.12'[0-7].*) return 0 ;;
    esac
  done < <(ifconfig 2>/dev/null)
  return 1
}

text() {
  local platform main interface address vpn_icon show_interface
  platform=$(oasis_platform)
  case $platform in
    linux|macos) main=$("${platform}_main_address") ;;
    *) return 0 ;;
  esac
  [ -n "$main" ] || return 0
  interface=${main%% *}
  address=${main#* }

  local out
  out="$(oasis_option @oasis_network_icon)$address"
  show_interface=$(oasis_option @oasis_network_show_interface off)
  [ "$show_interface" = on ] && [ -n "$interface" ] && out="$out $interface"
  vpn_icon=$(oasis_option @oasis_network_vpn_icon)
  if [ -n "$vpn_icon" ] && "${platform}_vpn_up"; then
    out="$out $vpn_icon"
  fi
  # tmux format-expands #() output
  printf '%s' "${out//#/##}"
}

case ${1:-} in
  text) text ;;
esac
