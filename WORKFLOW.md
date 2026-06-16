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

- First line of every response must be `**Phase: [NAME]**`. Valid phases: `SESSION_INIT`, `ARCHITECT`, `PLANNER`, `DESIGNER`, `IMPLEMENTER`, `TESTER`, `UI_REVIEWER`, `CODE_REVIEWER`, `GIT`, `REPORTER`, `DEPLOYER`, `ICP`.
- Never skip a gate. Each gate needs Yassine's explicit "approved" or "go."
- Read the active app's `MANIFEST.json` first (structured state: phase, packet, tests, review, git status, blockers). If `handoff_needed` is true, read `docs/handoff.md` before doing anything else.
- Design before code. No UI implementation until mockups are approved. New screens/states not covered by the approved design need a design addendum before implementation.
- Implement only what the current packet defines. Confirm a green build and passing tests before editing. Verify UI with a real Simulator screenshot against the approved mockup — never by reading source alone.
- Protect user data. If an app is shipped with real data, every persistence/schema/migration change must be proven safe by a migration test that loads an old-schema store with data.
- Surface blockers. When blocked or uncertain, stop and ask Yassine. Use the advisor before committing to a non-trivial approach and before declaring substantial work done.
- Every agent writes the active app's `docs/state.md` and `MANIFEST.json` before handing off. REPORTER also updates `tasks/packet-index.md`.
- GIT pushes the packet branch and opens a PR but leaves it **unmerged** — "pushed" never means "merged to main." Merging happens after Yassine reviews the REPORTER output at Gate 3.
- A `PreToolUse` hook (`.claude/hooks/check-git-push-gate.sh`, registered in `.claude/settings.json`) enforces CODE_REVIEWER → GIT ordering: `git push`/`gh pr create` on a packet branch is blocked unless that packet's `MANIFEST.json` shows `tests.status == "PASS"` and `code_review.status == "PASS"`. If the branch is named `packet-*` and no `apps/*/MANIFEST.json` has a matching `packet_branch`, the hook **fails closed** (blocks). **This only loads if the Claude Code session's project root is this repo.**
- **The coordinator sets `MANIFEST.json.packet_branch` to the new packet's branch (and resets `tests.status`/`code_review.status` to `"PENDING"`) at the start of each packet**, before handing off to IMPLEMENTER. The git-push gate and the test-results hook both key off `packet_branch` — if it still points at the previous packet's branch, both hooks miss their target for the whole packet.
- A `PostToolUse` hook (`.claude/hooks/swift-format-on-edit.sh`) runs `swift format --in-place` on any `.swift` file after Edit/Write — formatting is enforced automatically, not reviewed.
- A `PostToolUse` hook (`.claude/hooks/write-test-results.sh`) parses the output of any `xcodebuild test`/`swift test` run on a packet branch and writes the PASS/FAIL verdict (+ counts) into that packet's `MANIFEST.json.tests` automatically — TESTER doesn't have to remember to update it.
- When the DEPLOYER subagent reports back, the coordinator sends Yassine a push notification — subagents cannot call notification tools themselves, only the coordinator session can.

---

## Repo Layout

```text
claude-app-system/
├── WORKFLOW.md                  ← shared source of truth for Claude + Codex
├── CLAUDE.md                    ← Claude Code entrypoint, points here
├── AGENTS.md                    ← Codex entrypoint, points here
├── README.md
├── .claude/
│   ├── agents/                  ← subagent prompts (designer, implementer, tester, …)
│   ├── hooks/                   ← PreToolUse/PostToolUse shell hooks
│   ├── rules/                   ← glob-conditional knowledge (ios-architecture, ios-design, …)
│   ├── skills/                  ← invocable skills (/architect, /planner, /reporter, /icp, /worktree, …)
│   └── settings.json
├── knowledge/
│   └── game-design.md           ← opt-in for gamified apps only
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
| 0 | SESSION_INIT | skill: `/resume-app` | this file | resume report | confirm direction |
| 1 | ARCHITECT | skill: `/architect` | `.claude/rules/ios-stack`, `ios-launch`, `ios-design` | vision.md, stack.md, decisions.md | Gate 1 |
| 2 | PLANNER | skill: `/planner` | `.claude/rules/ios-architecture` | packet-index + packet files | Gate 2 |
| 3 | DESIGNER | `.claude/agents/designer.md` (subagent), `.claude/skills/render-mockups`, `reviews/design.md` | `.claude/rules/ios-design` | ui-system + full app screen set | Full-App Design Gate |
| 4 | IMPLEMENTER | `.claude/agents/implementer.md` (subagent) | `.claude/rules/ios-architecture`, `ios-launch`, `swift6.md` | SwiftUI code | TESTER |
| 5 | TESTER | `.claude/agents/tester.md` (subagent), `.claude/skills/swiftdata-migration-test` | `.claude/rules/ios-testing` | tests + screenshots + verdict | reviewer |
| 6 | UI_REVIEWER | `.claude/agents/ui-reviewer.md` (subagent, fresh context from IMPLEMENTER), `reviews/design.md` | `.claude/rules/ios-design` | UI verdict | CODE_REVIEWER |
| 7 | CODE_REVIEWER | `.claude/agents/code-reviewer.md` (subagent, isolated from IMPLEMENTER), review checklist | `.claude/rules/ios-architecture` | review verdict | GIT or IMPLEMENTER |
| 8 | GIT | `.claude/agents/git-manager.md` (subagent, git/gh only) | none | branch + commit + push | REPORTER |
| 9 | REPORTER | skill: `/reporter` | none | packet report | Gate 3 |
| 10 | DEPLOYER | `.claude/agents/deployer.md` (subagent) | `.claude/rules/ios-launch` | TestFlight/App Store build | confirm production |
| — | ICP | skill: `/icp`, app `docs/icp.md` | `.claude/rules/ios-design` | icp-session report | on demand |

When activating an agent, read its prompt file and the listed knowledge file(s), then follow them exactly.

---

## Starting Or Resuming A Session

Run `/resume-app` to orient. Full SESSION_INIT in `.claude/skills/resume-app/SKILL.md`.

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
