#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Source the main configuration file
tmux source-file "$CURRENT_DIR/oasis_tmux.conf"