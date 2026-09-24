# adapters

Optional. `SKILL.md` works without anything here; an adapter makes one of its rules
hold even when the agent doesn't read or follow it.

## What's enforced

§2: *anything irreversible gets confirmed before it runs.* `patterns.txt` lists the
commands that count: one POSIX extended regex per line, harness-neutral. A match
**asks**, it never blocks, so a command you do mean to run is one confirmation away.

The list is generic on purpose. Rules that only hold for your project, such as which
cluster or namespace counts as dev, go in that project's own harness settings, not here.

## Claude Code

`claude-code/guard.sh` is a `PreToolUse` hook on `Bash`. It reads the command from the
hook payload (with `jq` if installed, otherwise from the raw payload) and returns
`permissionDecision: "ask"` on the first pattern that matches.

Install: merge `claude-code/hooks.example.json` into `~/.claude/settings.json` (every
project) or a project's `.claude/settings.json`. Merge it into any `hooks.PreToolUse`
array you already have instead of replacing that array. Then open `/hooks` once, or
restart, so the new hook loads.

Check it without installing:

```bash
echo '{"tool_input":{"command":"git reset --hard"}}' | ~/.claude/skills/leancode/adapters/claude-code/guard.sh
```

A hook that fails (the script missing, `patterns.txt` unreadable) lets the command
through, and the `SKILL.md` rule is then the only guard left.

### In auto mode, use `permissions.ask` instead

In auto mode the hook's `"ask"` did not show a prompt in testing, and the docs don't say
how auto mode treats it. `permissions.ask` rules do prompt in auto mode: they are
[documented](https://code.claude.com/docs/en/permissions.md) to, and did in testing,
including behind a `cd … &&` prefix. Mirror `patterns.txt` as rules, for example:

```json
"permissions": {
  "ask": [
    "Bash(git push *)", "Bash(git reset --hard*)", "Bash(git clean *)",
    "Bash(git branch -D *)", "Bash(git checkout -- *)", "Bash(rm -r*)",
    "Bash(kubectl delete *)", "Bash(kubectl drain *)", "Bash(helm uninstall *)",
    "Bash(helm rollback *)", "Bash(terraform destroy*)", "Bash(terraform apply*)"
  ]
}
```

Rules match by prefix, so they are coarser than the regexes: `git push *` asks on every
push, not only a forced one, and SQL inside a command (`psql -c 'DROP …'`) is not caught.
Merge them into any `permissions.ask` you already have.

## Other harnesses

None yet. An adapter for another harness reads `patterns.txt` and asks before a
matching shell command runs. Write one against that harness's documented hook format,
not a guess at it.
