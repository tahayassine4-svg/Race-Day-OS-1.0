# AI-Orchestrated App Development System

This is a reusable orchestration system for building applications (web, mobile, and native) through a sequence of specialized AI agents. Every session reads this file first to determine the current state and activate the correct agent.

---

## System Overview

Nine agents collaborate in a fixed sequence to take a raw app idea all the way to committed, tested, reviewed code — with Yassine (Engineering Manager) as the decision-maker at every gate.

**Standing rules — non-negotiable:**
- **Design before code.** No UI is ever implemented before its rendered design mockup (`design/*.png`) is approved by Yassine at the Design Gate. The Designer builds an HTML mockup, renders it to an image, and shows it first. (Backend/data-only packets skip the Design Gate.)
- Never skip a gate. Every gate requires explicit approval from Yassine before proceeding.
- Never run two agents in parallel. Agents are sequential within each packet.
- Always read `docs/vision.md`, `docs/stack.md`, `docs/ui-system.md`, and the active `tasks/packet-NN.md` before acting.
- Never implement anything not defined in the current packet.
- **Baseline first.** Establish a green build/tests before editing, so you can tell if your change broke something.
- **Verify visually.** UI is confirmed by screenshotting the running app (simulator or headless browser) against the approved mockup — never by reading source.
- **Protect user data.** If the app is already shipped (TestFlight/production) with real data, every persistence/schema/migration change must preserve it, proven by a migration test that loads an old-schema store with data. A code-level default is not a store-level default — test, don't assume.
- **Use the advisor** before committing to a non-trivial approach and before declaring work done.
- When blocked or uncertain, surface the issue to Yassine. Do not improvise silently.

---

## The Workflow Loop

```
[App idea — Yassine describes it in 2-3 sentences]
          ↓
     [ARCHITECT]  →  docs/vision.md + docs/stack.md + initial dev plan
          ↓
    ⏸ GATE 1: Yassine approves plan and stack
          ↓
      [PLANNER]  →  tasks/packet-01.md … tasks/packet-NN.md
          ↓
    ⏸ GATE 2: Yassine approves the packet sequence
          ↓
    ┌─────────────────────────────────────────┐
    │         For each packet, in order:       │
    │                                          │
    │  [DESIGNER]  →  docs/ui-system.md +      │
    │     design/packet-NN.png  (if UI)        │
    │       ↓                                  │
    │  ⏸ DESIGN GATE: Yassine approves the     │
    │     rendered mockup (skipped if no UI)   │
    │       ↓                                  │
    │  [IMPLEMENTER]  →  code, built to match  │
    │       ↓                                  │
    │   [TESTER]  →  tests + results           │
    │       ↓                                  │
    │  [UI-REVIEWER]  →  (if UI changed)       │
    │       ↓                                  │
    │  [CODE-REVIEWER]  →  quality review      │
    │       ↓ (fail → back to IMPLEMENTER)     │
    │  [GIT-MANAGER]  →  commit + push + PR    │
    │       ↓                                  │
    │   [REPORTER]  →  reports/packet-NN.md    │
    │       ↓                                  │
    │  ⏸ GATE 3: Yassine reviews report,       │
    │    approves merge, decides next packet   │
    └─────────────────────────────────────────┘
```

---

## Agent Roster

| # | Agent | Prompt file | Trigger | Produces | Gate after |
|---|---|---|---|---|---|
| 1 | Architect | `prompts/architect.md` | New app idea | `docs/vision.md`, `docs/stack.md`, dev plan | GATE 1 |
| 2 | Planner | `prompts/planner.md` | GATE 1 approved | `tasks/packet-NN.md` files | GATE 2 |
| 3 | Designer | `prompts/designer.md` | GATE 2 / any UI packet | `docs/ui-system.md`, `design/packet-NN.png` (rendered mockups) | **DESIGN GATE** |
| 4 | Implementer | `prompts/implementer.md` | DESIGN GATE approved (or backend packet) | Code, built to match the mockup | → Tester |
| 5 | Tester | `prompts/tester.md` | Implementer done | Tests + results (incl. migration/data-safety + visual checks) | → UI-Reviewer or Code-Reviewer |
| 6 | UI-Reviewer | `prompts/ui-reviewer.md` | Tester done (UI changed) | UI validation vs approved mockup | → Code-Reviewer |
| 7 | Code-Reviewer | `prompts/code-reviewer.md` | Tester (+ UI-Reviewer) done | Review against `reviews/*.md` | Pass → Git-Manager / Fail → Implementer |
| 8 | Git-Manager | `prompts/git-manager.md` | Code-Reviewer passes | Commit + push + PR | → Reporter |
| 9 | Reporter | `prompts/reporter.md` | Git-Manager done | `reports/packet-NN-report.md` | GATE 3 |
| — | **ICP** | `prompts/icp.md` | **On-demand** — invoke any time | `reports/icp-session-[date].md` | None (report to Yassine) |

> **ICP agent is on-demand.** Invoke with: "Run ICP session" or "Run ICP on [specific flow]". It reads `docs/icp.md` for the persona — update that file when the project changes.

---

## How to Invoke Each Agent

When activating an agent, read its prompt file and follow it exactly:

- **Architect:** Read `prompts/architect.md` — ask one tight round of clarifying questions, then produce `docs/vision.md` and `docs/stack.md`.
- **Planner:** Read `prompts/planner.md` — read `docs/vision.md`, produce all `tasks/packet-NN.md` files.
- **Designer:** Read `prompts/designer.md` + `reviews/design.md` — for any UI packet, write `docs/ui-system.md`, build an HTML mockup, render it to `design/packet-NN.png`, show it, and HALT at the Design Gate. Skip for backend-only packets.
- **Implementer:** Read `prompts/implementer.md` — read the active packet and the approved `design/packet-NN.png`, implement only what is specified, built to match the mockup.
- **Tester:** Read `prompts/tester.md` — run all tests defined in the packet's acceptance criteria.
- **ICP:** Read `prompts/icp.md` + `docs/icp.md` — embody the persona, walk the live app, produce `reports/icp-session-[date].md`.
- **UI-Reviewer:** Read `prompts/ui-reviewer.md` — validate UI renders correctly and is responsive.
- **Code-Reviewer:** Read `prompts/code-reviewer.md` — check against `reviews/frontend.md` or `reviews/backend.md`.
- **Git-Manager:** Read `prompts/git-manager.md` — commit, push to feature branch, open PR.
- **Reporter:** Read `prompts/reporter.md` — write `reports/packet-NN-report.md`, present clean summary.

---

## Current State

> **This section is updated after every packet. It is the single source of truth for resuming work across sessions.**

**Project:** Race Day OS
**Last completed:** Packet 07 — Live Race Day ✅
**Last report:** `reports/packet-07-report.md`
**Current packet:** None — Packets 08 + 09 complete
**Status:** ⏸ GATE 3 — awaiting Yassine review

**Git:** Branch: `main`. Remote: `git@github.com:tahayassine4-svg/Race-Day-OS-1.0.git`. Pushed through `8062706`.

**Next session command:** "Continue from where we left off" or "Read Current State and resume workflow"

---

**Session log:**

| Date | Packet | Outcome | Notes |
|---|---|---|---|
| 2026-05-22 | 01 — Foundation & Auth | ✅ PASSED | Build + types clean. 3 runtime criteria need live Supabase env. npm used (not pnpm). |
| 2026-05-22 | 02 — Race & Course Setup | ✅ PASSED | Build + types clean. 6 runtime criteria need live Supabase. Git initialized; Packets 01+02 in one initial commit. |
| 2026-05-22 | 03 — Pacing Engine | ✅ PASSED | Build + types clean. Pure engine, 3 scenarios, inline overrides. All acceptance criteria verified in code. |
| 2026-05-22 | 04 — Fueling Planner | ✅ PASSED | Build + types clean. Pure engine, global targets, per-segment overrides, notes-on-blur. |
| 2026-05-22 | 05 — Crew & Checklists | ✅ PASSED | Build + types clean. Crew CRUD, station assignments, checklist cards with task reorder + preview. |
| 2026-05-22 | 06 — Crew Magic Link | ✅ PASSED | Build + types clean. Public /crew/[token] dashboard + station card, arrival logging, condition notes, ?crew= param. |
| 2026-05-22 | 07 — Live Race Day | ✅ PASSED | Build + types clean. Supabase Realtime, live projections, status badges, projected finish, ETA. /races/[id]/live added. |
| 2026-05-23 | 08 — GPX + Excel Import | ✅ PASSED | recharts + xlsx installed. Dual drop zones, client-side parse, 0.5 km dedup merge. saveImportData auth-gated. |
| 2026-05-23 | 09 — Segment Builder | ✅ PASSED | Elevation chart, interactive table, validateDrafts, confirmImport transaction. Redirects to pacing on confirm. |

---

## Starting a New Session

At the start of every session:

1. Read the **Current State** section above — this tells you exactly where to resume.
2. Read `reports/packet-NN-report.md` for the last completed packet to understand what was built and any open issues.
3. Read `tasks/packet-NN.md` for the current packet to understand what to build next.
4. State your mode and confirm with Yassine: "Resuming from [status]. Ready to [next action] — continue?"

If `## Current State` shows `Status: ⏸ GATE 3` (or any gate), wait for Yassine's "go" before activating the next agent.
If no `docs/` files exist: "No project found. Activating ARCHITECT — tell me about your app idea."

**After every packet, update Current State:**
- Set `Last completed` to the packet just finished
- Set `Last report` to the new report path
- Set `Current packet` to the next packet
- Set `Status` to the correct gate or agent
- Add a row to the session log
