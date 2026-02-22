#!/usr/bin/env bash

# Not in tmux? Skip
[ -z "$TMUX" ] && exit 0

# Check if tmux plugin is active (notification-reader in status line)
if ! tmux show-option -gqv status-format[1] 2>/dev/null | grep -q "notification-reader"; then
    echo "tmux-agent-notifications: tmux plugin not detected. Install via TPM: set -g @plugin 'kaiiserni/tmux-agent-notifications'" >&2
fi

exit 0
