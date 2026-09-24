#!/usr/bin/env bash
# Claude Code PreToolUse hook: ask before a Bash command matching ../patterns.txt runs.
set -u
patterns="$(cd "$(dirname "$0")/.." && pwd)/patterns.txt"
input=$(cat)
cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // empty' 2>/dev/null) || cmd=""
[ -n "$cmd" ] || cmd=$input  # no jq: match against the raw payload

while IFS= read -r p; do
  case "$p" in ''|'#'*) continue ;; esac
  if printf '%s' "$cmd" | grep -Eq -- "$p"; then
    reason=$(printf 'leancode: irreversible command (matches %s), confirm first' "$p" | sed 's/\\/\\\\/g; s/"/\\"/g')
    printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"ask","permissionDecisionReason":"%s"}}\n' "$reason"
    exit 0
  fi
done < "$patterns"
exit 0
