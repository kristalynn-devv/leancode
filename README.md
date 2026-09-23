# leancode

A coding-workflow skill for agents. It turns "implement this" from a single leap into
a walk with nine steps plus a structure check and one tighten pass on the finished diff, and (the part most
workflows leave out) it **audits whether the walk actually happened** before it
reports anything back.

Written for [Claude Code](https://claude.com/claude-code) skills, but it is one
Markdown file with YAML frontmatter, so any agent that loads skills by description
can read it.

## What it does

| Step | What it enforces |
| --- | --- |
| §0 Entry and return | Note who handed the work over. Hit a decision you cannot make → hand it **back**, don't guess and don't pick the next skill for them |
| §1 Plan first | Say the goal out loud before the first edit; read the code this touches; read the repo's standing constraints, not just the scope-matched docs |
| Structure | Name the case before the edit. A new boundary is checked against that decision. A refactor keeps the structure already there |
| §2 Build lean | Reuse before adding; no new abstraction until there are real call sites for it |
| §3 Verify with evidence | A baseline run *before* the change; the new test seen red; the full diff read. Never "should work" |
| §4 Self-review | A delegated review round, findings checked against the code, rejected ones named |
| Optimize | One pass on the finished diff: remove, collapse, bound a cost this change introduced. No speed rewrite without a measurement |
| §5 Split across agents | Subagents are authorized for speed. Analyse the risk *before* splitting; never repeat an in-flight task; fan out only onto slices that cannot touch each other; the main session owns the merge |
| §6 Continuity | `HANDOFF.md` once the session is close to running out, so the next one doesn't start cold |
| §7 Audit | Re-read the **session**, not the diff. A step that never happened leaves nothing in a diff to see |
| §8 Report | What changed, why, how it was verified, and what was deliberately skipped |
| §9 Doc hygiene | Docs are edited only on the user's go-ahead |

Two design decisions carry most of the weight:

**Ceremony scales with the change, and the level is said out loud.** A typo gets a
diff read. A small fix gets §2, §3, Structure, Optimize, §8. Anything else gets the whole walk. Without
this a workflow skill is only ever obeyed on the tasks that did not need it.

**The skill never edits its own rules mid-task.** Observations go into an
append-only `FRICTION.md` beside `SKILL.md`; promoting one into a rule needs a human,
and needs the change to name what it replaces. The session that just got burned is the
worst judge of what the rule should be. It over-corrects from a sample of one, and
every rule added is paid for on every future run, invisibly.

`FRICTION.md` is not published here, because mine logs real repo names. Start your own from
[`FRICTION.template.md`](./FRICTION.template.md).

## Setup

Needs an agent that loads skills from a folder. [Claude Code](https://claude.com/claude-code)
is what it was written against and the only one it has been run in.

The skill is a folder with a `SKILL.md` in it. **The folder name must match the `name:`
in the frontmatter** (`leancode`), because that is how the agent addresses it.

Paths below are macOS and Linux. On Windows the personal skills folder is
`%USERPROFILE%\.claude\skills\`, and the symlink route is
`mklink /D "%USERPROFILE%\.claude\skills\leancode" C:\src\leancode` from an
elevated prompt.

Already have a `leancode` folder there from an earlier install? The clone will refuse
rather than overwrite it. Update it instead, with the `git pull` under
[Update / remove](#update--remove).

### Every project (personal skill)

```bash
git clone https://github.com/kristalynn-devv/leancode.git ~/.claude/skills/leancode
```

### One project only (project skill)

Commit it into the repo so everyone working there gets the same walk:

```bash
git clone https://github.com/kristalynn-devv/leancode.git .claude/skills/leancode
rm -rf .claude/skills/leancode/.git   # keep it as files, not a nested repo
```

### Keep a clone you can edit, symlink it in

Best if you intend to tune the rules and push them back:

```bash
git clone https://github.com/kristalynn-devv/leancode.git ~/src/leancode
ln -s ~/src/leancode ~/.claude/skills/leancode
```

### Verify it loaded

Start Claude Code and type `/leancode`. If the skill is listed, it is installed.
Naming it is optional though, since the description is written so it engages on
implementation intent by itself ("fix this bug", "add this endpoint").

```
/leancode
```

### Start the friction log

```bash
cp ~/.claude/skills/leancode/FRICTION.template.md ~/.claude/skills/leancode/FRICTION.md
```

Without it §7's last line has nowhere to write, and the skill stops learning from its
own runs. One line per run, including the runs that went fine, because a log of only
the failures is a numerator with no denominator.

### Tune it

Every threshold lives in one table at the top of `SKILL.md` and is referenced by name
from the section that uses it. Change the number there; don't hunt for it in the prose.

| Name | Default | What it gates |
| --- | --- | --- |
| `handoff.steps_left` | 3 | Steps still open before `HANDOFF.md` is required |
| `handoff.context_left` | 20% | Remaining context budget that triggers the note |
| `abstraction.call_sites` | 3 | Real call sites required before a new abstraction exists |
| `build.max_cycles` | 3 | Build→verify cycles before stopping to rethink |
| `review.rounds` | 1 | Delegated self-review passes |
| `review.max_rounds` | 2 | Hard ceiling; past this, hand back to the caller |
| `optimize.passes` | 1 | One pass on the finished diff; leftovers are named, not re-hunted |

### Update / remove

```bash
git -C ~/.claude/skills/leancode pull    # update
rm -rf ~/.claude/skills/leancode         # remove
```

## Where it sits

Planning is somebody else's job. This skill is reached by **state**, not by name: the
decisions are settled and the next move is editing code. Pair it with whatever you plan
in: a planning skill, an issue tracker, your own head. When it hits something it cannot
decide, it returns the question to whoever called it rather than routing on to a skill
of its own choosing.

## License

MIT. See [LICENSE](./LICENSE).
