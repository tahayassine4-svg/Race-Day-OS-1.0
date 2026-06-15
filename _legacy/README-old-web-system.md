# AI-Orchestrated Web App Development System

A reusable scaffolding system that turns any web app idea into shipped code through a sequence of specialized AI agents — with you as the Engineering Manager approving every major decision.

---

## What This System Is

Instead of asking an AI to "build me an app," this system breaks the work into eight specialized agents that each do one job well:

1. **Architect** — translates your idea into a technical plan
2. **Planner** — breaks the plan into discrete, testable software packets
3. **Implementer** — writes code for one packet at a time
4. **Tester** — writes and runs tests against acceptance criteria
5. **UI-Reviewer** — validates the interface looks and behaves correctly
6. **Code-Reviewer** — checks code quality against defined checklists
7. **Git-Manager** — commits, pushes, and opens a pull request
8. **Reporter** — documents what was built, what passed, what's next

You approve at three gates. Everything else runs automatically.

---

## The 8-Agent Workflow

```
[App idea — describe it in 2-3 sentences]
          ↓
     [ARCHITECT]  →  docs/vision.md + docs/stack.md + dev plan
          ↓
    ⏸ GATE 1: You approve plan and stack
          ↓
      [PLANNER]  →  tasks/packet-01.md … tasks/packet-NN.md
          ↓
    ⏸ GATE 2: You approve the packet sequence
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
    │  ⏸ GATE 3: You review report,            │
    │    approve merge, decide next packet     │
    └─────────────────────────────────────────┘
```

---

## How to Start a New Project

### Step 1 — Scaffold from this template

```bash
./new-app.sh ~/projects/my-new-app
```

This copies the entire system into a new directory and initializes a git repo.

### Step 2 — Open Claude Code inside the new project

```bash
cd ~/projects/my-new-app
claude
```

### Step 3 — Describe your idea

Claude reads `CLAUDE.md`, sees no project exists, and activates the **Architect**. Just say:

> "I want to build a [brief description]. Core features: [1], [2], [3]. Target users: [who]. Platform: [web / mobile / both]."

The Architect will ask follow-up questions, then produce `docs/vision.md` and `docs/stack.md`.

---

## How the Gates Work

There are three points where the system stops and waits for your approval:

| Gate | After | You decide |
|---|---|---|
| **Gate 1** | Architect produces plan | Is the tech stack right? Does the plan match the vision? |
| **Gate 2** | Planner produces packet list | Are the packets in the right order? Is scope right? |
| **Gate 3** | Reporter summarizes each packet | Did it pass? Approve merge? Start the next packet? |

At every gate, the system presents what it produced and waits. You say "approved" / "go" / "go ahead" to continue, or give feedback to adjust.

---

## Folder Structure

```
my-app/
├── CLAUDE.md              ← Master orchestration file (Claude reads this every session)
├── README.md              ← This file
├── new-app.sh             ← Script to scaffold new projects from this template
├── app/                   ← Application source code
├── docs/
│   ├── vision.md          ← App summary, goals, and target users (Architect output)
│   └── stack.md           ← Tech stack decisions and setup instructions
├── prompts/               ← The eight agent definitions
│   ├── architect.md
│   ├── planner.md
│   ├── implementer.md
│   ├── tester.md
│   ├── ui-reviewer.md
│   ├── code-reviewer.md
│   ├── git-manager.md
│   └── reporter.md
├── tasks/                 ← One file per software packet (Planner output)
│   └── _template.md
├── reviews/               ← Checklists for the Code-Reviewer
│   ├── frontend.md
│   └── backend.md
└── reports/               ← Packet completion reports (Reporter output)
    └── _template.md
```

---

## Tips

- **Be specific with your idea.** The more context you give the Architect, the tighter the plan.
- **Push back at gates.** Gate 2 is the best time to reorder, merge, or split packets before any code is written.
- **Trust the reports.** The Reporter is your audit trail — it captures decisions, trade-offs, and open questions for every packet.
- **The Code-Reviewer can send work back.** If code quality fails, the implementer gets a second pass with specific notes before anything is committed.
