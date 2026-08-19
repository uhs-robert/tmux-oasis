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
