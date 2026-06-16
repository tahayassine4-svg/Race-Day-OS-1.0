---
name: resume-app
description: Figure out exactly where development of a given app left off and continue from there. Use whenever Yassine says to "continue working on", "resume", "pick up", "get back to", or "keep going on" a specific app (e.g. "continue the Getting Money app"). Reads that app's state, packet index, and all reports, reconstructs the last completed step and the next one, reports the resume point, and waits for direction.
---

# Resume App — find the last step and continue

This skill runs the **SESSION_INIT** phase of the iOS App Factory for one named app. Its job is to reload full context for an app that was worked on earlier, determine precisely where work stopped, and continue from that point — never guessing, never restarting from scratch.

Start your response with `**Phase: SESSION_INIT**`.

## 1. Identify the app

From Yassine's message, resolve which app he means. Match loosely (e.g. "Getting Money", "gettin money", "the money app" → `apps/getting-money`).

- Primary location: `apps/<name>/` (current factory layout).
- Legacy apps live at the repo root: `GettinMoney/`, `project-tracker-ios/` (live on TestFlight — never disturb its store/build), `calisthenics-rep-tracker-ios/`.

Run `ls -1 apps/` and check the root for legacy folders. If the name is ambiguous or no app matches, list the available apps and ask which one — do not assume.

## 2. Read everything (in this order)

For the resolved app folder, read these in full. Do not skim — this is the whole point of the skill.

0. `MANIFEST.json`, if present — the fast, structured resume pointer (`phase`, `packet`, `packet_branch`, `tests`, `code_review`, `ui_review`, `git`, `blockers`, `handoff_needed`). Read this first; it's what the rest of this step verifies and narrates. If `handoff_needed` is true, read `docs/handoff.md` next, before anything else. If `MANIFEST.json` doesn't exist yet, fall back entirely to the prose sources below.
1. `docs/state.md` — the canonical prose resume pointer. Note `phase`, `packet`, `status`, `last_action`, `next_step`, `branch`, `commit`, `timestamp`.
2. `tasks/packet-index.md` — the full packet sequence and each packet's status (COMPLETE / in progress / not started), branch, and commit.
3. **Every** report in `reports/` — read them in order (`packet-01-report.md` … latest). The latest report is the most detailed account of where things stand; earlier ones give the arc. Also scan for any `*-escalation.md` (a stalled packet handed to Yassine).
4. The active or next `tasks/packet-NN.md` — the packet identified as in-progress or the next not-yet-started one, so you know its acceptance criteria before proposing work.
5. Context docs as needed to act correctly: `docs/vision.md`, `docs/stack.md`, `docs/ui-system.md`, `docs/decisions.md`.

Then read the governing rules so you resume in-system, not freelance:
- The repo `CLAUDE.md` (workflow loop, gates, agent roster) — already in context, re-check the relevant parts.
- The definition for whatever phase comes next, per `WORKFLOW.md`'s Agent Roster table — either a coordinator skill (e.g. `/planner` at `.claude/skills/planner/SKILL.md`) or a `.claude/agents/<name>.md` subagent (e.g. `.claude/agents/implementer.md`) — plus the `.claude/rules/` file it lists.

## 3. Cross-check state against reality

`MANIFEST.json`/`state.md` record what was *intended* at handoff; verify against the actual repo before trusting it:

- `git -C <repo root> log --oneline -8` and `git status` — confirm the recorded branch/commit exist and whether there's uncommitted work.
- Confirm the files the last report claims to have created/changed actually exist.
- If the app is shipped (TestFlight/App Store), re-read the data-safety rule in `CLAUDE.md` and treat any persistence/schema change as migration-gated.

If state and reality disagree (e.g. state says a packet is COMPLETE but its work isn't committed, or a commit is referenced as "committing now"), flag the discrepancy explicitly — that gap is usually exactly where work stopped.

## 4. Report the resume point and HALT

Produce a tight resume report, then stop and wait for Yassine's direction. Do not start building, committing, or advancing past a gate without his explicit "go".

```
Resuming app: <name>
Last phase:   <phase>
Packets:      <N complete> / <total>  (last completed: <NN — name>)
Active packet: <NN — name>  |  none — all packets complete
Last action:  <one line from the last report / state>
State vs repo: <consistent | discrepancy: …>
Next step:    <the concrete next action — next packet to build, a gate awaiting
              approval, an escalation needing a decision, or "v1 complete; next
              is X">

Continue from here, or change direction?
```

After Yassine confirms, hand off to the correct next phase/agent per the factory loop (read that agent's prompt first) and proceed one agent at a time, honoring every gate.

## Notes

- This skill only **orients and resumes** — it does not skip gates, redo completed packets, or invent new scope.
- If the app has no `docs/state.md` or `reports/` yet, say so: it was likely never started past ARCHITECT/PLANNER, and the next step is whichever earlier phase is missing.
