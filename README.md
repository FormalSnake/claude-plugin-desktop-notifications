# tmux-agent-notifications (Claude Code Plugin)

Per-project tmux status bar notifications for Claude Code agents. Each agent gets its own notification that only disappears when you focus that specific pane.

## What This Plugin Does

This Claude Code plugin automatically registers hooks for:
- **Stop** - Notifies when an agent finishes
- **Notification** - Shows agent messages that need attention
- **UserPromptSubmit** - Clears notifications when you interact with an agent

No manual `settings.json` editing required.

## Requirements

- tmux 3.2+
- [tmux-agent-notifications](https://github.com/kaiiserni/tmux-agent-notifications) TPM plugin (for status bar display)

## Installation

Install the Claude Code plugin:

```bash
claude plugin add kaiiserni/claude-plugin-tmux-notifications
```

Then install the companion tmux plugin for status bar display. Add to `~/.tmux.conf`:

```tmux
set -g @plugin 'kaiiserni/tmux-agent-notifications'
```

Reload tmux: `prefix + I`

## How It Works

```
Claude Code hooks (this plugin)     tmux plugin
         |                              |
    Stop/Notification             status line display
         |                         keybindings
         v                         auto-clearing
  ~/.claude/.notifications/
    ProjectA__42
    ProjectB__53
```

1. This plugin catches Claude Code events and writes notification files
2. The tmux plugin reads those files and displays them in the status bar
3. Notifications clear automatically when you focus the agent's pane

## Configuration

Display settings are configured via tmux `@` variables in `~/.tmux.conf` (see the [tmux plugin README](https://github.com/kaiiserni/tmux-agent-notifications)).

## License

MIT
