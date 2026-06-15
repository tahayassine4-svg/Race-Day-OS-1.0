# iOS App Factory

A reusable, **app-agnostic** AI orchestration system for building native iOS apps (Swift 6 + SwiftUI) — from idea to tested, committed, TestFlight-ready code, with a human approving at every gate.

This repo is the *factory*, not any one app. Each app it builds is self-contained under `apps/<name>/`.

## How it works

Ten specialized agents run in sequence, with approval gates:

```
ARCHITECT → ⏸ → PLANNER → ⏸ → [ per packet: DESIGNER → ⏸ → IMPLEMENTER → TESTER → UI_REVIEWER → CODE_REVIEWER → GIT → REPORTER → ⏸ ] → DEPLOYER
```

- **Design before code** — every UI packet gets a rendered mockup approved at the Design Gate before any SwiftUI is written.
- **Verify visually** — UI is confirmed with a real Simulator screenshot against the mockup.
- **Protect data** — schema changes on shipped apps are proven safe with a migration test.

See **[`WORKFLOW.md`](./WORKFLOW.md)** for the full system definition. `CLAUDE.md` and `AGENTS.md` are tool-specific entrypoints that point to the shared workflow.

## Layout

| Path | What |
|---|---|
| `WORKFLOW.md` | shared source of truth for Claude Code + Codex |
| `CLAUDE.md` / `AGENTS.md` | tool-specific entrypoints |
| `prompts/` | the 10 agent role prompts |
| `reviews/` | review checklists (design / swiftui-ui / swift-architecture) |
| `knowledge/` | distilled iOS knowledge, wired into the prompts |
| `templates/` | clean scaffolds copied into each new app |
| `apps/<name>/` | each app the system builds, self-contained |
| `_legacy/` | archived earlier (non-iOS) work |

## Start a build

1. Open a session — it begins in SESSION_INIT and lists `apps/`.
2. New app: "I have an idea — <2–3 sentences>." The Architect asks a tight round of questions, then scaffolds `apps/<name>/` and writes its vision + stack.
3. Resume: name the app, or it resumes the one in progress from that app's `docs/state.md`.

## Create a Claude/Codex handoff

Generate a current-session handoff for an app:

```bash
./scripts/create-handoff apps/getting-money --goal "Continue the current app work" --next "Read docs/state.md and latest report, then continue"
```

The command writes `apps/<app>/docs/handoff.md` using the app state, active packet/report paths, git status, recent artifacts, and latest archive/IPA paths. Review the generated file before handing the session to another agent.

## Knowledge base

`ios-architecture` (MVVM-C, DI, no-DB-in-views) · `ios-stack` (Swift 6/SwiftUI/SwiftData/CloudKit/RevenueCat) · `ios-design` (HIG, Liquid Glass, ergonomics, anti-slop, ADA-winner moves) · `ios-testing` (Swift Testing, migration safety, Simulator verification) · `ios-launch` (MVP/MoSCoW, StoreKit 2, privacy manifest, ASO) · `game-design` (**opt-in**, gamified apps only).

## Existing apps

`GettinMoney/`, `project-tracker-ios/` (live on TestFlight — don't disturb), and `calisthenics-rep-tracker-ios/` predate the `apps/` layout and remain at the repo root. New apps go in `apps/`.
