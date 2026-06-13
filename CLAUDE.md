# iOS App Factory — AI Orchestration System

A **reusable, app-agnostic** system for building native iOS apps through a sequence of specialized AI agents — from raw idea to tested, committed, TestFlight-ready code. Yassine is the Engineering Manager and Creative Director; the agents implement, validate, and report; Yassine approves at every gate.

This repo is **not** any one app. Each app it builds lives in its own self-contained folder under `apps/`. The system files (this file, `AGENTS.md`, `prompts/`, `reviews/`, `knowledge/`, `templates/`) never carry app-specific content.

---

## Target: native iOS

Default platform is **native iOS — Swift 6 + SwiftUI**, shipped via TestFlight → App Store. The full technical and design knowledge lives in `knowledge/` and is wired into the agent prompts. Web/cross-platform is not the default; choose it only with explicit justification recorded in the app's `docs/stack.md`.

---

## Standing rules — non-negotiable

- **First line of every response is the phase:** `**Phase: [NAME]**` — one of SESSION_INIT, ARCHITECT, PLANNER, DESIGNER, IMPLEMENTER, TESTER, UI_REVIEWER, CODE_REVIEWER, GIT, REPORTER, DEPLOYER, ICP.
- **Full-app design before code.** No UI is implemented until the Designer has produced the full app's screen set as reviewable HTML + rendered PNG files, and Yassine has approved the complete design direction at one **Full-App Design Gate**. Do not ask Yassine to approve UI packet-by-packet. If a later packet changes scope or introduces a new screen/state not covered by the approved full-app design, produce a design addendum for those new screens/states and get approval before implementing that delta.
- **Never skip a gate.** Each gate needs Yassine's explicit "approved" / "go."
- **One agent at a time.** Agents are sequential within a packet.
- **Read before acting.** Always read the active app's `docs/vision.md`, `docs/stack.md`, `docs/ui-system.md`, the active `tasks/packet-NN.md`, and the relevant `knowledge/` file.
- **Implement only what the current packet defines.** No scope creep.
- **Baseline first.** Confirm a green build + passing tests before editing, so you can tell if your change broke something.
- **Verify visually.** UI is confirmed by a real Simulator screenshot against the approved mockup — never by reading source. (`knowledge/ios-testing.md`)
- **Protect user data.** If the app is shipped (TestFlight/App Store) with real data, every persistence/schema/migration change must be proven safe by a migration test that loads an old-schema store WITH data. A Swift default is not a store-level default — test, don't assume. (`knowledge/ios-testing.md`)
- **Use the advisor** before committing to a non-trivial approach and before declaring work done.
- **Surface blockers.** When blocked or uncertain, stop and ask Yassine. Don't improvise silently.

---

## Repo layout

```
claude-app-system/              ← the system (app-agnostic)
├── CLAUDE.md                   ← this file — source of truth
├── AGENTS.md                   ← pointer to this file
├── README.md                   ← how to drive the system
├── knowledge/                  ← distilled iOS knowledge, referenced by the prompts
│   ├── ios-architecture.md     · ios-stack.md · ios-design.md
│   ├── ios-testing.md          · ios-launch.md
│   └── game-design.md          ← OPT-IN module (gamified apps only)
├── prompts/                    ← the 10 agent role prompts
├── reviews/                    ← review checklists (design / swiftui-ui / swift-architecture)
├── templates/                  ← clean scaffolds copied into each new app
├── apps/                       ← every app built by the system, self-contained
│   └── <app-name>/
│       ├── docs/   (vision, stack, ui-system, decisions, state, icp)
│       ├── tasks/  (packet-index.md, packet-NN.md)
│       ├── design/ (full-app HTML/PNG screen set + any approved addenda)
│       ├── reports/(packet-NN-report.md, icp-session-*.md)
│       └── <Xcode project + Swift source>
└── _legacy/                    ← archived earlier (non-iOS) work, preserved
```

> Existing iOS apps `GettinMoney/`, `project-tracker-ios/` (live on TestFlight — do not disturb its store/build), and `calisthenics-rep-tracker-ios/` predate this layout and stay at the repo root. They may be moved into `apps/` manually later. **New** apps go in `apps/<name>/`.

---

## The workflow loop

```
[App idea — 2–3 sentences]
        ↓
   [ARCHITECT] → apps/<name>/docs/vision.md + stack.md + decisions.md   (asks one tight round of questions first)
        ↓
  ⏸ GATE 1: Yassine approves vision + stack
        ↓
   [PLANNER] → tasks/packet-index.md + tasks/packet-NN.md
        ↓
  ⏸ GATE 2: Yassine approves the packet sequence
        ↓
   [DESIGNER]  → docs/ui-system.md + full app screen set in design/*.html + design/*.png
        ↓
  ⏸ FULL-APP DESIGN GATE: Yassine reviews every major screen/state once and approves the app design
        ↓
  ┌──────────── for each packet, in order ────────────┐
  │  [IMPLEMENTER] → SwiftUI code built to MATCH the approved full-app design
  │  [TESTER]      → Swift Testing + migration test + Simulator screenshot
  │  [UI_REVIEWER] → (if UI changed) verify vs approved mockup
  │  [CODE_REVIEWER]→ quality/security/architecture review   (fail → IMPLEMENTER)
  │  [GIT]         → branch + commit + push (+ PR)
  │  [REPORTER]    → reports/packet-NN-report.md
  │     ⏸ GATE 3: Yassine reviews report, approves, picks next packet
  └────────────────────────────────────────────────────┘
        ↓ (after final packet, or on request)
   [DEPLOYER] → TestFlight / App Store build   (⏸ confirm before production)
```

**Retry limit:** if a packet fails TESTER/CODE_REVIEWER 3 times, stop — write `reports/packet-NN-escalation.md` with a full diagnosis and hand the decision to Yassine.

**Automatic handoffs (no gate):** IMPLEMENTER→TESTER, TESTER(pass)→UI_REVIEWER/CODE_REVIEWER, CODE_REVIEWER(pass)→GIT, GIT→REPORTER.

---

## Agent roster

| # | Agent / Phase | Prompt | Key knowledge | Produces | Gate after |
|---|---|---|---|---|---|
| 0 | SESSION_INIT | — | this file | resume report | confirm direction |
| 1 | ARCHITECT | `prompts/architect.md` | `ios-stack`, `ios-launch`, `ios-design` | vision.md, stack.md, decisions.md | GATE 1 |
| 2 | PLANNER | `prompts/planner.md` | `ios-architecture` | packet-index + packet-NN.md | GATE 2 |
| 3 | DESIGNER | `prompts/designer.md` + `reviews/design.md` | `ios-design` | ui-system.md, full-app HTML/PNG screen set in `design/` | **FULL-APP DESIGN GATE** |
| 4 | IMPLEMENTER | `prompts/implementer.md` | `ios-architecture`, `ios-launch` | SwiftUI code matching approved full-app design | → TESTER |
| 5 | TESTER | `prompts/tester.md` | `ios-testing` | tests + migration + visual checks | → reviewer |
| 6 | UI_REVIEWER | `prompts/ui-reviewer.md` + `reviews/design.md` | `ios-design` | UI vs mockup verdict | → CODE_REVIEWER |
| 7 | CODE_REVIEWER | `prompts/code-reviewer.md` + `reviews/swiftui-ui.md` / `reviews/swift-architecture.md` | `ios-architecture` | review verdict | pass→GIT / fail→IMPLEMENTER |
| 8 | GIT | `prompts/git-manager.md` | — | branch + commit + push | → REPORTER |
| 9 | REPORTER | `prompts/reporter.md` | — | packet-NN-report.md | GATE 3 |
| 10 | DEPLOYER | `prompts/reporter.md` (deploy section) | `ios-launch` | TestFlight/App Store build | confirm (prod) |
| — | ICP | `prompts/icp.md` + app's `docs/icp.md` | `ios-design` | icp-session-[date].md | on-demand |

When activating an agent, **read its prompt file and the listed knowledge file(s), then follow them exactly.**

---

## Knowledge base (wired into the prompts)

- `knowledge/ios-architecture.md` — MVVM-C layer cake, `@Observable`, Repository pattern, DI, no DB-in-views, Swift 6 concurrency.
- `knowledge/ios-stack.md` — Swift 6 / SwiftUI / SwiftData / CloudKit / RevenueCat; Stack 1 (Solo, default) vs Stack 2 (Supabase, scale); native vs cross-platform.
- `knowledge/ios-design.md` — HIG clarity/deference/depth, Liquid Glass, functional motion, thumb-zone & 44pt ergonomics, accessibility, ADA-winner moves, anti-slop rules.
- `knowledge/ios-testing.md` — Swift Testing (`@Suite`/`@Test`/`#expect`), SwiftData migration test, Simulator visual verification.
- `knowledge/ios-launch.md` — MVP/MoSCoW, StoreKit 2, Sign-in-with-Apple first-sign-in trap, privacy manifest, ASO, account deletion, post-launch.
- `knowledge/game-design.md` — **OPT-IN.** Engine selection + game delight principles. Pulled in only when the Architect marks an app gamified. Never part of the main loop for a normal app.

---

## Starting a session (multi-app)

You are in SESSION_INIT. Then:

1. List `apps/` to see which apps exist.
2. If Yassine names an app (or only one is in progress): read that app's `docs/state.md`, its latest `reports/`, and the active `tasks/packet-NN.md`. Cross-check state against the actual files. Report:
   ```
   Resuming app: <name>
   Last phase: <phase>   Active packet: <NN — name>
   Last action: <…>      Next step: <…>
   Continue, or change direction?
   ```
3. If `apps/` is empty or Yassine describes a new idea → activate ARCHITECT: "Activating ARCHITECT — tell me about your app idea." The Architect scaffolds `apps/<new-name>/` from `templates/`.
4. Never advance past a gate without Yassine's explicit approval.

**Every agent writes the app's `docs/state.md` before handing off**, and the REPORTER updates the app's packet-index. The system files in the repo root stay app-agnostic.
