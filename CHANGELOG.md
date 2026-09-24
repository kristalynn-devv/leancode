# Changelog

`version` in `SKILL.md`'s frontmatter is the source of truth. Semver: major = breaking walk change, minor = new rule or section, patch = wording. Newest first.

- 3.0.0 (2026-09-24) — split for size: §5 risk pass and fan-out shapes → references/split.md, §6 template → references/handoff.md, §9 skeleton → references/doc-skeleton.md, changelog → CHANGELOG.md; each pointer carries an inline fallback
- 2.9.0 (2026-09-24) — §3 baseline runs in the background during planning and finishes before the first edit; §4 review runs in the background while §8 is drafted and §7 walked up to §3; Optimize waits for findings
- 2.8.0 (2026-09-24) — §1 task list lives in the harness's todo tool when present, kept current per step, gates each edit; §7 friction line records tier and wall time
- 2.7.1 (2026-09-24) — §7 audit line for §5 matches 2.7.0's conditional wording

- 2.7.0 (2026-09-24) — harness-neutral wording: §2 comments follow the file's density; §5 standing ask applies only where a harness bans spawning; §6 note is a checkpoint, needed with or without compaction

- 2.6.0 (2026-09-24) — §3: in-session fallback when `security-review` or `run` is missing or can't spawn, aimed at this change's diff; §7 accepts it when named
- 2.5.0 (2026-09-23) — Structure: name new or existing before the edit. A named new boundary is exempt from `abstraction.call_sites`; one correction does not reopen §4. A refactor keeps the structure already there
- 2.4.0 (2026-09-23) — Optimize, one pass after §4: remove, collapse, bound a cost this change introduced. No speed rewrite without a measurement
- 2.3.0 (2026-09-23) — §5 authorizes subagents for speed; a slice that repeats another in-flight task is a no. "Unless the user asked" counts as asked
- 2.2.0 (2026-09-22) — §5 rewritten: mandatory pre-split risk pass, three fan-out shapes, non-interference and isolation rules, main-session-owns-merge
- 2.1.0 (2026-09-22) — require a version bump + changelog line on every SKILL.md edit
- 2.0.0 (2026-09-21) — first numbered snapshot of the evolved walk (tunables, §0–§9, FRICTION.md)
