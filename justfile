set positional-arguments

# List available recipes
default:
    just --list

# Reload tmux config from oasis_tmux.conf
reload:
    tmux source-file oasis_tmux.conf

# List available theme names (dark + light, .conf stripped)
list:
    @ls themes/dark/ themes/light/ | grep '\.conf$' | sed 's/oasis_//;s/\.conf//'

# Pull latest theme .conf files from sibling oasis.nvim repo
sync:
    cp ../oasis.nvim/extras/tmux/themes/dark/*.conf themes/dark/
    for d in 1 2 3 4 5; do cp ../oasis.nvim/extras/tmux/themes/light/$d/*.conf themes/light/$d/; done
    @echo "Synced themes from oasis.nvim"

# Apply named theme: find its .conf, set flavor var, source it
theme name:
    @conf=$(find themes -name "oasis_{{name}}.conf" | head -1); \
    if [ -z "$conf" ]; then echo "Theme not found: {{name}}"; exit 1; fi; \
    tmux set -gq @oasis_flavor "{{name}}" && tmux source-file "$conf" && echo "Loaded: $conf"

# Run the status script tests in tests/ (args: [name ...])
test *args:
    @bash dev/test.sh "$@"

# Start the isolated tmux server oasis-dev with this checkout loaded (args: option=value ...)
sandbox *args:
    @bash dev/sandbox.sh start "$@"

# Kill the oasis-dev sandbox server
sandbox-stop:
    @bash dev/sandbox.sh stop

# Print the sandbox's drawn status bar as cells, glyphs as U+XXXX
render:
    @bash dev/render.sh

# Check the drawn bar matches ref cell by cell (args: [ref] [option=value ...], ref defaults to main)
compare *args:
    @bash dev/compare.sh "$@"

# Draw the status bar to a PNG (args: [out.png] [option=value ...])
screenshot *args:
    @bash dev/screenshot.sh "$@"

# Print commands for the owner to preview this checkout on their own tmux (args: option=value ...)
preview *args:
    @bash dev/owner_commands.sh preview "$@"

# Print commands to undo `just preview` (args: the same option=value ... given to preview)
restore *args:
    @bash dev/owner_commands.sh restore "$@"
