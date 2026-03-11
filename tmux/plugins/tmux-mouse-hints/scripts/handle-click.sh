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

# Read config file and try to match patterns
while IFS= read -r line || [[ -n "$line" ]]; do
    # Skip comments and empty lines
    [[ "$line" =~ ^[[:space:]]*# ]] && continue
    [[ -z "${line// }" ]] && continue

    # Parse pattern = command
    if [[ "$line" =~ ^([^=]+)=(.+)$ ]]; then
        pattern="${BASH_REMATCH[1]}"
        command="${BASH_REMATCH[2]}"

        # Trim whitespace
        pattern=$(echo "$pattern" | xargs)
        command=$(echo "$command" | xargs)

        # Try to match pattern against the clicked line
        if [[ "$CLICKED_LINE" =~ $pattern ]]; then
            matched_text="${BASH_REMATCH[0]}"
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
    fi
done < "$CONFIG_FILE"

echo "No pattern matched" >> /tmp/tmux-mouse-hints.log
echo "---" >> /tmp/tmux-mouse-hints.log
