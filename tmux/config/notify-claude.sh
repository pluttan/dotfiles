#!/bin/bash
# Notify when Claude Code finishes work (spinner -> done)

PANE_ID="$1"
STATE_DIR="/tmp/claude-pane-state"
mkdir -p "$STATE_DIR"

TITLE=$(/opt/homebrew/bin/tmux display-message -t "$PANE_ID" -p '#{pane_title}' 2>/dev/null)
CMD=$(/opt/homebrew/bin/tmux display-message -t "$PANE_ID" -p '#{pane_current_command}' 2>/dev/null)

# Only track non-shell panes (Claude Code etc.)
[ "$CMD" = "zsh" ] || [ "$CMD" = "bash" ] && exit 0

FIRST_CHAR="${TITLE:0:1}"
STATE_FILE="$STATE_DIR/$PANE_ID"
PREV_CHAR=""
[ -f "$STATE_FILE" ] && PREV_CHAR=$(cat "$STATE_FILE")

echo -n "$FIRST_CHAR" > "$STATE_FILE"

# If previous char was a spinner and now it's not — notify
if [ -n "$PREV_CHAR" ] && [ "$PREV_CHAR" != "$FIRST_CHAR" ] && [ "$FIRST_CHAR" = "✳" ]; then
    /opt/homebrew/bin/tmux display-message "Claude Code: ${TITLE:2}"
    afplay /Volumes/pr/dotfiles/sounds/notify.mp3 &
fi
