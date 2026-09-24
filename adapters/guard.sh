#!/usr/bin/env bash
# Pre-shell-command hook: deny, without prompting, a command matching patterns.txt.
# Arg picks the output format: claude | codex (same contract) | cursor.
set -u
fmt=${1:-claude}
patterns="$(cd "$(dirname "$0")" && pwd)/patterns.txt"
input=$(cat)
cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // .command // empty' 2>/dev/null) || cmd=""
[ -n "$cmd" ] || cmd=$input  # no jq: match against the raw payload

while IFS= read -r p; do
  case "$p" in ''|'#'*) continue ;; esac
  if printf '%s' "$cmd" | grep -Eq -- "$p"; then
    reason=$(printf 'leancode: irreversible command blocked (matches %s). Record it as a blocker and carry on; the user runs it if they mean it.' "$p" | sed 's/\\/\\\\/g; s/"/\\"/g')
    case "$fmt" in
      cursor) printf '{"permission":"deny","user_message":"%s","agent_message":"%s"}\n' "$reason" "$reason" ;;
      *) printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"%s"}}\n' "$reason" ;;
    esac
    exit 0
  fi
done < "$patterns"
exit 0
