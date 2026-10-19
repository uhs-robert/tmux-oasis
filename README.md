<p align="center">
  <img
    src="./assets/logo.png"
    width="auto" height="128" alt="logo" />
</p>
<hr/>
<p align="center">
  <a href="https://github.com/uhs-robert/tmux-oasis/stargazers"><img alt="GitHub stars" src="https://img.shields.io/github/stars/uhs-robert/tmux-oasis?colorA=192330&colorB=khaki&style=for-the-badge&cacheSeconds=4300"></a>
  <a href="https://github.com/uhs-robert/tmux-oasis/issues"><img alt="GitHub issues" src="https://img.shields.io/github/issues/uhs-robert/tmux-oasis?colorA=192330&colorB=skyblue&style=for-the-badge&cacheSeconds=4300"></a>
  <a href="https://github.com/uhs-robert/tmux-oasis/contributors"><img alt="GitHub contributors" src="https://img.shields.io/github/contributors/uhs-robert/tmux-oasis?colorA=192330&colorB=8FD1C7&style=for-the-badge&cacheSeconds=4300"></a>
  <a href="https://github.com/uhs-robert/tmux-oasis/network/members"><img alt="GitHub forks" src="https://img.shields.io/github/forks/uhs-robert/tmux-oasis?colorA=192330&colorB=CFA7FF&style=for-the-badge&cacheSeconds=4300"></a>
</p>
<p align="center">
A collection of <strong>16</strong> desert-inspired Tmux colorscheme status lines; with <strong>dual light/dark modes</strong>.
</p>

## 🎨 Status Bar with Dynamic Modes

Wouldn't it be nice to know what mode you're in? And not just one mode, but for **ALL modes like in Vim**.

Oasis provides a fully styled status line with a robust dynamic mode indicator for **ALL** of tmux's modes and **16 unique color schemes**.

<div align="center">

**Normal Mode**
<br>
<img src="./assets/screenshots/statusbar/mode-normal.png" alt="Normal Mode">

**Command Mode**
<br>
<img src="./assets/screenshots/statusbar/mode-command.png" alt="Command Mode">

**Copy Mode**
<br>
<img src="./assets/screenshots/statusbar/mode-copy.png" alt="Copy Mode">

**View Mode**
<br>
<img src="./assets/screenshots/statusbar/mode-view.png" alt="View Mode">

**Choose Mode**
<br>
<img src="./assets/screenshots/statusbar/mode-choose.png" alt="Choose Mode">

**Zoom Mode**
<br>
<img src="./assets/screenshots/statusbar/mode-zoom.png" alt="Zoom Mode">

**Options Mode**
<br>
<img src="./assets/screenshots/statusbar/mode-options.png" alt="Options Mode">

**Clock Mode**
<br>
<img src="./assets/screenshots/statusbar/mode-clock.png" alt="Clock Mode">

</div>

> [!NOTE]
> Previews above all use the `moonlight_dark` style with the default layout.

## 🌅 Overview

Choose from 16 distinct desert-inspired base styles, each with its own personality and color palette. Dual-mode themes now ship with one dark plus five fine-grained light variants.

<details>
<summary>✨ What's New / 🚨 Breaking Changes</summary>
<br/>
<!-- whats-new:start -->

  <details>
    <summary>✨ v2.2: Configurable Status Line Layout</summary>
    <!-- v2.2:start -->
    <h3>✨ Configurable layout</h3>
    Hide, regroup or reorder status line modules with <code>@oasis_status_left</code> and <code>@oasis_status_right</code>, pick a separator style with <code>@oasis_separator</code>, or add your own modules. See the <a href="#example-layouts">example layouts</a>.
    <h3>✨ Window separators</h3>
    Windows get their own caps with <code>@oasis_window_separator</code> (<code>round</code>, <code>powerline</code>, <code>slant</code> or <code>flat</code>, default <code>round</code>). Override single caps with <code>@oasis_window_separator_left</code> and <code>@oasis_window_separator_right</code>.
    <h3>✨ Module states</h3>
    A module can show a warn or crit state through <code>@oasis_module_&lt;name&gt;_state</code>, coloured by <code>@oasis_state_warn_color</code> and <code>@oasis_state_crit_color</code>.
    <h3>✨ New opt-in modules</h3>
    Not in the default layout; add them to <code>@oasis_status_left</code> or <code>@oasis_status_right</code>.
    <table>
      <tr><td><code>git</code></td><td>Branch of the active pane, marked while there are uncommitted changes</td></tr>
      <tr><td><code>battery</code></td><td>Battery level, hidden without a battery and while fully charged</td></tr>
      <tr><td><code>host</code></td><td>Short hostname, coloured by <code>@oasis_host_states</code></td></tr>
      <tr><td><code>ssh</code></td><td>Remote host while the active pane runs ssh</td></tr>
      <tr><td><code>load</code></td><td>1-minute load average</td></tr>
      <tr><td><code>ram</code></td><td>Used memory in percent</td></tr>
      <tr><td><code>cpu</code></td><td>CPU usage in percent</td></tr>
      <tr><td><code>disk</code></td><td>Used space of one filesystem (<code>@oasis_disk_path</code>)</td></tr>
    </table>
    See <a href="#config-options">all configuration options</a>.
    <h3>✨ Moonlight is the new default style</h3>
    To keep the previous look, set <code>@oasis_flavor "lagoon_dark"</code>.
    <h3>🚨 Restart tmux after updating</h3>
    Reloading your config in an already-running tmux shows doubled separators. Restart tmux once (<code>tmux kill-server</code>) to clear it.
    <blockquote>
    <strong>Note:</strong> If you overrode a built-in module such as <code>@oasis_module_clock</code>, it should now contain only its text. Separators and colours are added for you.
    </blockquote>
    <!-- v2.2:end -->
  </details>

  <details>
    <summary>🚨 v2.0: Dual Style Themes / Deprecated Themes</summary>
    <!-- v4:start -->
    <h3>✨ Dual Style Themes</h3>
    Each style now has <strong>5 light theme variants</strong>.
    <ul>
      <li>Check out the <a href="#%EF%B8%8F-light-styles">new light theme screenshots</a>.</li>
    </ul>
    <h3>🚨 BREAKING CHANGE: Deprecated Light Theme Migration</h3>
    The following standalone <strong>light themes have been deprecated</strong> in favor of the dual-mode system:
    <table>
      <tr>
        <td>Dawn</td>
        <td>Replaced with <code>night_light_1</code></td>
      </tr>
      <tr>
        <td>Dawnlight</td>
        <td>Replaced with <code>night_light_2</code></td>
      </tr>
      <tr>
        <td>Day</td>
        <td>Replaced with <code>night_light_3</code></td>
      </tr>
      <tr>
        <td>Dusk</td>
        <td>Replaced with <code>night_light_4</code></td>
      </tr>
      <tr>
        <td>Dust</td>
        <td>Replaced with <code>night_light_5</code></td>
      </tr>
    </table>
    <blockquote>
    <strong>Note:</strong> The migration table above shows direct replacements. All deprecated themes were based on the <code>night</code> style family.
    </blockquote>
    <br/>
    <!-- v4:end -->
  </details>
<!-- whats-new:end -->
</details>

## 🌙 Dark Styles

Click any card below to view the full preview and syntax sample. [↓ Or click here to view all full previews](#view-all-theme-styles)

### Dark Previews

<table>
  <tr>
    <td align="center"><a href="#night-dark"><img src="assets/screenshots/night-dark-dashboard.png" alt="Night (dark)" width="auto"></a><br><strong>Night</strong><br><em>Desert Night</em></td>
    <td align="center"><a href="#moonlight-dark"><img src="assets/screenshots/moonlight-dark-dashboard.png" alt="Moonlight (dark)" width="auto"></a><br><strong>Moonlight (Default)</strong><br><em>Moonlit Night</em></td>
    <td align="center"><a href="#midnight-dark"><img src="assets/screenshots/midnight-dark-dashboard.png" alt="Midnight (dark)" width="auto"></a><br><strong>Midnight</strong><br><em>Dark Desert</em></td>
    <td align="center"><a href="#abyss-dark"><img src="assets/screenshots/abyss-dark-dashboard.png" alt="Abyss (dark)" width="auto"></a><br><strong>Abyss</strong><br><em>Black Desert</em></td>
  </tr>
  <tr>
    <td align="center"><a href="#starlight-dark"><img src="assets/screenshots/starlight-dark-dashboard.png" alt="Starlight (dark)" width="auto"></a><br><strong>Starlight</strong><br><em>Black Lagoon</em></td>
    <td align="center"><a href="#desert-dark"><img src="assets/screenshots/desert-dark-dashboard.png" alt="Desert (dark)" width="auto"></a><br><strong>Desert</strong><br><em>Grey</em></td>
    <td align="center"><a href="#sol-dark"><img src="assets/screenshots/sol-dark-dashboard.png" alt="Sol (dark)" width="auto"></a><br><strong>Sol</strong><br><em>Red</em></td>
    <td align="center"><a href="#scorpion-dark"><img src="assets/screenshots/scorpion-dark-dashboard.png" alt="Desert (dark)" width="auto"></a><br><strong>Scorpion</strong><br><em>Scorched</em></td>
  </tr>
  <tr>
    <td align="center"><a href="#canyon-dark"><img src="assets/screenshots/canyon-dark-dashboard.png" alt="Canyon (dark)" width="auto"></a><br><strong>Canyon</strong><br><em>Orange</em></td>
    <td align="center"><a href="#dune-dark"><img src="assets/screenshots/dune-dark-dashboard.png" alt="Dune (dark)" width="auto"></a><br><strong>Dune</strong><br><em>Yellow</em></td>
    <td align="center"><a href="#cactus-dark"><img src="assets/screenshots/cactus-dark-dashboard.png" alt="Cactus (dark)" width="auto"></a><br><strong>Cactus</strong><br><em>Green</em></td>
    <td align="center"><a href="#mirage-dark"><img src="assets/screenshots/mirage-dark-dashboard.png" alt="Mirage (dark)" width="auto"></a><br><strong>Mirage</strong><br><em>Teal</em></td>
  </tr>
  <tr>
    <td align="center"><a href="#lagoon-dark"><img src="assets/screenshots/lagoon-dark-dashboard.png" alt="Lagoon (dark)" width="auto"></a><br><strong>Lagoon</strong><br><em>Blue</em></td>
    <td align="center"><a href="#luna-dark"><img src="assets/screenshots/luna-dark-dashboard.png" alt="Luna (dark)" width="auto"></a><br><strong>Luna</strong><br><em>Indigo</em></td>
    <td align="center"><a href="#twilight-dark"><img src="assets/screenshots/twilight-dark-dashboard.png" alt="Twilight (dark)" width="auto"></a><br><strong>Twilight</strong><br><em>Sunset</em></td>
    <td align="center"><a href="#rose-dark"><img src="assets/screenshots/rose-dark-dashboard.png" alt="Rose (dark)" width="auto"></a><br><strong>Rose</strong><br><em>Pink</em></td>
  </tr>
</table>

## ☀️ Light Styles

### Light Previews

The examples below use the light style 3.

<table>
  <tr>
    <td align="center"><a href="#night-light"><img src="assets/screenshots/night-light-3-dashboard.png" alt="Night (light)" width="auto"></a><br><strong>Night</strong></td>
    <td align="center"><a href="#moonlight-light"><img src="assets/screenshots/moonlight-light-3-dashboard.png" alt="Moonlight (light)" width="auto"></a><br><strong>Moonlight</strong></td>
    <td align="center"><a href="#midnight-light"><img src="assets/screenshots/midnight-light-3-dashboard.png" alt="Midnight (light)" width="auto"></a><br><strong>Midnight</strong></td>
    <td align="center"><a href="#abyss-light"><img src="assets/screenshots/abyss-light-3-dashboard.png" alt="Abyss (light)" width="auto"></a><br><strong>Abyss</strong></td>
  </tr>
  <tr>
    <td align="center"><a href="#starlight-light"><img src="assets/screenshots/starlight-light-3-dashboard.png" alt="Starlight (light)" width="auto"></a><br><strong>Starlight</strong></td>
    <td align="center"><a href="#desert-light"><img src="assets/screenshots/desert-light-3-dashboard.png" alt="Desert (light)" width="auto"></a><br><strong>Desert</strong></td>
    <td align="center"><a href="#sol-light"><img src="assets/screenshots/sol-light-3-dashboard.png" alt="Sol (light)" width="auto"></a><br><strong>Sol</strong></td>
    <td align="center"><a href="#scorpion-light"><img src="assets/screenshots/scorpion-light-3-dashboard.png" alt="Desert (dark)" width="auto"></a><br><strong>Scorpion</strong></td>
  </tr>
  <tr>
    <td align="center"><a href="#canyon-light"><img src="assets/screenshots/canyon-light-3-dashboard.png" alt="Canyon (light)" width="auto"></a><br><strong>Canyon</strong></td>
    <td align="center"><a href="#dune-light"><img src="assets/screenshots/dune-light-3-dashboard.png" alt="Dune (light)" width="auto"></a><br><strong>Dune</strong></td>
    <td align="center"><a href="#cactus-light"><img src="assets/screenshots/cactus-light-3-dashboard.png" alt="Cactus (light)" width="auto"></a><br><strong>Cactus</strong></td>
    <td align="center"><a href="#mirage-light"><img src="assets/screenshots/mirage-light-3-dashboard.png" alt="Mirage (light)" width="auto"></a><br><strong>Mirage</strong></td>
  </tr>
  <tr>
    <td align="center"><a href="#lagoon-light"><img src="assets/screenshots/lagoon-light-3-dashboard.png" alt="Lagoon (light)" width="auto"></a><br><strong>Lagoon</strong></td>
    <td align="center"><a href="#luna-light"><img src="assets/screenshots/luna-light-3-dashboard.png" alt="Luna (dark)" width="auto"></a><br><strong>Luna</strong></td>
    <td align="center"><a href="#twilight-light"><img src="assets/screenshots/twilight-light-3-dashboard.png" alt="Twilight (light)" width="auto"></a><br><strong>Twilight</strong></td>
    <td align="center"><a href="#rose-light"><img src="assets/screenshots/rose-light-3-dashboard.png" alt="Rose (light)" width="auto"></a><br><strong>Rose</strong></td>
  </tr>
</table>

## ✨ Features

- **Advanced status line** with dynamic mode indicators based on `vim` for each of tmux's modes.
  - Includes: `NORMAL`, `COMMAND`, `COPY`, `VIEW`, `CHOOSE`, `CLOCK`, `OPTIONS`, and `ZOOM` modes.
  - **Customizable mode formats**: Set `@oasis_mode_format` to `short` (single letter), `full` (complete word), `icon` (Nerd Font icons), or `custom` (user-defined labels)
- **16 base styles** with granular variants: dual-mode themes provide 1 dark + 5 light levels
- **Automatic theme loading**, set `@oasis_flavor` and the system will handle the rest (suffixes added for you)
- **Modular design** with separate theme and status line module configurations (_download **only** what you need_)
- **Configurable status line layout**: hide, regroup or reorder modules, pick a separator style, or add your own modules
- **Standalone** with zero dependencies on any other plugins

## 📦 Installation

For customization options, please see [all configuration options](#config-options).

### Method 1: Tmux Plugin Manager (TPM) - Recommended

Add to your `tmux.conf`:

```tmux
set -g @plugin 'uhs-robert/tmux-oasis'
set -g @oasis_flavor "moonlight_dark"  # Optional: defaults to moonlight_dark
```

Install with TPM: `prefix + I`

### Method 2: Manual Installation

Clone this repository:

```bash
git clone https://github.com/uhs-robert/tmux-oasis ~/.tmux/themes/oasis
```

In your `tmux.conf`, set your preferred theme style:

```tmux
set -g @oasis_flavor "moonlight_dark"
```

Source the main configuration:

```tmux
source-file "~/.tmux/themes/oasis/oasis_tmux.conf"
```

Reload tmux: `tmux source ~/.tmux.conf`

## ⚙️ Configuration

Oasis offers _many_ different styles to choose from. First, pick a theme!

- **Dual-mode themes**: `abyss`, `cactus`, `canyon`, `desert`, `dune`, `lagoon`, `luna`, `mirage`, `midnight`, `night`, `rose`, `scorpion`, `sol`, `starlight`, `twilight`
  - Variants: `_dark` and `_light_1` … `_light_5`
  - Short names auto-expand to dark: setting `set -g @oasis_flavor "lagoon"` loads `lagoon_dark`

Examples:

```tmux
set -g @oasis_flavor "canyon_light_3"   # For light variant 3
set -g @oasis_flavor "night"            # Resolves to night_dark
```

Then set up any additional configuration options for more customization!

<a id="example-layouts"></a>

### Example layouts

Each side is a list of groups separated by `|`; see the configuration block below for all modules.

```tmux
# Desktop
set -g @oasis_status_right "sync | folder git"

# Laptop
set -g @oasis_status_right "sync | folder git | cpu ram battery"

# Server
set -g @oasis_status_left "mode | host session"
set -g @oasis_status_right "ssh sync | folder git | load ram disk"
```

<a id="config-options"></a>

<details>
  <summary>🍦 Configuration Options & Defaults</summary>
  <br>
<!-- config:start -->

All options below show their default values. Add any of these to your `tmux.conf` to override:

```tmux
# Theme variant (16 base styles × 6 variants each)
# Options: [style]_dark, [style]_light_1, [style]_light_2, [style]_light_3, [style]_light_4, [style]_light_5
# Styles: "night", "moonlight", "midnight", "abyss", "starlight", "desert", "sol", "canyon", "dune", "cactus", "mirage", "lagoon", "luna", "twilight", "rose"
set -g @oasis_flavor "moonlight_dark"

# Mode indicator display format
# Options: "short" (N, C, V), "full" (NORMAL, COPY, VIEW), "icon" (Nerd Font icons), "custom" (see below)
set -g @oasis_mode_format "full"

# Custom mode labels (only used when @oasis_mode_format is "custom")
set -g @oasis_mode_custom_normal "NORMAL"
set -g @oasis_mode_custom_command "COMMAND"
set -g @oasis_mode_custom_copy "COPY"
set -g @oasis_mode_custom_view "VIEW"
set -g @oasis_mode_custom_choose "CHOOSE"
set -g @oasis_mode_custom_options "OPTIONS"
set -g @oasis_mode_custom_clock "CLOCK"
set -g @oasis_mode_custom_zoom "ZOOM"

# Status line layout
# "|" separates groups, spaces separate modules in the same group. Each side has at
# most two groups: accent at the screen edge, surface inside it. Extra groups are
# merged into the inner one, with a warning at load.
# Remove a module or group to hide it; an empty string hides the whole side.
# Modules: mode, session, sync, folder, clock, load, ram, cpu, disk, host, ssh, git, battery (or your own, see below)
# git and battery are not in the default layout; add them to try them, e.g. "git battery | clock"
set -g @oasis_status_left "mode | session"
set -g @oasis_status_right "sync folder | clock"

# Separators between groups: "powerline", "round", "slant" or "flat"
set -g @oasis_separator "powerline"
set -g @oasis_separator_left ""    # Optional glyph override for the left side
set -g @oasis_separator_right ""   # Optional glyph override for the right side
set -g @oasis_separator_module " " # Placed between modules in the same group

# Caps around each window in the window list: "round", "powerline", "slant" or "flat"
set -g @oasis_window_separator "round"
set -g @oasis_window_separator_left ""  # Optional glyph override for the left cap
set -g @oasis_window_separator_right "" # Optional glyph override for the right cap

# Custom modules: define @oasis_module_<name> as a tmux format, then use <name> in a layout.
# @oasis_module_<name>_when optionally hides it while the format is false.
# set -g @oasis_module_host "#H"
# set -g @oasis_module_host_when "#{!=:#{client_session},main}"

# Module states: @oasis_module_<name>_state is a format that evaluates to "ok", "warn" or "crit"
# (empty or anything else means "ok"; "ok" adds no colour). In a surface group, warn/crit
# colour that module's icon and text. In an accent group, the whole group turns the warn/crit
# colour (crit wins over warn) while a stateful module in it is shown, so a module's
# _when hiding it also clears its state.
set -g @oasis_state_warn_color "#{@thm_yellow}"
set -g @oasis_state_crit_color "#{@thm_red}"
# Example (Linux): your own module, red above a load of 4
# set -g @oasis_module_busy "#(cut -d' ' -f1 /proc/loadavg)"
# set -g @oasis_module_busy_state "#{?#(awk '$1 > 4' /proc/loadavg),crit,ok}"
# set -g @oasis_status_right "busy folder | clock"
# The built-in load, ram, cpu and disk modules already do this: "load ram cpu disk | clock"

# Where Oasis keeps the scripts its modules call, as #(bash "#{@oasis_scripts_dir}/<name>.sh").
# Oasis sets this to its own status/scripts directory when it loads; don't change it.
# set -g @oasis_scripts_dir "<oasis checkout>/status/scripts"

# Clock module settings
set -g @oasis_clock_24h "on"      # "on" for 24-hour format, "off" for 12-hour AM/PM
set -g @oasis_clock_icon "󰥔 "     # Icon/text shown before time

# Folder/directory module settings
set -g @oasis_folder_icon " "    # Icon/text shown before directory path

# Host module settings (opt-in: add "host" to a layout)
set -g @oasis_host_icon "󰒋 "  # Icon/text shown before the short hostname
set -g @oasis_host_states ""          # Space-separated glob=state pairs, e.g. "prod-*=crit staging-*=warn"; first match wins, no match is ok

# SSH module settings (opt-in: add "ssh" to a layout). Shows the remote host while the active pane runs ssh
set -g @oasis_ssh_icon "󰣀 "   # Icon/text shown before the remote host

# Session module settings
set -g @oasis_session_icon "󰍹 "  # Icon/text shown before session name

# Load module settings (not in the default layout): 1-minute load average, e.g. 1.23
# warn and crit are multiples of the core count; a state shows from there up
set -g @oasis_load_icon "󰊚 "  # Icon/text shown before the load
set -g @oasis_load_warn "0.7"       # Warn at 0.7 x cores
set -g @oasis_load_crit "1.0"       # Crit at 1.0 x cores

# RAM module settings (not in the default layout): used memory, excluding reclaimable cache
set -g @oasis_ram_icon " "    # Icon/text shown before the percentage
set -g @oasis_ram_warn "80"         # Warn at this percent or more
set -g @oasis_ram_crit "90"         # Crit at this percent or more

# CPU module settings (not in the default layout): usage since the previous refresh,
# so it shows nothing until the second refresh
set -g @oasis_cpu_icon " "    # Icon/text shown before the percentage
set -g @oasis_cpu_warn "70"         # Warn at this percent or more
set -g @oasis_cpu_crit "90"         # Crit at this percent or more

# Disk module settings (not in the default layout): used space of one filesystem
# On macOS "/" is read as /System/Volumes/Data, where your files are
set -g @oasis_disk_icon "󰋊 " # Icon/text shown before the percentage
set -g @oasis_disk_path "/"         # Any path on the filesystem to watch
set -g @oasis_disk_warn "80"        # Warn at this percent or more
set -g @oasis_disk_crit "90"        # Crit at this percent or more
# Git module settings (hidden outside a repository)
set -g @oasis_git_icon ""        # Icon/text shown before the branch
set -g @oasis_git_dirty_icon "*"   # Appended while tracked files have uncommitted changes

# Battery module settings (hidden without a laptop battery and while fully charged)
set -g @oasis_battery_icons "    "  # Five icons, empty to full, separated by spaces
set -g @oasis_battery_charging_icon ""  # Shown instead of the level icon while charging
set -g @oasis_battery_warn "50"    # warn state at or below this percent (not while charging)
set -g @oasis_battery_crit "20"    # crit state at or below this percent (not while charging)

# Pane settings
set -g @oasis_dim_inactive "on"   # "on" darkens unfocused panes, "off" keeps the terminal background
```

<!-- config:end -->
</details>

## ⚙️ (Devs) Creating New Theme Styles

1. Dark variant: Create `themes/dark/oasis_<name>_dark.conf`
2. Light variants: Create `themes/light/[1-5]/oasis_<name>_light_[1-5].conf` (5 brightness levels)
3. Define all the `@thm_*` color variables in each variant file
4. Set `@oasis_flavor` to your new variant to test it

> [!TIP]
> Dual-mode themes should ship with one `_dark` and five `_light_[1-5]` files for consistent UX.

To try changes in an isolated tmux server, compare the status bar against `main` or take a screenshot, see the dev recipes in `just --list`.

# 👀 View All Theme Styles

> All screenshots below show how the theme looks [with the companion theme in neovim](https://github.com/uhs-robert/oasis.nvim)

> [!IMPORTANT]
> The status line at the top is the TMUX plugin integration.

<a id="view-all-theme-styles"></a>

<details open>
  <summary><b>All styles (click to collapse)</b></summary>
  <br/>
  <!-- all-styles:start -->
  <a id="dark-previews"></a>
  <details open>
    <summary><b>🌕️ Dark Previews</b></summary>
    <!-- dark-styles:start -->
    <a id="night-dark"></a>
    <h3>Night (Dark · Desert Night)</h3>
    <img src="./assets/screenshots/night-dark-dashboard.png" alt="Night dark mode dashboard"></img>
    <p align="center">
      <a href="#dark-previews">↑ Back to Dark Styles</a>
    </p>
    <a id="moonlight-dark"></a>
    <h3>Moonlight (Dark · Moonlit Night · Default)</h3>
    <img src="./assets/screenshots/moonlight-dark-dashboard.png" alt="Moonlight dark mode dashboard"></img>
    <p align="center">
      <a href="#dark-previews">↑ Back to Dark Styles</a>
    </p>
    <a id="midnight-dark"></a>
    <h3>Midnight (Dark · Off Black)</h3>
    <img src="./assets/screenshots/midnight-dark-dashboard.png" alt="Midnight dark mode dashboard"></img>
    <p align="center">
      <a href="#dark-previews">↑ Back to Dark Styles</a>
    </p>
    <a id="abyss-dark"></a>
    <h3>Abyss (Dark · Black)</h3>
    <img src="./assets/screenshots/abyss-dark-dashboard.png" alt="Abyss dark mode dashboard"></img>
    <p align="center">
      <a href="#dark-previews">↑ Back to Dark Styles</a>
    </p>
    <a id="starlight-dark"></a>
    <h3>Starlight (Dark · Black Vivid)</h3>
    <img src="./assets/screenshots/starlight-dark-dashboard.png" alt="Starlight dark mode dashboard"></img>
    <p align="center">
      <a href="#dark-previews">↑ Back to Dark Styles</a>
    </p>
    <a id="desert-dark"></a>
    <h3>Desert (Dark · Grey)</h3>
    <img src="./assets/screenshots/desert-dark-dashboard.png" alt="Desert dark mode dashboard"></img>
    <p align="center">
      <a href="#dark-previews">↑ Back to Dark Styles</a>
    </p>
    <a id="sol-dark"></a>
    <h3>Sol (Dark · Red)</h3>
    <img src="./assets/screenshots/sol-dark-dashboard.png" alt="Sol dark mode dashboard"></img>
    <p align="center">
      <a href="#dark-previews">↑ Back to Dark Styles</a>
    </p>
    <a id="scorpion-dark"></a>
    <h3>Scorpion (Dark · Scorched)</h3>
    <img src="./assets/screenshots/scorpion-dark-dashboard.png" alt="Scorpion dark mode dashboard"></img>
    <p align="center">
      <a href="#dark-previews">↑ Back to Dark Styles</a>
    </p>
    <a id="canyon-dark"></a>
    <h3>Canyon (Dark · Orange)</h3>
    <img src="./assets/screenshots/canyon-dark-dashboard.png" alt="Canyon dark mode dashboard"></img>
    <p align="center">
      <a href="#dark-previews">↑ Back to Dark Styles</a>
    </p>
    <a id="dune-dark"></a>
    <h3>Dune (Dark · Yellow)</h3>
    <img src="./assets/screenshots/dune-dark-dashboard.png" alt="Dune dark mode dashboard"></img>
    <p align="center">
      <a href="#dark-previews">↑ Back to Dark Styles</a>
    </p>
    <a id="cactus-dark"></a>
    <h3>Cactus (Dark · Green)</h3>
    <img src="./assets/screenshots/cactus-dark-dashboard.png" alt="Cactus dark mode dashboard"></img>
    <p align="center">
      <a href="#dark-previews">↑ Back to Dark Styles</a>
    </p>
    <a id="mirage-dark"></a>
    <h3>Mirage (Dark · Teal)</h3>
    <img src="./assets/screenshots/mirage-dark-dashboard.png" alt="Mirage dark mode dashboard"></img>
    <p align="center">
      <a href="#dark-previews">↑ Back to Dark Styles</a>
    </p>
    <a id="lagoon-dark"></a>
    <h3>Lagoon (Dark · Blue)</h3>
    <img src="./assets/screenshots/lagoon-dark-dashboard.png" alt="Lagoon dark mode dashboard"></img>
    <p align="center">
      <a href="#dark-previews">↑ Back to Dark Styles</a>
    </p>
    <a id="luna-dark"></a>
    <h3>Luna (Dark · Indigo)</h3>
    <img src="./assets/screenshots/luna-dark-dashboard.png" alt="Luna dark mode dashboard"></img>
    <p align="center">
      <a href="#dark-previews">↑ Back to dark Styles</a>
    </p>
    <a id="twilight-dark"></a>
    <h3>Twilight (Dark · Sunset)</h3>
    <img src="./assets/screenshots/twilight-dark-dashboard.png" alt="Twilight dark mode dashboard"></img>
    <p align="center">
      <a href="#dark-previews">↑ Back to Dark Styles</a>
    </p>
    <a id="rose-dark"></a>
    <h3>Rose (Dark · Pink)</h3>
    <img src="./assets/screenshots/rose-dark-dashboard.png" alt="Rose dark mode dashboard"></img>
    <p align="center">
      <a href="#dark-previews">↑ Back to Dark Styles</a>
    </p>
    <!-- dark-styles:end -->
</details>
  <details open>
  <summary><b>🌞 Light Previews</b></summary>
  <!-- light-styles:start -->
  <a id="light-previews"></a>
    <a id="night-light"></a>
    <h3>Night (Light)</h3>
    <img src="./assets/screenshots/night-light-3-dashboard.png" alt="Night light mode dashboard"></img>
    <p align="center">
      <a href="#light-previews">↑ Back to Light Styles</a>
    </p>
    <a id="moonlight-light"></a>
    <h3>Moonlight (Light)</h3>
    <img src="./assets/screenshots/moonlight-light-3-dashboard.png" alt="Moonlight light mode dashboard"></img>
    <p align="center">
      <a href="#light-previews">↑ Back to Light Styles</a>
    </p>
    <a id="midnight-light"></a>
    <h3>Midnight (Light)</h3>
    <img src="./assets/screenshots/midnight-light-3-dashboard.png" alt="Midnight light mode dashboard"></img>
    <p align="center">
      <a href="#light-previews">↑ Back to Light Styles</a>
    </p>
    <a id="abyss-light"></a>
    <h3>Abyss (Light)</h3>
    <img src="./assets/screenshots/abyss-light-3-dashboard.png" alt="Abyss light mode dashboard"></img>
    <p align="center">
      <a href="#light-previews">↑ Back to Light Styles</a>
    </p>
    <a id="starlight-light"></a>
    <h3>Starlight (Light)</h3>
    <img src="./assets/screenshots/starlight-light-3-dashboard.png" alt="Starlight light mode dashboard"></img>
    <p align="center">
      <a href="#light-previews">↑ Back to Light Styles</a>
    </p>
    <a id="desert-light"></a>
    <h3>Desert (Light)</h3>
    <img src="./assets/screenshots/desert-light-3-dashboard.png" alt="Desert light mode dashboard"></img>
    <p align="center">
      <a href="#light-previews">↑ Back to Light Styles</a>
    </p>
    <a id="sol-light"></a>
    <h3>Sol (Light)</h3>
    <img src="./assets/screenshots/sol-light-3-dashboard.png" alt="Sol light mode dashboard"></img>
    <p align="center">
      <a href="#light-previews">↑ Back to Light Styles</a>
    </p>
    <a id="scorpion-light"></a>
    <h3>Scorpion (Light · Scorched)</h3>
    <img src="./assets/screenshots/scorpion-light-3-dashboard.png" alt="Scorpion light mode dashboard"></img>
    <p align="center">
      <a href="#light-previews">↑ Back to light Styles</a>
    </p>
    <a id="canyon-light"></a>
    <h3>Canyon (Light)</h3>
    <img src="./assets/screenshots/canyon-light-3-dashboard.png" alt="Canyon light mode dashboard"></img>
    <p align="center">
      <a href="#light-previews">↑ Back to Light Styles</a>
    </p>
    <a id="dune-light"></a>
    <h3>Dune (Light)</h3>
    <img src="./assets/screenshots/dune-light-3-dashboard.png" alt="Dune light mode dashboard"></img>
    <p align="center">
      <a href="#light-previews">↑ Back to Light Styles</a>
    </p>
    <a id="cactus-light"></a>
    <h3>Cactus (Light)</h3>
    <img src="./assets/screenshots/cactus-light-3-dashboard.png" alt="Cactus light mode dashboard"></img>
    <p align="center">
      <a href="#light-previews">↑ Back to Light Styles</a>
    </p>
    <a id="mirage-light"></a>
    <h3>Mirage (Light)</h3>
    <img src="./assets/screenshots/mirage-light-3-dashboard.png" alt="Mirage light mode dashboard"></img>
    <p align="center">
      <a href="#light-previews">↑ Back to Light Styles</a>
    </p>
    <a id="lagoon-light"></a>
    <h3>Lagoon (Light)</h3>
    <img src="./assets/screenshots/lagoon-light-3-dashboard.png" alt="Lagoon light mode dashboard"></img>
    <p align="center">
      <a href="#light-previews">↑ Back to Light Styles</a>
    </p>
    <a id="luna-light"></a>
    <h3>Luna (Light)</h3>
    <img src="./assets/screenshots/luna-light-3-dashboard.png" alt="Luna light mode dashboard"></img>
    <p align="center">
      <a href="#light-previews">↑ Back to Light Styles</a>
    </p>
    <a id="twilight-light"></a>
    <h3>Twilight (Light)</h3>
    <img src="./assets/screenshots/twilight-light-3-dashboard.png" alt="Twilight light mode dashboard"></img>
    <p align="center">
      <a href="#light-previews">↑ Back to Light Styles</a>
    </p>
    <a id="rose-light"></a>
    <h3>Rose (Light)</h3>
    <img src="./assets/screenshots/rose-light-3-dashboard.png" alt="Rose light mode dashboard"></img>
    <p align="center">
      <a href="#light-previews">↑ Back to Light Styles</a>
    </p>
  <!-- light-styles:end -->
  </details>
  <!-- all-styles:end -->
</details>
