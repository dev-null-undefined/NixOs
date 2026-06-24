# Claude Code `Notification` hook — desktop notification via notify-send.
#
# Reads the hook JSON payload on stdin and pops a notification UNLESS the
# terminal window hosting *this* Claude Code session is the focused Hyprland
# window (so you are never notified about the window you are already looking at).
#
# Wrapped by writeShellApplication, so the shebang + `set -euo pipefail` and the
# runtime PATH (jq, libnotify, coreutils, gawk) are injected by Nix. hyprctl is
# intentionally not a runtime input: it is resolved from the session PATH and the
# focus check degrades to "always notify" when it is absent (e.g. not on Hyprland).
#
#   title  = current working directory (project folder)
#   body   = AI chat title -> else last prompt -> else the reason message

input=$(cat)
field() { printf '%s' "$input" | jq -r "$1 // empty"; }

cwd=$(field '.cwd')
message=$(field '.message')
transcript=$(field '.transcript_path')
session_id=$(field '.session_id')
notification_type=$(field '.notification_type')

# Is the Hyprland-focused window the terminal running this session? Walk our
# process-ancestor chain and compare each PID to the active window's PID; a match
# means the hosting terminal is focused, so stay silent. Correct with multiple
# terminals open — only this session's own window suppresses the notification.
terminal_is_focused() {
  command -v hyprctl >/dev/null 2>&1 || return 1

  local active_pid pid
  active_pid=$(hyprctl activewindow -j 2>/dev/null | jq -r '.pid // empty')
  [ -n "$active_pid" ] && [ "$active_pid" -gt 0 ] 2>/dev/null || return 1

  pid=$$
  while [ "$pid" -gt 1 ] 2>/dev/null; do
    [ "$pid" -eq "$active_pid" ] && return 0
    pid=$(awk '/^PPid:/{print $2}' "/proc/$pid/status" 2>/dev/null)
    [ -n "$pid" ] || return 1
  done
  return 1
}

terminal_is_focused && exit 0

title=$(basename "$cwd" 2>/dev/null)
[ -n "$title" ] || title="Claude Code"

body=""
if [ -n "$transcript" ] && [ -f "$transcript" ]; then
  body=$(jq -r 'select(.type == "ai-title") | .aiTitle // empty' "$transcript" 2>/dev/null | tail -n1)
  [ -n "$body" ] || body=$(jq -r 'select(.type == "last-prompt") | .lastPrompt // empty' "$transcript" 2>/dev/null | tail -n1)
fi
[ -n "$body" ] || body="$message"
[ -n "$body" ] || body="Waiting for input"

# Collapse to a single line and cap the length so multi-line prompts stay tidy.
body=${body//$'\n'/ }
if [ "${#body}" -gt 140 ]; then
  body="${body:0:139}…"
fi
# notify-send reads a leading '-' as an option; nudge it out of the way.
case "$body" in -*) body=" $body" ;; esac

urgency=normal
case "$notification_type" in
  permission_prompt | elicitation_dialog) urgency=critical ;;
esac

# Tag by session so repeated notifications from one session replace rather than
# stack (honoured by mako/dunst; harmlessly ignored otherwise).
hint=()
[ -n "$session_id" ] && hint=(--hint="string:x-canonical-private-synchronous:claude-$session_id")

notify-send \
  --app-name="Claude Code" \
  --urgency="$urgency" \
  --icon=utilities-terminal \
  "${hint[@]}" \
  "$title" "$body"
