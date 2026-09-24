# adapters

Optional. `SKILL.md` works without anything here. An adapter makes §2's rule, *anything
irreversible gets confirmed before it runs*, hold even when the agent skips it.

## Default: each harness's own guard, and block rather than ask

In an autonomous mode the agent is meant to keep working without a person at the
keyboard, so a destructive command is **blocked without a prompt**. The agent is told
why, records it as a blocker, and carries on with the rest. The user runs the command
themselves if they mean it. Use the harness's native mechanism first; the shared hook
covers what native rules can't express.

| Harness | Default (native) | Extra, if needed |
| --- | --- | --- |
| Claude Code | Nothing to install. Auto mode's built-in `soft_deny` rules already cover every entry in `patterns.txt`: they block without prompting and tell Claude which rule fired. Check with `claude auto-mode defaults`. | Extend with your own prose rules under `autoMode.soft_deny`, keeping `"$defaults"` in the list |
| Codex CLI | `codex/default.rules`: execpolicy `forbidden` rules, which block without prompting. Copy to `~/.codex/rules/`. | `guard.sh codex` as a `PreToolUse` hook on `Bash`, for flag orders a token prefix misses |
| Cursor | `cursor/hooks.example.json`: `guard.sh cursor` on `beforeShellExecution`. The IDE has no hard denylist of its own. Merge into `~/.cursor/hooks.json` or `<project>/.cursor/hooks.json`. | The Cursor CLI also takes `permissions.deny` rules in `cli-config.json` |

Sources, checked 2026-09-24:
[Claude Code auto mode](https://code.claude.com/docs/en/auto-mode-config.md),
[Codex rules](https://learn.chatgpt.com/docs/agent-configuration/rules),
[Codex hooks](https://learn.chatgpt.com/docs/hooks),
[Cursor hooks](https://cursor.com/docs/agent/hooks),
[Cursor CLI permissions](https://cursor.com/docs/cli/reference/permissions).
Tested here: `guard.sh` in all three output formats, and Claude Code's defaults. Not yet
run inside Codex or Cursor.

## Files

- `patterns.txt`: the harness-neutral list, one POSIX extended regex per line. Generic
  on purpose. Project rules, such as which cluster or namespace counts as dev, go in
  that project's own harness settings.
- `guard.sh <claude|codex|cursor>`: reads the command from the hook's stdin (with `jq`
  if installed, otherwise from the raw payload) and prints a **deny** in that harness's
  format on the first match. Check it without installing:

  ```bash
  echo '{"tool_input":{"command":"git reset --hard"}}' | ~/.claude/skills/leancode/adapters/guard.sh codex
  ```

- `codex/default.rules`: `patterns.txt` as Codex token-prefix rules. Keep both in step.
- `cursor/hooks.example.json`: hook registration for Cursor.
- `claude-code/guard.sh`: retired no-op, kept so an older install that points at it
  doesn't error. Remove that hook from your settings.

A hook that fails, for example because the script is missing, lets the command through
(Cursor: unless the hook sets `failClosed: true`). The `SKILL.md` rule is then the only
guard left.

## Interactive use

Outside an autonomous mode, the harness already asks before running a shell command you
haven't allowlisted, so nothing here is needed. To force a prompt even for allowlisted
commands in Claude Code, add `permissions.ask` rules. They prompt in auto mode too, which
stalls an unattended run, so don't use them for one.
