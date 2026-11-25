Notes for the next release. Each PR with a notable change adds a line here. The owner copies the section into the GitHub release and empties it.

## v2.4.0 (unreleased)

## ✨ New Features

- **User module**: shows the login of the tmux server owner. Add `user` next to `host` in a layout. Opt-in (#31)
- **Uptime module**: shows system uptime as `3d 4h`, `4h 12m` or `12m`. Opt-in (#32)
- **Application module**: shows the program in the active pane, hidden while it runs a shell. Opt-in (#33)
- **Kube module**: shows the current kubectl context and a non-default namespace, read from the kubeconfig without running kubectl. Opt-in (#34)
- **Temp module**: shows CPU temperature on Linux, warn at 70 °C and crit at 80 °C. Hidden on macOS and without a CPU sensor. Opt-in (#35)
- **Network module**: shows the main IPv4 address, with a lock while WireGuard or Tailscale is up. Opt-in (#36)
