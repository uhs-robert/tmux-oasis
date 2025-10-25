<p align="center">
  <img
    src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/svg/1f3dd.svg"
    width="128" height="128" alt="Oasis emoji" />
</p>
<h1 align="center">Tmux Oasis</h1>

<p align="center">
  <a href="https://github.com/uhs-robert/tmux-oasis/stargazers"><img src="https://img.shields.io/github/stars/uhs-robert/tmux-oasis?colorA=192330&colorB=skyblue&style=for-the-badge"></a>
  <a href="https://github.com/uhs-robert/tmux-oasis/issues"><img src="https://img.shields.io/github/issues/uhs-robert/tmux-oasis?colorA=192330&colorB=khaki&style=for-the-badge"></a>
  <a href="https://github.com/uhs-robert/tmux-oasis/contributors"><img src="https://img.shields.io/github/contributors/uhs-robert/tmux-oasis?colorA=192330&colorB=8FD1C7&style=for-the-badge"></a>
  <a href="https://github.com/uhs-robert/tmux-oasis/network/members"><img src="https://img.shields.io/github/forks/uhs-robert/tmux-oasis?colorA=192330&colorB=CFA7FF&style=for-the-badge"></a>
</p>

<p align="center">
A collection of <strong>14</strong> desert-inspired Tmux colorscheme status lines; warm, readable, and configurable.
</p>

## Status Bar with Dynamic Modes

Wouldn't it be nice to know what mode you're in? And not just one mode, but for **ALL modes like in Vim**.

Oasis provides a fully styled status line with a robust dynamic mode indicator for **ALL** of tmux's modes and **14 unique color schemes**.

<div align="center">

**Normal Mode**
<br>
<img src="assets/screenshots/statusbar/mode-normal.webp" alt="Normal Mode">

**Command Mode**
<br>
<img src="assets/screenshots/statusbar/mode-command.webp" alt="Command Mode">

**Copy Mode**
<br>
<img src="assets/screenshots/statusbar/mode-copy.webp" alt="Copy Mode">

**View Mode**
<br>
<img src="assets/screenshots/statusbar/mode-view.webp" alt="View Mode">

**Choose Mode**
<br>
<img src="assets/screenshots/statusbar/mode-choose.webp" alt="Choose Mode">

**Clock Mode**
<br>
<img src="assets/screenshots/statusbar/mode-clock.webp" alt="Clock Mode">

**Options Mode**
<br>
<img src="assets/screenshots/statusbar/mode-options.webp" alt="Options Mode">

</div>

> [!NOTE]
> Previews above all use the `lagoon` variant.

## Theme Overview

Choose from 14 distinct desert-inspired variants, each with its own personality and color palette:

<table>
  <tr>
    <td align="center">
      <a href="#night---purple-night-sky"><img src="assets/screenshots/tmux-night.webp" alt="Night" width="180"></a><br>
      <strong>Night</strong><br><em>Purple Night Sky</em>
    </td>
    <td align="center">
      <a href="#night---off-black"><img src="assets/screenshots/tmux-midnight.webp" alt="Midnight" width="180"></a><br>
      <strong>Midnight</strong><br><em>Off Black</em>
    </td>
    <td align="center">
      <a href="#abyss---black"><img src="assets/screenshots/tmux-abyss.webp" alt="Abyss" width="180"></a><br>
      <strong>Abyss</strong><br><em>Black</em>
    </td>
    <td align="center">
      <a href="#starlight---black-vivid"><img src="assets/screenshots/tmux-starlight.webp" alt="Starlight" width="180"></a><br>
      <strong>Starlight</strong><br><em>Black Vivid</em>
    </td>
  </tr>
  <tr>
    <td align="center">
      <a href="#desert---grey"><img src="assets/screenshots/tmux-desert.webp" alt="Desert" width="180"></a><br>
      <strong>Desert</strong><br><em>Grey</em>
    </td>
    <td align="center">
      <a href="#sol---red"><img src="assets/screenshots/tmux-sol.webp" alt="Sol" width="180"></a><br>
      <strong>Sol</strong><br><em>Red</em>
    </td>
    <td align="center">
      <a href="#canyon---orange"><img src="assets/screenshots/tmux-canyon.webp" alt="Canyon" width="180"></a><br>
      <strong>Canyon</strong><br><em>Orange</em>
    </td>
    <td align="center">
      <a href="#dune---yellow"><img src="assets/screenshots/tmux-dune.webp" alt="Dune" width="180"></a><br>
      <strong>Dune</strong><br><em>Yellow</em>
    </td>
  </tr>
  <tr>
    <td align="center">
      <a href="#cactus---green"><img src="assets/screenshots/tmux-cactus.webp" alt="Cactus" width="180"></a><br>
      <strong>Cactus</strong><br><em>Green</em>
    </td>
    <td align="center">
      <a href="#mirage---teal"><img src="assets/screenshots/tmux-mirage.webp" alt="Mirage" width="180"></a><br>
      <strong>Mirage</strong><br><em>Teal</em>
    </td>
    <td align="center">
      <a href="#lagoon---blue"><img src="assets/screenshots/tmux-lagoon.webp" alt="Lagoon" width="180"></a><br>
      <strong>Lagoon (Default)</strong><br><em>Blue</em>
    </td>
    <td align="center">
      <a href="#twilight---purple"><img src="assets/screenshots/tmux-twilight.webp" alt="Twilight" width="180"></a><br>
      <strong>Twilight</strong><br><em>Purple</em>
    </td>
  </tr>
  <tr>
    <td align="center">
      <a href="#rose---pink"><img src="assets/screenshots/tmux-rose.webp" alt="Rose" width="180"></a><br>
      <strong>Rose</strong><br><em>Pink</em>
    </td>
    <td align="center">
      <a href="#dawn---light"><img src="assets/screenshots/tmux-dawn.webp" alt="Dawn" width="180"></a><br>
      <strong>Dawn</strong><br><em>Light</em>
    </td>
  </tr>
</table>

> [!TIP]
> Click any card above to see the full preview example. Or [click here to see all](#view-all-theme-variants).
>
> The companion NeoVim colorscheme can be found here: [oasis.nvim](https://github.com/uhs-robert/oasis.nvim)

## Features

- **Advanced status line**: Dynamic mode indicators with color-coded states inspired by `vim` for each of tmux's modes: includes `NORMAL`, `COMMAND`, `COPY`, `VIEW`, `CHOOSE`, `CLOCK`, and `OPTIONS` modes.
- **14 theme variants**: Covers the entire rainbow of options with an emphasis on being dark with one light theme thrown in for good measure. Variants are all desert-inspired.
- **Automatic theme loading**: Set `@oasis_flavor` and the system will handle the rest
- **Modular design**: Separate theme files and unique status line configurations (_you could just download **only** what you need_)
- **Standalone**: Zero dependencies on any other plugins

## Installation

### Method 1: Tmux Plugin Manager (TPM) - Recommended

1. Add to your `tmux.conf`:

```tmux
set -g @plugin 'uhs-robert/tmux-oasis'
set -g @oasis_flavor "lagoon"  # Optional: defaults to lagoon
```

2. Install with TPM: `prefix + I`

### Method 2: Manual Installation

1. Clone this repository:

```bash
git clone https://github.com/uhs-robert/tmux-oasis ~/.tmux/themes/tmux-oasis
```

2. In your `tmux.conf`, set your preferred theme variant:

```tmux
set -g @oasis_flavor "lagoon"
```

3. Source the main configuration:

```tmux
source-file "~/.tmux/themes/tmux-oasis/oasis_tmux.conf"
```

4. Reload tmux: `tmux source ~/.tmux.conf`

## Status Line Features

The status line is inspired from 'lualine' in Neovim. It includes:

- **Dynamic mode indicators**: Visual indicators for `prefix mode`, `copy mode`, `command mode`, `tree mode` etc.
- **Session information**: Current session name with icons
- **Current directory**: Abbreviated path display
- **Real-time clock**: Hours, minutes, seconds with AM/PM
- **Color-coded states**: Different colors for all of the different tmux modes

## (Devs) Creating New Theme Variants

1. Create a new file in `themes/oasis_[name].conf`
2. Define all the `@thm_*` color variables
3. Use `set -g @oasis_flavor "[name]"` in your tmux.conf

> [!TIP]
> Feel free to add your own variants by creating `themes/oasis_[variant].conf` files

## View All Theme Variants

> [!IMPORTANT]
> The status line at the top is the TMUX plugin integration.
>
> The screenshots below show how the theme looks [with the companion theme in neovim](https://github.com/uhs-robert/oasis.nvim)

<details open>
  <summary><b>All variants (click to collapse)</b></summary>

### Night - Purple Night Sky

Deep desert night sky with purple-indigo undertones, a deeper purple than twilight for those who prefer soft darkness

<img src="assets/screenshots/tmux-night.webp" alt="Night" width="800">

### Midnight - Off Black

Deep slate and navy tones of the desert at midnight, a tinted-black lighter than abyss

<img src="assets/screenshots/tmux-midnight.webp" alt="Midnight" width="800">

### Abyss - Black

Deep, dark variant with mysterious depths

<img src="assets/screenshots/tmux-abyss.webp" alt="Abyss" width="800">

### Starlight - Black Vivid

Desert abyss illuminated by brilliant starlight with vivid accent colors

<img src="assets/screenshots/tmux-starlight.webp" alt="Starlight" width="800">

### Desert - Grey

Inspired by the classic vim desert theme, neutral sand and earth tones

<img src="assets/screenshots/tmux-desert.webp" alt="Desert" width="800">

### Sol - Red

Hot, scorching desert sun with intense red tones

<img src="assets/screenshots/tmux-sol.webp" alt="Sol" width="800">

### Canyon - Orange

Rich oranges of desert canyon walls

<img src="assets/screenshots/tmux-canyon.webp" alt="Canyon" width="800">

### Dune - Yellow

Sandy beiges and warm yellow earth tones

<img src="assets/screenshots/tmux-dune.webp" alt="Dune" width="800">

### Cactus - Green

Fresh greens of desert vegetation

<img src="assets/screenshots/tmux-cactus.webp" alt="Cactus" width="800">

### Mirage - Teal

Cool teals of shimmering desert mirages

<img src="assets/screenshots/tmux-mirage.webp" alt="Mirage" width="800">

### Lagoon - Blue

The original Oasis theme, cool blues of the oasis lagoon

<img src="assets/screenshots/tmux-lagoon.webp" alt="Lagoon" width="800">

### Twilight - Purple

Evening desert with purple and indigo hues

<img src="assets/screenshots/tmux-twilight.webp" alt="Twilight" width="800">

### Rose - Pink

Soft pinks of the warm desert rose

<img src="assets/screenshots/tmux-rose.webp" alt="Rose" width="800">

### Dawn - Light

Ah, the morning sun. Don't forget your sunglasses!

<img src="assets/screenshots/tmux-dawn.webp" alt="Dawn" width="800">

</details>
