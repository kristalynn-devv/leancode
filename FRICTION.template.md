# FRICTION — what actually happened when `leancode` ran

> Template. Copy to `FRICTION.md` beside `SKILL.md` and start logging your own runs.

Observations, not rules. **Append-only.** Nothing here changes how the skill behaves until a human moves it into `SKILL.md` deliberately.

Why the split: the session that just got burned is the worst judge of what the rule should be — it over-corrects from a sample of one, and every added rule is paid for on every future invocation, invisibly. Observing is cheap and safe; deciding is neither.

## How to append

At the **end** of a task — never mid-task.

**Every run gets one line.** Without these there is no denominator, and "the skill failed 3 times" means nothing.

```
- 2026-09-17 · <repo> · <task in a few words> · <ended: shipped | returned to caller | stopped at ceiling | abandoned>
```

**A run where a rule failed gets a second line.** Log both directions — a rule that fired and was useless matters as much as a rule that was missing, because it is the only thing that ever justifies *deleting* a rule. Without deletions the file only grows.

```
  ↳ §<section> · <what the rule did or failed to do, one sentence>
```

## Bar for promoting an observation into a rule

An entry may become a rule in `SKILL.md` only when:

1. it happened **twice in different repos**, or **once with real damage**; and
2. the change names what it **replaces or shortens** — or says why the file can carry the extra weight; and
3. a human approves it. The skill never promotes its own entries.

Repo-specific lessons ("this repo's tests are flaky", "this repo forbids refactors", migration or alerting policy) go in that repo's own `CLAUDE.md` — never here, never in `SKILL.md`.

## Runs

<!-- One line per run, newest last. Keep the ones that went fine too — without them
     "the skill failed three times" has no denominator. -->
