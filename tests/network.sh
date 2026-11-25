# Cases for status/scripts/network.sh
. "$fixtures_dir/stubs.sh"
sys_root=$stub_data/sys
wireguard_dir=$stub_data/wireguard
proc_root=$stub_data/proc
mkdir -p "$sys_root/class/net" "$wireguard_dir" "$proc_root/net"

# Usage: add_interface NAME FLAGS [UEVENT_LINE]
add_interface() {
  mkdir -p "$sys_root/class/net/$1"
  printf '%s\n' "$2" > "$sys_root/class/net/$1/flags"
  printf 'INTERFACE=%s\n%s\n' "$1" "${3-}" > "$sys_root/class/net/$1/uevent"
}
reset() { rm -rf "$sys_root/class/net"/* "$wireguard_dir"/* "$stub_data"/{ip,route,ifconfig,ipconfig.*}; }
lan_route() { echo "1.1.1.1 via 192.168.1.1 dev wlan0 src 192.168.1.170 uid 1000" > "$stub_data/ip"; }
net() {
  run_script network text OASIS_UNAME=${uname_name:-Linux} OASIS_SYS_ROOT="$sys_root" OASIS_PROC_ROOT="$proc_root" OASIS_WIREGUARD_RUN_DIR="$wireguard_dir" \
    opt_oasis_network_icon="I " opt_oasis_network_vpn_icon=V "$@"
}

reset
assert_equals "no route hides" "" "$(net)"
lan_route
add_interface wlan0 0x1003
add_interface docker0 0x1003
assert_equals "address from the default route, not docker0" "I 192.168.1.170" "$(net)"
assert_equals "interface name on request" "I 192.168.1.170 wlan0" "$(net opt_oasis_network_show_interface=on)"
assert_equals "interface name off by default" "I 192.168.1.170" "$(net opt_oasis_network_show_interface=off)"

add_interface wg0 0x80d1 DEVTYPE=wireguard
assert_equals "wireguard up shows the marker" "I 192.168.1.170 V" "$(net)"
assert_equals "empty vpn icon turns the marker off" "I 192.168.1.170" "$(net opt_oasis_network_vpn_icon=)"
assert_equals "marker after the interface name" "I 192.168.1.170 wlan0 V" "$(net opt_oasis_network_show_interface=on)"
add_interface wg0 0x1002 DEVTYPE=wireguard
assert_equals "wireguard down has no marker" "I 192.168.1.170" "$(net)"
rm -rf "$sys_root/class/net/wg0"
add_interface home0 0x80d1 DEVTYPE=wireguard
assert_equals "wireguard by devtype under any name" "I 192.168.1.170 V" "$(net)"
rm -rf "$sys_root/class/net/home0"
add_interface tailscale0 0x1091
assert_equals "tailscale up flag without if_inet6 is trusted" "I 192.168.1.170 V" "$(net)"
cp "$fixtures_dir/linux/if_inet6_tailscale_down" "$proc_root/net/if_inet6"
assert_equals "tailscale0 up but without a global address (tailscale down)" "I 192.168.1.170" "$(net)"
cp "$fixtures_dir/linux/if_inet6_tailscale_up" "$proc_root/net/if_inet6"
assert_equals "tailscale up with its global address" "I 192.168.1.170 V" "$(net)"
add_interface tailscale0 0x1090
assert_equals "tailscale interface down" "I 192.168.1.170" "$(net)"
rm "$proc_root/net/if_inet6"
add_interface tun0 0x1091 DEVTYPE=tun
assert_equals "other tunnels are not VPNs" "I 192.168.1.170" "$(net)"

echo "1.1.1.1 dev tailscale0 src 100.64.0.5 uid 1000" > "$stub_data/ip"
assert_equals "full-tunnel VPN shows the tunnel address" "I 100.64.0.5" "$(net)"
assert_equals "# is doubled for tmux" "##I 192.168.1.170" "$(lan_route; net opt_oasis_network_icon='#I ')"
assert_equals "unsupported OS hides" "" "$(uname_name=FreeBSD net)"

# macOS
reset
uname_name=Darwin
assert_equals "mac without a route hides" "" "$(net)"
printf '   route to: default\ndestination: default\n       mask: default\n    gateway: 192.168.1.1\n  interface: en0\n' > "$stub_data/route"
assert_equals "mac route without an address hides" "" "$(net)"
echo 192.168.1.20 > "$stub_data/ipconfig.en0"
assert_equals "mac address" "I 192.168.1.20" "$(net)"
assert_equals "mac interface name" "I 192.168.1.20 en0" "$(net opt_oasis_network_show_interface=on)"
touch "$wireguard_dir/wg0.name"
assert_equals "mac wireguard file" "I 192.168.1.20 V" "$(net)"
rm "$wireguard_dir/wg0.name"
printf 'lo0: flags=8049<UP>\n\tinet 127.0.0.1 netmask 0xff000000\nutun4: flags=8051<UP>\n\tinet 100.101.2.3 --> 100.101.2.3 netmask 0xffffffff\n' > "$stub_data/ifconfig"
assert_equals "mac tailscale address range" "I 192.168.1.20 V" "$(net)"
printf 'en0: flags=8863<UP>\n\tinet 100.200.2.3 netmask 0xffffff00\n' > "$stub_data/ifconfig"
assert_equals "mac address outside 100.64.0.0/10 is no VPN" "I 192.168.1.20" "$(net)"
unset uname_name
