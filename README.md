# 🏜️ Oasis Tmux

A modular desert-themed colorscheme for Tmux with warm, earthy tones and multiple palette variants. Originally inspired by the classic `desert` theme for vim, also uses the cool/warm philosophy from `melange` (i.e., `warm colors = action/flow` and `cool colors = structure/data`).

This is the companion to the **Oasis** theme suite: [oasis.nvim](https://github.com/uhs-robert/oasis.nvim)

## Features

- **Multiple theme variants**: Support for all the Oasis theme variants (lagoon, desert, dune, etc.)
- **Automatic theme loading**: Set `@oasis_flavor` and the system automatically loads the correct theme
- **Standalone**: Zero dependencies on any other plugin
- **Advanced status line**: Dynamic mode indicators with color-coded states
- **Modular design**: Separate theme files and status line configuration

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

## Usage

### Available Theme Variants

- `lagoon` (default) - The original Oasis theme with lagoon-inspired colors
- Add your own variants by creating `themes/oasis_[variant].conf` files

### Theme Variables

Each theme provides these color variables:

- `@thm_fg` - Foreground text color
- `@thm_primary` - Primary accent color
- `@thm_secondary` - Secondary accent color
- `@thm_core` - Core/background color
- `@thm_mantle` - Mantle color
- `@thm_surface` - Surface color
- `@thm_red`, `@thm_orange`, `@thm_yellow`, `@thm_green`, etc. - Standard colors

### Creating New Theme Variants

1. Create a new file in `themes/oasis_[name].conf`
2. Define all the `@thm_*` color variables
3. Use `set -g @oasis_flavor "[name]"` in your tmux.conf

### Status Line Features

The status line is inspired from lualine in Neovim. It includes:

- **Dynamic mode indicators**: Visual indicators for copy mode, command mode, etc.
- **Session information**: Current session name with icons
- **Current directory**: Abbreviated path display
- **Real-time clock**: Hours, minutes, seconds with AM/PM
- **Color-coded states**: Different colors for different tmux modes

