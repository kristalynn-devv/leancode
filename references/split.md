# Splitting work across agents
Read by SKILL.md §5 before any split beyond one read-only agent. Everything here is §5; section references point back into SKILL.md.

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

**`HANDOFF.md` stays single (§6) when the work fans out.** One note, with a line per slice: who owns it, which files, which worktree, and where it stopped. Notes per agent drift, and the one you resume from is never the current one.
