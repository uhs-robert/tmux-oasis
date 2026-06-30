reload:
    tmux source-file oasis_tmux.conf

list:
    @ls themes/dark/ themes/light/ | grep '\.conf$' | sed 's/oasis_//;s/\.conf//'

sync:
    cp ../oasis.nvim/extras/tmux/themes/dark/*.conf themes/dark/
    for d in 1 2 3 4 5; do cp ../oasis.nvim/extras/tmux/themes/light/$d/*.conf themes/light/$d/; done
    @echo "Synced themes from oasis.nvim"

theme name:
    @conf=$(find themes -name "oasis_{{name}}.conf" | head -1); \
    if [ -z "$conf" ]; then echo "Theme not found: {{name}}"; exit 1; fi; \
    tmux set -gq @oasis_flavor "{{name}}" && tmux source-file "$conf" && echo "Loaded: $conf"
