# iOS App Factory — Shared AI Workflow

This is the shared source of truth for both Claude Code and Codex.

Claude-specific entrypoint: `CLAUDE.md`  
Codex-specific entrypoint: `AGENTS.md`

If an entrypoint conflicts with this file, follow this file unless Yassine explicitly overrides it in the active session.

---

## Purpose

This repo is a reusable, app-agnostic system for building native iOS apps through specialized AI agents, from raw idea to tested, committed, TestFlight-ready code.

Yassine is the Engineering Manager and Creative Director. The agents implement, validate, and report. Yassine approves at every gate.

This repo is not any one app. Each app lives in a self-contained folder under `apps/`.

---

## Target Platform

Default platform is native iOS:

- Swift 6
- SwiftUI
- SwiftData local persistence by default
- TestFlight first, then App Store

Web or cross-platform work is not the default. Choose it only with explicit justification recorded in the active app's `docs/stack.md`.

---

## Standing Rules

- First line of every response must be `**Phase: [NAME]**`.
- Valid phases: `SESSION_INIT`, `ARCHITECT`, `PLANNER`, `DESIGNER`, `IMPLEMENTER`, `TESTER`, `UI_REVIEWER`, `CODE_REVIEWER`, `GIT`, `REPORTER`, `DEPLOYER`, `ICP`.
- Full-app design comes before code. No UI implementation until the Designer has produced the full app screen set as reviewable HTML and rendered PNG files, and Yassine has approved the complete design direction.
- If later work changes scope or introduces a new screen/state not covered by the approved design, produce a design addendum and get approval before implementing that delta.
- Never skip a gate. Each gate needs Yassine's explicit "approved" or "go."
- One agent runs at a time within a packet.
- Read before acting. Always read the active app's `docs/vision.md`, `docs/stack.md`, `docs/ui-system.md`, active `tasks/packet-NN.md`, and the relevant `knowledge/` file.
- Implement only what the current packet defines.
- Baseline first. Confirm a green build and passing tests before editing unless the task is explicitly triage-only or the baseline cannot run.
- Verify visually. UI is confirmed by a real Simulator screenshot against the approved mockup, never only by reading source.
- Protect user data. If an app is shipped with real data, every persistence/schema/migration change must be proven safe by a migration test that loads an old-schema store with data.
- Use the advisor before committing to a non-trivial approach and before declaring substantial work done.
- Surface blockers. When blocked or uncertain, stop and ask Yassine. Do not improvise silently.
- Every agent writes the active app's `docs/state.md` before handing off.
- REPORTER updates the app's `tasks/packet-index.md`.
- System files in the repo root stay app-agnostic.

---

## Repo Layout

```text
claude-app-system/
├── WORKFLOW.md                  ← shared source of truth for Claude + Codex
├── CLAUDE.md                    ← Claude Code entrypoint, points here
├── AGENTS.md                    ← Codex entrypoint, points here
├── README.md
├── knowledge/
│   ├── ios-architecture.md
│   ├── ios-stack.md
│   ├── ios-design.md
│   ├── ios-testing.md
│   ├── ios-launch.md
│   └── game-design.md           ← opt-in for gamified apps only
├── prompts/                     ← agent role prompts
├── reviews/                     ← review checklists
├── templates/                   ← app scaffolds and handoff templates
├── apps/
│   └── <app-name>/
│       ├── docs/
│       ├── tasks/
│       ├── design/
│       ├── reports/
│       └── <Xcode project + Swift source>
└── _legacy/
```

Existing iOS apps `GettinMoney/`, `project-tracker-ios/`, and `calisthenics-rep-tracker-ios/` predate the `apps/` layout and stay at the repo root unless manually moved. New apps go in `apps/<name>/`.

---

## Workflow Loop

```text
[App idea]
    ↓
ARCHITECT → apps/<name>/docs/vision.md + stack.md + decisions.md
    ↓
Gate 1: Yassine approves vision + stack
    ↓
PLANNER → tasks/packet-index.md + tasks/packet-NN.md
    ↓
Gate 2: Yassine approves packet sequence
    ↓
DESIGNER → docs/ui-system.md + full app HTML/PNG screen set in design/
    ↓
Full-App Design Gate: Yassine approves every major screen/state
    ↓
For each packet:
    IMPLEMENTER → SwiftUI code matching approved design
    TESTER → Swift Testing + migration tests where needed + Simulator screenshots
    UI_REVIEWER → UI vs approved mockup verdict, if UI changed
    CODE_REVIEWER → quality/security/architecture review
    GIT → branch + commit + push + PR when requested/appropriate
    REPORTER → reports/packet-NN-report.md
    Gate 3: Yassine approves report and next packet
    ↓
DEPLOYER → TestFlight/App Store build, when requested or after final packet
```

Retry limit: if a packet fails TESTER or CODE_REVIEWER three times, stop, write `reports/packet-NN-escalation.md`, and hand the decision to Yassine.

Automatic handoffs without a user gate:

- IMPLEMENTER → TESTER
- TESTER pass → UI_REVIEWER/CODE_REVIEWER
- CODE_REVIEWER pass → GIT
- GIT → REPORTER

---

## Agent Roster

| # | Phase | Prompt | Key knowledge | Produces | Gate after |
|---|---|---|---|---|---|
| 0 | SESSION_INIT | none | this file | resume report | confirm direction |
| 1 | ARCHITECT | `prompts/architect.md` | `ios-stack`, `ios-launch`, `ios-design` | vision.md, stack.md, decisions.md | Gate 1 |
| 2 | PLANNER | `prompts/planner.md` | `ios-architecture` | packet-index + packet files | Gate 2 |
| 3 | DESIGNER | `prompts/designer.md`, `reviews/design.md` | `ios-design` | ui-system + full app screen set | Full-App Design Gate |
| 4 | IMPLEMENTER | `prompts/implementer.md` | `ios-architecture`, `ios-launch` | SwiftUI code | TESTER |
| 5 | TESTER | `prompts/tester.md` | `ios-testing` | tests + screenshots + verdict | reviewer |
| 6 | UI_REVIEWER | `prompts/ui-reviewer.md`, `reviews/design.md` | `ios-design` | UI verdict | CODE_REVIEWER |
| 7 | CODE_REVIEWER | `prompts/code-reviewer.md`, review checklist | `ios-architecture` | review verdict | GIT or IMPLEMENTER |
| 8 | GIT | `prompts/git-manager.md` | none | branch + commit + push | REPORTER |
| 9 | REPORTER | `prompts/reporter.md` | none | packet report | Gate 3 |
| 10 | DEPLOYER | `prompts/reporter.md` deploy section | `ios-launch` | TestFlight/App Store build | confirm production |
| — | ICP | `prompts/icp.md`, app `docs/icp.md` | `ios-design` | icp-session report | on demand |

When activating an agent, read its prompt file and the listed knowledge file(s), then follow them exactly.

---

## Knowledge Base

- `knowledge/ios-architecture.md` — MVVM-C layer cake, `@Observable`, Repository pattern, DI, no DB in views, Swift 6 concurrency.
- `knowledge/ios-stack.md` — Swift 6, SwiftUI, SwiftData, CloudKit, RevenueCat; native vs cross-platform choices.
- `knowledge/ios-design.md` — HIG, Liquid Glass, functional motion, thumb-zone ergonomics, accessibility, anti-slop rules.
- `knowledge/ios-testing.md` — Swift Testing, migration tests, Simulator visual verification.
- `knowledge/ios-launch.md` — MVP/MoSCoW, StoreKit 2, Sign in with Apple, privacy manifest, ASO, account deletion, post-launch.
- `knowledge/game-design.md` — opt-in only when the Architect marks an app as gamified.

---

## Starting Or Resuming A Session

Start in `SESSION_INIT`.

1. Read the active tool entrypoint:
   - Claude Code: `CLAUDE.md`, then this file.
   - Codex: `AGENTS.md`, then this file.
2. List `apps/` to see available apps.
3. If Yassine names an app, read that app's:
   - `docs/state.md`
   - latest relevant `reports/`
   - active `tasks/packet-NN.md`
   - any `docs/handoff.md` if present
4. Cross-check state against the actual filesystem and git status.
5. Report:

```text
Resuming app: <name>
Last phase: <phase>
Active packet: <NN — name>
Last action: <...>
Next step: <...>

Continue, or change direction?
```

If `apps/` is empty or Yassine gives a new app idea, activate ARCHITECT.

Never advance past a gate without Yassine's explicit approval.

---

## Claude-To-Codex Handoff Protocol

The goal is for Claude and Codex to continue each other's work without guessing.

Before Claude stops, hits limits, or hands work to Codex, it must update:

- active app `docs/state.md`
- active `tasks/packet-NN.md`
- active `reports/packet-NN-report.md` if testing/review happened
- screenshot/artifact paths if UI was verified
- `docs/handoff.md`, copied from `templates/handoff.md` when needed

Before Codex continues Claude's work, Codex must read:

- root `AGENTS.md`
- root `WORKFLOW.md`
- active app `docs/state.md`
- active app `docs/handoff.md`, if present
- active packet file
- latest relevant report
- `git status --short`

The handoff must state:

- current goal
- active phase and packet
- exact files changed
- tests run and results
- tests not run
- known risks
- blockers
- next recommended command/action
- whether the latest archive/IPA includes the newest code

Use `templates/handoff.md` as the handoff format.

To generate a current-session handoff from the repo state, run:

```bash
./scripts/create-handoff apps/<app-name> --goal "Continue <goal>" --next "Run <next command or action>"
```

This writes `apps/<app-name>/docs/handoff.md`. Review and edit any unknown fields before handing the session to another agent.

---

## State File Minimum Fields

Every app `docs/state.md` should include at least:

```yaml
phase: <PHASE>
app: <app-name>
packet: <NN — name or N/A>
status: <current status>
last_action: <what just happened>
next_step: <what comes next>
branch: <branch or —>
commit: <commit or —>
timestamp: <ISO date>
handoff:
  needed: <true|false>
  path: <docs/handoff.md or —>
```

More fields are allowed when useful.
