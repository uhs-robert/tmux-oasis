#!/usr/bin/env bash
# Usage: owner_commands.sh preview|restore [option=value ...]
# Prints tmux commands for the owner to run on their own server; runs none itself.
set -euo pipefail
. "$(dirname "$0")/lib.sh"

# Built-in modules are set with `set -o`, so a reload keeps the values already
# loaded from TPM's copy unless they are unset first. Restore unsets them too,
# or the checkout's versions would outlive the preview.
module_options() {
  grep -hoE '^[[:space:]]*set(-option)? -[a-zA-Z]+ @oasis_module_[A-Za-z0-9_]+' "$checkout_dir"/status/modules/*.conf |
    awk '{print $NF}' | sort -u
}

single_quoted() {
  printf "'%s'" "$(printf '%s' "$1" | sed "s/'/'\\\\''/g")"
}

action=${1:-}
case $action in
  preview | restore) shift ;;
  *) die "usage: owner_commands.sh preview|restore [option=value ...]" ;;
esac
check_option_args "$@"

for name in $(module_options); do
  echo "tmux set -gu $name"
done

case $action in
  preview)
    for assignment in "$@"; do
      echo "tmux set -g $(option_name "${assignment%%=*}") $(single_quoted "${assignment#*=}")"
    done
    echo "tmux source-file $checkout_dir/oasis_tmux.conf"
    ;;
  restore)
    for assignment in "$@"; do
      echo "tmux set -gu $(option_name "${assignment%%=*}")"
    done
    echo "tmux source-file ~/.tmux.conf"
    ;;
esac
