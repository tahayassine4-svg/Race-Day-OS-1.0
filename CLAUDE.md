# AI-Orchestrated Web App Development System

This is a reusable orchestration system for building web applications through a sequence of specialized AI agents. Every session reads this file first to determine the current state and activate the correct agent.

---

## System Overview

Eight agents collaborate in a fixed sequence to take a raw app idea all the way to committed, tested, reviewed code — with Yassine (Engineering Manager) as the decision-maker at every gate.

**Standing rules — non-negotiable:**
- Never skip a gate. Every gate requires explicit approval from Yassine before proceeding.
- Never run two agents in parallel. Agents are sequential within each packet.
- Always read `docs/vision.md`, `docs/stack.md`, and the active `tasks/packet-NN.md` before acting.
- Never implement anything not defined in the current packet.
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
    │  [IMPLEMENTER]  →  code in app/          │
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
| 3 | Implementer | `prompts/implementer.md` | GATE 2 / prev packet approved | Code in `app/` | → Tester |
| 4 | Tester | `prompts/tester.md` | Implementer done | Tests + results | → UI-Reviewer or Code-Reviewer |
| 5 | UI-Reviewer | `prompts/ui-reviewer.md` | Tester done (UI changed) | UI validation notes | → Code-Reviewer |
| 6 | Code-Reviewer | `prompts/code-reviewer.md` | Tester (+ UI-Reviewer) done | Review against `reviews/*.md` | Pass → Git-Manager / Fail → Implementer |
| 7 | Git-Manager | `prompts/git-manager.md` | Code-Reviewer passes | Commit + push + PR | → Reporter |
| 8 | Reporter | `prompts/reporter.md` | Git-Manager done | `reports/packet-NN-report.md` | GATE 3 |

---

## How to Invoke Each Agent

When activating an agent, read its prompt file and follow it exactly:

- **Architect:** Read `prompts/architect.md` — ask clarifying questions, then produce `docs/vision.md` and `docs/stack.md`.
- **Planner:** Read `prompts/planner.md` — read `docs/vision.md`, produce all `tasks/packet-NN.md` files.
- **Implementer:** Read `prompts/implementer.md` — read the active packet, implement only what is specified.
- **Tester:** Read `prompts/tester.md` — run all tests defined in the packet's acceptance criteria.
- **UI-Reviewer:** Read `prompts/ui-reviewer.md` — validate UI renders correctly and is responsive.
- **Code-Reviewer:** Read `prompts/code-reviewer.md` — check against `reviews/frontend.md` or `reviews/backend.md`.
- **Git-Manager:** Read `prompts/git-manager.md` — commit, push to feature branch, open PR.
- **Reporter:** Read `prompts/reporter.md` — write `reports/packet-NN-report.md`, present clean summary.

---

## Current State

> **This section is updated after every packet. It is the single source of truth for resuming work across sessions.**

**Project:** Race Day OS
**Last completed:** Packet 03 — Pacing Engine
**Last report:** `reports/packet-03-report.md`
**Current packet:** Packet 04 — Fueling Plan
**Status:** ⏸ GATE 3 — awaiting Yassine's "go" to start Packet 04 (BUILDER)

**Git:** Branch: `main`. Remote: `git@github.com:tahayassine4-svg/Race-Day-OS-1.0.git`. Pushed through `b596ffd`.

**Next session command:** "Continue from where we left off" or "Read Current State and resume workflow"

---

**Session log:**

| Date | Packet | Outcome | Notes |
|---|---|---|---|
| 2026-05-22 | 01 — Foundation & Auth | ✅ PASSED | Build + types clean. 3 runtime criteria need live Supabase env. npm used (not pnpm). |
| 2026-05-22 | 02 — Race & Course Setup | ✅ PASSED | Build + types clean. 6 runtime criteria need live Supabase. Git initialized; Packets 01+02 in one initial commit. |
| 2026-05-22 | 03 — Pacing Engine | ✅ PASSED | Build + types clean. Pure engine, 3 scenarios, inline overrides. All acceptance criteria verified in code. |

---

## Starting a New Session

At the start of every session:

1. Read the **Current State** section above — this tells you exactly where to resume.
2. Read `reports/packet-NN-report.md` for the last completed packet to understand what was built and any open issues.
3. Read `tasks/packet-NN.md` for the current packet to understand what to build next.
4. State your mode and confirm with Yassine: "Resuming from [status]. Ready to [next action] — continue?"

If `## Current State` shows `Status: ⏸ GATE 3`, wait for Yassine's "go" before activating BUILDER.
If no `docs/` files exist: "No project found. Activating ARCHITECT — tell me about your app idea."

**After every packet, update Current State:**
- Set `Last completed` to the packet just finished
- Set `Last report` to the new report path
- Set `Current packet` to the next packet
- Set `Status` to the correct gate or agent
- Add a row to the session log
