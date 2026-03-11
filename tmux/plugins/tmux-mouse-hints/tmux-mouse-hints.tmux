#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Bind Ctrl+Click to our handler script
tmux bind-key -n C-MouseDown1Pane run-shell -b "$CURRENT_DIR/scripts/handle-click.sh '#{mouse_word}' '#{mouse_x}' '#{mouse_y}' '#{pane_id}'"
