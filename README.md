# desktop-notifications (Claude Code Plugin)

Cross-platform desktop notifications for Claude Code agents. Get notified when agents finish or need attention — on macOS, Linux, and Windows.

## What This Plugin Does

This Claude Code plugin automatically registers hooks for:
- **Stop** — Notifies when an agent finishes
- **Notification** — Shows agent messages that need attention

No manual `settings.json` editing required.

## Requirements

| Platform | Requirement |
|----------|-------------|
| macOS | [`terminal-notifier`](https://github.com/julienXX/terminal-notifier) (`brew install terminal-notifier`) |
| Linux | `notify-send` (usually pre-installed via libnotify) |
| Windows/WSL | PowerShell (built-in on Windows 10+) |

### macOS: Why `terminal-notifier`?

`terminal-notifier` appears as its own app in **System Settings > Notifications**, which allows you to set the notification style to **Alerts** (persistent) instead of Banners. This means notifications stay visible until you dismiss them.

To configure:
1. Install: `brew install terminal-notifier`
2. Trigger a test notification (see below) so the app registers
3. Go to **System Settings > Notifications > terminal-notifier**
4. Set alert style to **Alerts**

## Installation

```bash
# Add the marketplace
claude plugin marketplace add FormalSnake/claude-plugin-desktop-notifications

# Install the plugin
claude plugin install desktop-notifications@claude-plugin-desktop-notifications
```

> Restart Claude Code after installing for hooks to activate.

## Testing

macOS:
```bash
terminal-notifier -title "Claude Code" -subtitle "test-project" -message "Agent has finished" -sound default
```

Linux:
```bash
notify-send "Claude Code - test-project" "Agent has finished"
```

Hook test:
```bash
echo '{"cwd":"/tmp/test-project"}' | bash plugins/desktop-notifications/hooks/scripts/claude-hook.sh Stop
```

## Notification Log

All notifications are logged to `~/.claude/notifications.log`.

## Uninstall

```bash
claude plugin uninstall desktop-notifications@claude-plugin-desktop-notifications
claude plugin marketplace remove claude-plugin-desktop-notifications
```

## License

MIT
