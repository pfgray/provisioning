#!/usr/bin/env bash

# Arguments passed from tmux
MOUSE_WORD="$1"
MOUSE_X="$2"
MOUSE_Y="$3"
PANE_ID="$4"

# Config file path will be substituted by Nix at build time
CONFIG_FILE="@CONFIG_FILE@"

# Capture the entire line around the click position for better pattern matching
CLICKED_LINE=$(tmux capture-pane -p -t "$PANE_ID" | sed -n "$((MOUSE_Y + 1))p")

echo "========" >> /tmp/tmux-mouse-hints.log

# For debugging
echo "Clicked word: $MOUSE_WORD" >> /tmp/tmux-mouse-hints.log
echo "Clicked line: $CLICKED_LINE" >> /tmp/tmux-mouse-hints.log
echo "Position: ($MOUSE_X, $MOUSE_Y)" >> /tmp/tmux-mouse-hints.log
echo "Pane: $PANE_ID" >> /tmp/tmux-mouse-hints.log

# Check if config file exists
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "Config file not found: $CONFIG_FILE" >> /tmp/tmux-mouse-hints.log
    exit 1
fi

echo "Using config file: $CONFIG_FILE" >> /tmp/tmux-mouse-hints.log

# Read config file and try to match patterns using jq to parse JSON
pattern_count=$(jq '.patterns | length' "$CONFIG_FILE")
echo "Found $pattern_count patterns in config" >> /tmp/tmux-mouse-hints.log

for ((i=0; i<pattern_count; i++)); do
    pattern=$(jq -r ".patterns[$i].pattern" "$CONFIG_FILE")
    command=$(jq -r ".patterns[$i].command" "$CONFIG_FILE")

    echo "Testing pattern: $pattern" >> /tmp/tmux-mouse-hints.log

    # Try to match pattern against the clicked line
    if [[ "$CLICKED_LINE" =~ $pattern ]]; then
        matched_text="${BASH_REMATCH[1]}"
        echo "Matched pattern: $pattern" >> /tmp/tmux-mouse-hints.log
        echo "Matched text: $matched_text" >> /tmp/tmux-mouse-hints.log

        # Replace {match} with the matched text in the command
        final_command="${command//\{match\}/$matched_text}"
        echo "Executing: $final_command" >> /tmp/tmux-mouse-hints.log

        # Show visual feedback in tmux status bar
        tmux display-message "Opening: $matched_text"

        # Execute the command
        eval "$final_command" &
        exit 0
    fi
done

echo "No pattern matched" >> /tmp/tmux-mouse-hints.log
echo "---" >> /tmp/tmux-mouse-hints.log
