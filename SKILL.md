---
name: leancode
description: "Use for any coding task — implementing a feature, fixing a bug, refactoring, reviewing code, or resuming interrupted work. Enforces plan-first (including greenfield work and reference lookups), lean implementation (reuse over duplication, security/perf awareness), a maximum-effort self-review (correctness, fit, cross-stack contracts), a structure check (a new boundary is named before the edit and matched on the diff; a refactor keeps the structure already there), one tighten pass on the finished diff (remove, collapse, bound a cost the change introduced — no unmeasured speed rewrite), a closing audit of the walk itself, a risk-assessed split across subagents for speed when slices are independent and do not repeat another in-flight task, evidence-based completion, ask-first doc hygiene, and a handoff note that survives across sessions. Engages on implementation intent without needing to be named, and returns open decisions to whoever handed the work over rather than guessing or re-routing. Scales down for trivial single-file edits and steps aside for non-coding requests."
version: 2.7.1
---

# Lean Code Workflow

## Tunables

Every threshold this skill uses lives here and is referenced by name from the section that uses it. Change a number here — don't hunt for it in the prose, and don't restate it there.

| Name | Default | Used by |
|---|---|---|
| `handoff.steps_left` | 3 | §6 — steps still open before the note is required |
| `handoff.context_left` | 20% | §6 — remaining context budget that triggers the note |
| `handoff.compactions` | 1 | §6 — compactions this session before the note is required |
| `abstraction.call_sites` | 3 | §2 — real call sites required before a new abstraction exists |
| `build.max_cycles` | 3 | §3 — build→verify cycles before stopping to rethink |
| `review.rounds` | 1 | §4 — delegated self-review passes |
| `review.max_rounds` | 2 | §4 — hard ceiling; past this, stop and hand back to the caller |
| `review.effort` | maximum (`ultrathink`) | §4 — reasoning depth the review runs at |
| `optimize.passes` | 1 | Optimize — one pass on the finished diff; leftovers are named, not re-hunted |
| `parallel.max_agents` | 3 | §5 — agents running at once, any shape |
| `parallel.min_slice` | ~1 sitting's worth | §5 — smallest slice worth handing to its own builder |

A project can override any of these in its own `CLAUDE.md`; the project's value wins — except that `review.max_rounds` always wins over `review.rounds`, a ceiling that config can exceed is not a ceiling.

## Versioning

`version` in the YAML frontmatter is the source of truth. Every edit to this file must, in the same change: bump `version` (semver — major = breaking walk change, minor = new rule or section, patch = wording) and add one Changelog line dated today. Say the new version in the §8 report. Append-only lines in `FRICTION.md` do not bump.

## 0. Entry and return

**You are reached by capability, not by name.** Planning happens wherever it happens — any skill, any conversation, the user's own head. What hands over to this skill is a *state*, not a call: the decisions are settled and the next move is editing code. Nothing upstream has to name this skill, and this skill names nothing downstream either.

**Note the return address before §1.** One line: who handed the work over — a planning skill, an orchestrator, or the user directly — and what came with it (the slice, the spec, the decisions already locked). No caller means the user is the caller.

**Hit something you can't decide → return it, don't route around it.** An open decision, a contradiction in the spec, a missing constraint that no amount of reading the code or looking it up resolves: stop building and hand it back to whoever called you — what you were doing, the exact question, the options you can see, and which one you'd pick. Don't guess past it. Don't invent the decision. Don't pass it to a third skill of your own choosing: the caller owns the route, and picking their next move for them is the same mistake as picking the answer for them.

- Returning is not failing. A question returned now costs one message; the same question guessed at costs the whole change, discovered at §4.
- Return the question, keep the work. Everything already built and verified stays; when the answer comes back, resume at the step you stopped at and leave locked decisions locked.
- Picking *which* work is the caller's call too. Handed a map, a backlog, or a pile of tickets with no slice named? That's not a menu to choose from — ask which one. Choosing for them feels helpful and costs exactly what guessing an answer costs.
- Only when there is no caller to return to — the user invoked you directly, and the question is about how the work should be *shaped* rather than what they want — reach for a planning pass yourself, and say which one you reached for and why.

## 1. Plan before touching code

- This request isn't actually an implement/fix/refactor task — it's a question, a discussion, or a plan-only ask → stop here after answering or planning. Don't walk §2–8.
- Restate the goal in one sentence. If it can't be stated in one sentence, the scope is unclear — narrow it.
- **Say that sentence out loud, with the slice it covers, before the first edit.** A goal restated only to yourself is a misreading nobody gets the chance to catch — and the cheapest moment to catch one is before any file is touched.
- **When the goal changes mid-flight, rewrite it before the next edit** — the sentence, the task list, and `HANDOFF.md`'s Goal and Decisions. §4 checks against the goal you are building to *now*, not the one you started the session with.
- Locate and read the code this touches — existing patterns, callers, related tests — before writing steps. A plan built without this risks resting on wrong assumptions about what's already there.
- Nothing to read because this is a new project or a part of it that doesn't exist yet → this isn't a coding step, it's a foundational decision (stack, structure, conventions). Return it to the caller (§0) — don't default your way into an architecture nobody chose. Whatever gets decided becomes the "existing pattern" every later change matches against.
- If the project has a docs router or index (e.g. a root `CLAUDE.md` that maps areas to files), follow it and read only the doc(s) matching this change's scope — never the whole doc tree. If no router exists, grep docs for the specific area instead of opening every file. A doc irrelevant to the current change is not worth its tokens.
- **Constraints are not scoped — read them every time.** A repo's standing prohibitions ("additive only", "don't refactor", "don't touch business logic", a frozen contract) usually live in the root `CLAUDE.md` or its equivalent, and usually do *not* match the scope of your change — so the scope-limited read above walks straight past them. Find them first, and restate the ones that bind this change in the plan. A rule you never read is a rule you will break. When an instruction and a repo constraint collide, say so before building and let the caller resolve it — don't quietly pick a side.
- Write the sequential steps as a task list before editing anything.
- A change that adds a file, moves code, or could be done by reshaping where things live → Structure, before the task list.
- Something doesn't resolve cleanly from the code or project docs — an unfamiliar library's API, a framework convention, a spec detail, a version-specific behavior — look it up (web search, official docs, or a docs tool like Context7) before guessing from memory or training data, which can be stale or simply wrong. Cite what you found when it changes the plan.
- Ask only questions that actually block the work; otherwise pick the obvious default and state the assumption. A genuinely blocking question goes back to the caller (§0), never into the build as a guess. A reference lookup that resolves it is better than either guessing or asking.
- **Scale the ceremony to the change, and say which level you picked.** One file, no behavior change (typo, copy, comment) → read the diff yourself; skip §4, Structure, Optimize, §6, §7, charting. A small fix that one test covers end to end → §2, §3, Structure, Optimize, §8, with §7 cut to the lines that apply and §4's delegated round optional. Anything else → the whole walk. Reading the diff before calling it done is never optional at any level.

## Structure — name the case before the edit

Two cases. Name one out loud before the task list. If both seem true, it is existing. New is the case you have to justify.

- **Existing** — a fix, a feature, or a refactor the current layout can hold. Name the neighbor: the file or folder this change sits beside, and the pattern it copies. File layout, naming, and where this kind of logic lives stay as they are. Moved code lands next to the code it already belonged with. The diff adds no new folder, no new layer, and no new pattern. A refactor that also invents a structure is two changes — return it (§0).
- **New** — nothing that already exists can hold the change without a second copy of the same idea. A repo with no pattern yet is not this case: that decision goes back to the caller (§1). Name the boundary and the interface in one sentence each before the task list. If that sentence is still an open decision, return it (§0). A lookup of what this codebase already does, or a design-guidance skill, can settle it; guessing cannot. On the diff, every new file belongs to that boundary, and callers cross only through the named interface. That seam is load-bearing — Optimize does not collapse it for having one call site. `abstraction.call_sites` still gates a helper extracted inside an existing structure. It does not gate a boundary this case already named.

Check the diff against the case you named once, after §4 when that round ran, before Optimize. A diff that drifted is corrected once to match the case, then the check §3 used is re-run. That correction does not re-enter §4, and it does not refresh this check. If it still does not match, return it (§0). On a match, go to Optimize. The typo tier skips this. A small fix names existing and confirms no new folder, layer, or pattern appeared.

## 2. Build lean

- Smallest change that fully achieves the goal. No scaffolding for futures nobody asked for.
- **The §1 task list is the scope boundary.** A file it doesn't name is out of bounds: spot a real problem there and you write it down and report it in §8 — you don't fix it in this change, however small the fix looks. The one exception is a file that genuinely blocks the work; then say out loud that you're widening the scope, and why, *before* touching it.
- No new abstraction, layer, or config option until there are `abstraction.call_sites` real call sites. A boundary Structure already named as new is the exception — that section owns it. A helper inside an existing structure is not exempt.
- Build the flexible version when flexibility is free — take the part that varies as a parameter, prop, or config value instead of freezing it into the body. "Flexible" means *not pinned down*, not *configurable for every imaginable future*. Free has a test: no extra file, no extra concept anyone has to be taught, and no more lines than pinning it down would have cost. Costs more than that and it isn't flexibility, it's an abstraction — and `abstraction.call_sites` decides whether that gets to exist at all.
- Extracting a component, helper, or module is not a violation of "smallest change" — a well-placed seam is often the smaller change. Reach for one when it removes duplication already in front of you or isolates the part that varies; don't reach for one to stage a future nobody asked for.
- **No hardcode.** Anything that names something outside the code — URLs, hosts, keys, IDs, paths, limits, env-specific strings, feature names — comes from config, a constant, or a parameter. Where the project already has a config surface (a typed options class, an env loader, a constants file), extend that one instead of opening a second.
- **Few inline literals.** A literal that appears more than once, carries meaning beyond its raw value, or would read as magic to the next person gets a name. A one-off literal whose meaning is obvious at the call site stays inline — naming it would cost more than it saves.
- **Short comments.** One line, saying *why*, not *what*, at the density the file around it already uses — don't strip a documented file bare or comment a terse one line by line. A comment that needs a paragraph is a signal the code or the naming is wrong — fix that instead. No commented-out code, no restating the line below it.
- Match the existing patterns, naming, and file layout of the codebase — don't introduce a second way to do the same thing.
- Before writing new code, search for an existing component, util, or helper that already does this — reuse or extend it before writing a new one.
- When this change needs the same logic, markup/UI, or type shape in 2+ places, extract a helper, component, or shared type now instead of duplicating it — that's real duplication already in front of you, not the hypothetical future the `abstraction.call_sites` rule above guards against.
- No new dependency when the stdlib or an already-installed package covers it.
- **Anything reaching an environment you don't solely control needs a known way back — before the first edit, not after the failure.** The exact revert command or rollback step, written down, and known to work; name it in §8 beside what changed. A dev cluster the team shares counts, not just production. If there genuinely is no way back — a one-way migration, a message already consumed, mail already sent — that is not yours to stop on: say so and return it to the caller (§0), because proceeding anyway is their call to make.
- **Anything irreversible gets confirmed before it runs** — dropping or rewriting data, a migration with no down path, a force-push, deleting files or branches, anything reaching an environment that isn't local. A permissive tool mode is not consent: say what will be lost, then wait for the answer.
- **A new config key isn't done until every surface has it.** Find them all — the typed options class, `.env.example`, the ConfigMap or Secret, the deploy manifest, CI variables — and add the key to each. Then name in §8 the ones a human still has to set by hand: a key that exists only on your machine passes every test and 500s in production.
- Avoid known perf/security footguns as you write, not after: N+1 queries, unbounded loops or payloads, secrets or PII in logs/client bundles, unsanitized input crossing a trust boundary.

## 3. Verify with evidence — never by assertion

- **Run it once before you change anything.** A test that was already red, a build that was already broken, a lint that already complained — without that first run you can't separate your breakage from the breakage you inherited, and you'll debug the wrong thing. What the project's docs claim about what builds is not evidence; the run is. A baseline that is already red is a finding, not a blocker: record exactly what was failing before you started and report it in §8 — but don't fix it unless it blocks you (§2). Green-after means nothing if you can't say what red-before looked like.
- Actually run something: the test, the build, the lint, the script, the page.
- **New behavior needs a test that fails without the change.** A test that is green both before and after proves nothing — run it against the baseline above to prove it actually catches the thing you just built.
- **`build.max_cycles` caps the build→verify loop.** The same thing failing twice for a *different* reason means the approach is wrong, not the code: stop patching symptoms and step back — and if the rethink is a decision rather than a fix, return it (§0). Hitting the cap is a stop, not a budget; say what still fails and what you'd try next.
- Read the full diff before declaring anything done.
- Report the concrete result (test output, command exit, screenshot), not "should work".
- **Verify the target environment before testing against it.** Once you have *checked* that it's a dev environment, test it hard — smoke runs, real requests, writes, restarts, whatever the change deserves. Checked means you ran something that names the target (the cluster context, the namespace, the host, the connection string) and read the answer back; inferring it from a branch name, a file you opened, or a config labelled "dev" somewhere is not checking. Not verified, or only fairly sure → ask before the first smoke test, not after it.
- Touched auth, input handling, the rendering of user-controlled data, secrets, or anything crossing a trust boundary → also run `security-review` before calling it done. Rendering counts: most injection arrives on the way out, through a template or an `innerHTML`, not on the way in.
- Touched UI or user-visible behavior → also use `run` (or `web-design-guidelines` for a UI-standards pass) to see it working in the real app, not just green tests.
- **The named skill isn't there, or can't run as written** — the harness has no such skill, or bans the sub-tasks it spawns → run its substance in-session. Security: walk the diff against the trust-boundary list above — an authorization check on every newly reachable path, input validation, output encoding where user data renders, secrets kept out of logs and client bundles — and report each finding with file and line. UI: drive the real app yourself (dev server plus a browser or screenshot tool, or a temporary probe that mounts the component), then delete the probe. Either way, point it at this change's diff (working tree plus staged), not the last commit. Name the fallback in §8 and don't call it the skill. Nothing can drive the real app → say so; green tests don't stand in for it.

## 4. Self-review — maximum effort

Review deliberately, not repeatedly. `review.rounds` pass(es) at `review.effort`, thinking at full depth, beats several cheap re-reads by the model that just wrote the code — that model is the worst reviewer of its own work.

- **Delegate it** — §5 owns the mechanics of spawning, briefing, and the harness-forbids-it fallback, and its standing authorization covers this round. A missing "use a subagent" in the current message is not a ban. What this pass buys is depth, not a different nameplate: spend it on effort, not on model shopping. Claude Code: `Agent` tool with `subagent_type: "general-purpose"` and **no `model` override** — the review runs on the session's own model, and never on Fable. Open the prompt with `ultrathink` so it runs at `review.effort`. On any other harness, select the deepest thinking mode available and leave the model alone. **The reviewer reads and reports; it never edits.** Fixing is the main session's job — a reviewer that patches its own findings puts changes into the diff that nobody reviewed, and collides with §5.
- **Brief it properly.** The reviewer doesn't share this session's context: give it the one-sentence goal from §1, the full diff (`git diff`, plus `--staged` if anything is staged), and the surrounding files it should read. Ask for concrete findings — file, line, what breaks — not a grade.
- **Every pass covers all three dimensions:**
  - *Correctness* — edge cases, empty/null inputs, error paths, off-by-one, async ordering, resource cleanup, security (auth checks, input trust), performance (extra queries/renders, unbounded work the change introduced).
  - *Fit* — dead code, leftover debug output, naming, broken callers, structure and file placement matching project convention, anything the change silently regressed.
  - *Cross-stack contract* (skip if the change touches only one side) — do the request/response shape, field name, type, and error format actually match on both ends? A frontend type and a backend response can each look correct in isolation while drifting apart; diff the real payload/type against what the other side sends or expects, don't just re-read each side separately.
- **Ask what should be there and isn't.** A diff can only show what was written; these get missed precisely because nobody typed them — rate limiting or lockout on anything guessable, an authorization check on a path that just became reachable, an upper bound on payload size and page size, a timeout and a retry cap on every outbound call. A new surface usually needs a control no one wrote.
- **Findings are evidence, not verdicts.** The reviewer lacks this session's context and will sometimes be wrong. Check each finding against the code before acting on it, and name the ones you rejected and why. "Fixing" a finding you don't believe makes the code worse and buries the findings that were real.
- Fix what it finds and re-run §3. Send it back beyond `review.rounds` only if the fixes amount to a new change of their own — otherwise `review.rounds` is the whole loop. A correction the Structure check makes is not that new change.
- **`review.max_rounds` is a hard ceiling, not a budget to spend.** Hitting it is a signal, not a step: stop delegating, say plainly that the change has outgrown one review cycle, and hand the caller (§0) the findings that are still open plus what you'd do next. Re-reviewing past the ceiling hides a scope problem instead of surfacing it.
- A clean pass means the process is clean, not that the goal is met. Before moving on, confirm the one-sentence goal from §1 is actually satisfied, not just that no more issues turned up. Then run the Structure check on the diff, then Optimize — a correct diff the caller still has to clean is not done.

## Optimize — one pass, then stop

§4 asks what breaks. This asks what the caller will still want to delete once the change is correct. A finding §4 already fixed is not done again here.

Run it on the diff you are about to hand over, after §4 when that round ran, and after §3 has been re-run for any fix that landed. The session that holds the goal runs it — it edits, so it is not delegated and it is not a second review. The typo tier skips it. A small fix runs it only on the lines the change touched.

Three moves, in order:

1. **Remove.** Dead code, unused names, debug leftovers, a branch the final shape made unreachable, a comment that restates the next line. If removing it does not change behavior, it goes. Orphans this change created go; pre-existing dead code stays and is named in §8.
2. **Collapse.** A helper, parameter, or branch this change added that now has a single call site and no reason to vary. Inline it. A seam Structure named as load-bearing stays, including when it has one call site. Do not add an abstraction, a config key, or a layer to make the diff cleaner.
3. **Bound the cost this change introduced.** An N+1, an unbounded loop or payload, a query or render that now runs per item with no cap. Fix those in place. A cache, an index, a pool, or a new dependency needs a measurement named in the §8 report. No measurement, no speed rewrite.

Out of scope: behavior the goal didn't ask for, files the task list doesn't name, and anything that changes what the tests assert. A move that would need a new or changed test is skipped and named in §8. It does not go back to §3 — going back reopens the walk, and §4 would run this pass again.

After the three moves, re-read the diff and re-run the check §3 already used. Green means the pass kept behavior. Red means revert the move that broke it — do not patch forward. An orphan the pass itself just created (an import left behind by a removal) is still this pass. Then stop. `optimize.passes` is the whole budget. Anything you still see and did not do is named in §8 — it is not a reason to walk the diff again, and not a question for the caller.

## 5. Split across agents — when it actually pays

**Subagents are allowed. Open one when it makes the work faster.** This section is the user's standing request to spawn: where a harness says not to call the agent tool unless the user asked, this is that ask; where it already allows spawning, this adds nothing. Don't wait for the word "subagent" in the current message. Use whatever spawn the harness actually has (Claude Code: `Agent`; Cursor: `Task`) and leave the model alone unless the user named one.

A second agent still costs a cold start: it shares none of this session's context, so everything it needs must be written out, and everything it learns comes back as a report. Pay that cost for a read across areas, the §4 review, or a build slice that is already independent. Don't pay it for a lookup one search would finish, or because the task merely has several parts.

**Do not duplicate another task.** Speed is doing the undone part once. Before the first spawn, name the work already in flight — this session's other slices and any agent already running, plus other sessions visible in the working tree, `HANDOFF.md`, or the branch. A slice that repeats that work is a no, even when the files don't overlap: don't re-search it, re-review it, or re-edit it. Skip it or wait for the owner. Don't start a twin.

**Before any split, run the risk pass — and write it down.** Splitting is itself a decision with a blast radius; deciding it in your head is how two agents end up in the same file, or on the same job. Five questions, answered out loud in the plan (§1) before the first agent is spawned:

1. **Whose work is this already?** Name every in-flight task that could own the slice. If one of them already owns the job, do not spawn. This is duplication, not a file collision — the questions below do not catch it.
2. **What does each slice touch?** List the files, and the shared surfaces behind them — the same type or schema, the same route table, the same config key, the same migration chain, the same lockfile, the same generated artifact. Two slices that never share a *file* can still collide through any of these.
3. **Where would they interfere?** Working tree and git index, build and test caches, ports and dev servers, a database or dev cluster, rate-limited external calls. Name the collision, then name what keeps it from happening — a worktree, a separate port, a serialized step.
4. **What breaks if one slice fails or goes wrong halfway?** If the answer is "the other slice is now built on something that doesn't exist", they were never independent. If it's "we throw that worktree away", the split is safe.
5. **Is it cheaper serialized?** The honest answer is often yes. Say so and serialize — a fan-out that saves ten minutes and costs an hour of integration is a loss. Duplicating an in-flight task is never the cheaper path.

Any question you can't answer concretely is a **no**: serialize, and say why in §8. An unanalyzed risk is not a small risk — it's an unknown one, and §0's rule applies: if the split itself is the open decision, it goes back to the caller.

**Three shapes, in order of how safe they are:**

- **Read fan-out — always available.** Independent read-only work: searching several areas, comparing approaches, auditing multiple files, reading another repo. Run up to `parallel.max_agents` at once. This also preserves the main session's context on long tasks, which is half the reason to reach for it.
- **Review fan-out — §4's round.** Same mechanics as here; §4 owns the rules for it. More than one reviewer only when the dimensions are genuinely separate (correctness vs. cross-stack contract, say), never the same brief twice for a second opinion.
- **Build fan-out — the narrow one.** Two agents editing at once is allowed only when every condition below holds. Any one missing → serialize, and say in §8 that you did.
  - **Disjoint file sets, decided up front.** Each slice names the files it owns; one file has exactly one owner. Overlap isn't negotiated mid-flight — it's a sign the split is wrong.
  - **Each slice is at least `parallel.min_slice` of work.** Below that, briefing costs more than doing it.
  - **No slice depends on another's output.** A slice that needs the shape of what another agent is still writing is a sequence, not a fan-out.
  - **Shared state is isolated — every item the risk pass named.** Concurrent edits in one working tree collide over the index, the build cache, and the dev server. Give each builder its own git worktree where the harness offers one (Claude Code: `isolation: "worktree"` on the `Agent` call, or an explicit worktree tool). Never let two of them run the same dev server, migrate the same database, commit or push on the same branch, or edit the same lockfile. Anything that genuinely cannot be isolated — one shared dev cluster, one external account with a rate limit — is not a thing to coordinate around: it stays with the main session, done once, before or after the fan-out.
  - **Nobody commits, pushes, or deploys from inside a slice.** Builders leave their work in their own tree and report; landing it is the main session's job, in one place, in an order it chose.

**Brief every agent the same way, whatever the shape.** It knows nothing you haven't written down: the one-sentence goal from §1, its slice and the files it owns, the repo constraints from §1 that bind it, the in-flight tasks it must not redo, what "done" looks like, and what to report back. Tell it explicitly what is *not* its slice — the common failure is an agent helpfully fixing something two slices over, or redoing a task another session already owns.

**A subagent that hits an open decision returns it — it does not decide.** §0 applies inside the fan-out exactly as it applies at the top: the sub-agent hands the question back to you, you either answer it from context you hold or return it further to your own caller. An agent that guesses past a decision produces a diff nobody agreed to, and you find out at integration.

**You own the merge, and nothing an agent reports is evidence until you've seen it here.** Per-slice green proves the slices, not the change. After the last one lands: read the combined diff yourself, re-run §3 against the integrated tree, and run §4 on the whole diff — not once per slice. Integration is where disjoint-looking slices turn out to share a type, a route, or a config key.

**An unconditional ban still outranks this file.** "Unless the user asked" does not — this section is that ask, so spawn and name the shape in §8. A ban with no such exception collapses every shape to sequential in-session work: do it, say so in §8, and offer the delegated round rather than claiming it ran.

**`HANDOFF.md` stays single (§6) when the work fans out.** One note, with a line per slice: who owns it, which files, which worktree, and where it stopped. Notes per agent drift, and the one you resume from is never the current one.

## 6. Long-run continuity

Only files on disk and git state survive a new session. Nothing else carries over.

**Maintain `HANDOFF.md` at the repo root** for any task spanning more than one sitting. Skip this section entirely for a task that finishes in the current sitting — don't create or touch the file for single-sitting work just because this skill runs on every task. Update it the moment each step finishes — not at the end — so an interrupted run still leaves a current note:

```markdown
# HANDOFF
updated: <timestamp>

## Goal
<one line>

## Steps
- [x] 1. ...
- [ ] 2. ...   <- current

## State
branch: <branch>   last commit: <sha>
uncommitted: <files>

## Decisions
- chose X over Y because ...

## Next action
<the exact command or edit to do next>

## Blockers
- <if any>
```

**Write the note early, not when you need it.** Create `HANDOFF.md` as soon as any of these is true, whichever comes first — an interruption is not the moment to start writing one:

- more than `handoff.steps_left` steps still open, or one step you can't finish in a single go (a long build, a deploy, a review round);
- remaining context is under `handoff.context_left`, or the session has been compacted `handoff.compactions` time(s);
- about to start anything irreversible or long-running;
- a rate limit, `/clear`, or an interrupt already in sight.

The single-sitting skip above lapses the moment any of these becomes true — a task that grew past one sitting gets its note retroactively, reconstructed from `git diff` and `git log`. Writing it costs a few hundred tokens; not writing it costs the whole session's state. The note is a checkpoint, not a stopping point. Context summarized by the harness still loses what isn't on disk, so the note matters whether or not the harness compacts. If it turns out the work finishes in this sitting, delete the file in one line at the end.

**Work spanning more than one repo gets one note, not one per repo.** Put `HANDOFF.md` in the repo where the build is driven, and name the other repos in it along with what is pending in each. Separate notes drift apart, and the one you resume from is never the one that was current.

**When resuming, never trust the note on its own.** Read `HANDOFF.md`, then confirm against reality — `git status`, `git diff`, `git log -5`, and run the tests. Where they disagree, the repo wins: correct `HANDOFF.md` first, then continue. A previous run may have been cut off before it could update the note.

**When a session ends or a rate limit interrupts work,** keeping `HANDOFF.md` current is the whole job — resuming is then just a new session pointed at that file, which costs less than dragging a long, bloated session forward. Schedule a wake-up (`send_later`, or a scheduled task naming the file's absolute path) only when nobody will be at the keyboard when work can resume.

**`HANDOFF.md` tracks one known route — it is not a planning tool.** If step 1 shows the work is still a field of open decisions rather than a sequence of steps, branching and too large to settle in one sitting, don't force it into a handoff note. Stop and return it to the caller (§0) — charting is their call to make, and a handoff note is the wrong container for it. Come back here to build once the decisions are settled. If you are the end of the line with no caller to return to, propose a charting pass yourself and name the one you'd use.

## 7. Audit — did the walk actually happen

§4 reads the diff; this reads the session. Almost every entry in `FRICTION.md` is a step that was skipped or half-done rather than a line of code nobody checked — and nothing in the skill noticed at the time. This is what notices.

- **Run it in-session, from your own transcript, before the report.** Never delegate it: a subagent sees the diff, and a step that never happened leaves nothing in a diff to see. It re-reads what you already did, so it costs a fraction of §4 — and it does not stand in for §4, it is what catches §4 going missing.
- **Scale it with §1's tier**, exactly like every other section.
- **Each line ends settled — done, fixed now, or named in §8 as deliberately skipped** with the tier that allowed it. Mentioning a step is not doing it: a missing §3, §4, Structure, or Optimize that this change actually needed means go and run it.
- **Audit the rules that are here, not the ones this session wishes were here.** A gap with no rule behind it is a `FRICTION.md` line, not a checklist item you add on the spot — same reason the skill doesn't edit its own rules mid-task.

What to walk:

- §0 — every open decision went back to the caller. Nothing was guessed past.
- §1 — the goal was said out loud before the first edit, and it is still the goal being built to.
- §1 — the repo's standing constraints were read, not only the scope-matched docs.
- Structure — the case was named before the first edit. Existing, including a refactor: no new folder, layer, or pattern. New: the diff matches the boundary and interface named beforehand, and that seam was not collapsed. The check ran once; a correction did not re-enter §4.
- §2 — every file touched is on the task list, or the widening was said out loud *before* it was touched.
- §2 — anything reaching a shared environment has its way back written down; anything irreversible was confirmed before it ran.
- §3 — the baseline came from a run before the change, not from what a doc claims builds.
- §3 — the test that proves new behavior was actually seen red against that baseline, not assumed to be.
- §3 — the full diff was read, and every result reported is a concrete one (output, exit code, screenshot).
- §3 — UI or user-visible change → seen working in the real app; auth, input handling, rendering user-controlled data, or secrets → `security-review` ran, or §3's in-session fallback ran and §8 names it.
- §4 — the delegated round ran at `review.effort` with no model override, findings were checked against the code, and rejected ones named. The harness forbids spawning agents → say so in §8 and offer the round; a self-read does not count as one.
- Optimize — one pass ran on the diff that shipped, or the tier skipped it and §8 says so. The check §3 used was re-run after the moves and was green, or the breaking move was reverted. A move that would have changed a test was skipped and named. A speed change names its measurement. The pass did not run a second time.
- §5 — a subagent ran only on work no other in-flight task already owned; a duplicate was skipped and named. Where the harness had an "unless the user asked" clause, it was treated as satisfied. An unconditional ban → said so in §8.
- §5 — work was split only after the risk pass was written down, and no two agents touched the same file or shared surface.
- §5 — per-slice results were re-verified on the integrated tree; nothing was reported green on a slice's word alone.
- §6 — `HANDOFF.md` matches where the work actually is, or is gone because the work finished here.
- Never — no claim in the report rests on a search you cut short or a document you didn't run.
- **Friction** — this skill's own log lives beside this file, `FRICTION.md` next to `SKILL.md`. At the *end* of every task, append one dated line: what the task was and how it ended. Add a second line only when a rule here failed you — didn't fire when it should have, fired wrongly, or there was simply no rule. Logging only the failures gives a numerator with no denominator, and no rate can be read from it. Never edit the rules themselves from inside a task: the session that just got burned is the worst judge of what the rule should be. This one file is exempt from §9's ask-first rule because it only records observations and changes no behaviour; `FRICTION.md` carries its own bar for what may later be promoted into a rule.

## 8. Report

What changed (files), why, and how it was verified — in a few lines. §7 already established what was done, skipped, and still open — this says it out loud, gaps included, rather than establishing it a second time.

**How the output reads** — this applies to every message that reaches the user, not only this section: reports, questions, and returns (§0).

- Emoji are signal, not decoration. One on a heading, a status, or a question, where it tells the reader at a glance what kind of thing they are looking at — ✅ done · ⚠️ risk · ❓ needs an answer · 🔴 blocked · 📋 plan. Never inside code, file paths, commands, or command output.
- **Gloss every technical term the first time it appears in a message.** An English term carries the Thai in parentheses — `rollback (ย้อนกลับ)`; a Thai term carries the English — `ขอบเขตชื่อบนคลัสเตอร์ (namespace)`. Use whichever order reads naturally; the point is that neither language is the one the reader has to guess at.
- Gloss for meaning, not word-for-word. A translation more confusing than the term it explains is worse than none — leave such a term bare rather than inventing a word nobody uses.
- Gloss once per message, not on every mention.

If this change affects documented behavior (a route, an API contract, a decision, a convention), flag it and ask the user which doc is authoritative for it and whether it needs updating — don't edit docs by default alongside code. See §9 for what to do once they say yes.

## 9. Doc hygiene — keep docs from bloating

- Docs are edited only on the user's go-ahead, never by default. If a change looks like it makes a doc stale, say so and ask which doc is authoritative and whether to update it — only touch it after they confirm it's actually necessary.
- One topic per doc. When a doc has bloated or its scope has grown too wide to read in one pass, that's the one exception to the ask-first rule above — split it automatically: turn it into a folder, one file per topic, no need to ask first since this only reorganizes existing content rather than changing it. Then update whatever router/index points to it so the split doesn't orphan a topic.
- This work depends on or connects to another project/repo/service (a shared package, an API another repo owns, a cross-repo contract) → say so, and ask whether it's worth recording as a reference doc for future work that spans both. Same go-ahead rule as above — note the connection, don't write the doc unasked.
- Scratch or agent-only artifacts that aren't meant for human discovery (self-review notes, in-progress splits, working drafts) → keep them in a `.leancode/` folder at the repo root instead of scattering them into the docs tree. `HANDOFF.md` (§6) is the one exception — it stays at the repo root itself, precisely so it's the first thing found when resuming interrupted work.
- New doc → use a minimal skeleton, skip sections that don't apply:

```markdown
# <Topic>
<one line: what this doc governs>

## Rule
<the decision/convention, stated plainly>

## Why
<the constraint or reasoning that shaped it>

## Related
- <links to the code, other docs, or tickets this connects to>

## Open
- <unresolved edges, if any — omit this section entirely if none>
```

- This skeleton is deliberately project-agnostic so it holds up when this skill moves to another agent or repo — adapt section names to match whatever doc convention the project already has (check its router first, per §1) rather than forcing this shape on top of an existing one.

## Never

- Declare done without having run something.
- Leave work half-finished without saying so.
- Edit a doc without the user's go-ahead — except the automatic split in §9 when a doc has bloated.
- Run something irreversible without confirming it first — a permissive tool mode is not consent.
- Smoke-test an environment you have not verified is dev.
- Split work across agents without the §5 risk pass, or let two of them edit the same file, branch, or shared surface.
- Open a subagent on work another in-flight task already owns.
- Guess past an open decision instead of returning it to the caller (§0).
- Claim high confidence without evidence to back it.
- Rewrite for speed without a measurement named in the §8 report.
- Invent a new folder, layer, or pattern on a refactor.
- Edit this file without bumping `version` and adding a Changelog line.

## Changelog

- 2.7.1 (2026-09-24) — §7 audit line for §5 matches 2.7.0's conditional wording

- 2.7.0 (2026-09-24) — harness-neutral wording: §2 comments follow the file's density; §5 standing ask applies only where a harness bans spawning; §6 note is a checkpoint, needed with or without compaction

- 2.6.0 (2026-09-24) — §3: in-session fallback when `security-review` or `run` is missing or can't spawn, aimed at this change's diff; §7 accepts it when named
- 2.5.0 (2026-09-23) — Structure: name new or existing before the edit. A named new boundary is exempt from `abstraction.call_sites`; one correction does not reopen §4. A refactor keeps the structure already there
- 2.4.0 (2026-09-23) — Optimize, one pass after §4: remove, collapse, bound a cost this change introduced. No speed rewrite without a measurement
- 2.3.0 (2026-09-23) — §5 authorizes subagents for speed; a slice that repeats another in-flight task is a no. "Unless the user asked" counts as asked
- 2.2.0 (2026-09-22) — §5 rewritten: mandatory pre-split risk pass, three fan-out shapes, non-interference and isolation rules, main-session-owns-merge
- 2.1.0 (2026-09-22) — require a version bump + changelog line on every SKILL.md edit
- 2.0.0 (2026-09-21) — first numbered snapshot of the evolved walk (tunables, §0–§9, FRICTION.md)
