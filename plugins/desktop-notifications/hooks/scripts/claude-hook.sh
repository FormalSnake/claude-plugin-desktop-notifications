#!/usr/bin/env bash

HOOK_EVENT="$1"
LOG_FILE="$HOME/.claude/notifications.log"
TIMESTAMP=$(date '+%H:%M:%S')

# Read JSON from stdin
if [ ! -t 0 ]; then
    JSON_DATA=$(cat)
fi

# Extract project name
if [ -n "$JSON_DATA" ]; then
    CWD=$(echo "$JSON_DATA" | grep -o '"cwd"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/.*: *"\([^"]*\)".*/\1/')
    PROJECT_NAME=$(basename "${CWD:-unknown}")
    PARENT_DIR=$(basename "$(dirname "$CWD")" 2>/dev/null)
    if [[ "$PARENT_DIR" == *.git ]]; then
        DISPLAY_NAME="${PARENT_DIR%.git}/$PROJECT_NAME"
    else
        DISPLAY_NAME="$PROJECT_NAME"
    fi
else
    PROJECT_NAME="unknown"
    DISPLAY_NAME="unknown"
fi

parse_json() {
    echo "$JSON_DATA" | grep -o "\"$1\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" | sed 's/.*: *"\([^"]*\)".*/\1/'
}

log_event() {
    local icon="$1"
    local msg="$2"
    echo "[$TIMESTAMP] $icon $DISPLAY_NAME: $msg" >> "$LOG_FILE"
}

send_notification() {
    local title="$1"
    local subtitle="$2"
    local message="$3"

    case "$(uname -s)" in
        Darwin)
            terminal-notifier -title "$title" -subtitle "$subtitle" \
                -message "$message" -sound default 2>/dev/null
            ;;
        Linux)
            if grep -qi microsoft /proc/version 2>/dev/null; then
                # WSL -> Windows toast via PowerShell
                powershell.exe -Command "
                    [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null;
                    [Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom, ContentType = WindowsRuntime] | Out-Null;
                    \$xml = New-Object Windows.Data.Xml.Dom.XmlDocument;
                    \$xml.LoadXml('<toast><visual><binding template=\"ToastGeneric\"><text>$title - $subtitle</text><text>$message</text></binding></visual></toast>');
                    \$toast = New-Object Windows.UI.Notifications.ToastNotification \$xml;
                    [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier('Claude Code').Show(\$toast)
                " 2>/dev/null
            else
                notify-send "$title - $subtitle" "$message" 2>/dev/null
            fi
            ;;
        MINGW*|MSYS*|CYGWIN*)
            # Native Windows (Git Bash)
            powershell.exe -Command "
                [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null;
                [Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom, ContentType = WindowsRuntime] | Out-Null;
                \$xml = New-Object Windows.Data.Xml.Dom.XmlDocument;
                \$xml.LoadXml('<toast><visual><binding template=\"ToastGeneric\"><text>$title - $subtitle</text><text>$message</text></binding></visual></toast>');
                \$toast = New-Object Windows.UI.Notifications.ToastNotification \$xml;
                [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier('Claude Code').Show(\$toast)
            " 2>/dev/null
            ;;
    esac
}

case "$HOOK_EVENT" in
    "Stop")
        log_event "done" "Agent has finished"
        send_notification "Claude Code" "$DISPLAY_NAME" "Agent has finished"
        ;;
    "Notification")
        MESSAGE=$(parse_json "message")
        MESSAGE=${MESSAGE:-"Needs attention"}
        MESSAGE=${MESSAGE//Claude/Agent}
        log_event "" "$MESSAGE"
        send_notification "Claude Code" "$DISPLAY_NAME" "$MESSAGE"
        ;;
esac

exit 0
