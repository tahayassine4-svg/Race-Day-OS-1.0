---
description: Default stacks (SwiftData+CloudKit vs Supabase), native vs cross-platform decision rules, and monetization toolchain — read by ARCHITECT when scoping any new app.
globs:
  - "apps/**/docs/stack.md"
  - "apps/**/docs/vision.md"
  - "apps/**/docs/decisions.md"
alwaysApply: false
---

# iOS Tech Stack — Defaults & Decision Rules

> The **Architect** reads this to recommend a stack. Default to the simplest stack that reliably ships. Don't introduce technology for its own sake.

## Core toolchain (assume unless a reason overrides)

- **Swift 6** — strict compile-time data-race safety on.
- **SwiftUI** — declarative UI. ~20–30% smaller memory footprint than UIKit; stack-allocated views.
- **Xcode** — build, profile (Instruments), test.
- **SwiftData** — local persistence (iOS 17+). See migration rules in `.claude/rules/ios-testing.md`.
- **TestFlight + App Store Connect** — beta distribution, crash telemetry, IAP config, submission.

## Default stack — Stack 1: Rapid Solo Indie (RECOMMENDED for most apps)

```
SwiftUI  →  SwiftData (local)  →  CloudKit (automatic iCloud sync)  →  RevenueCat (StoreKit 2)
                                                                      →  TelemetryDeck (analytics)
```

- **Persistence:** SwiftData. **Sync:** CloudKit automatic — zero backend code.
- **Monetization:** RevenueCat over StoreKit 2 (simplifies paywalls/entitlements).
- **Best for:** solo/small-team utility, productivity, tracking, fitness, lifestyle apps.
- **Pros:** free at indie scale, fastest to ship, no server to run.
- **Cons:** Apple-only; CloudKit enforces **add-only** schema migration rules (you can add fields, not rename/delete destructively) — design models accordingly.

## Stack 2: Scalable Full-Stack (use only when the app needs accounts + cross-platform + relational data)

```
Native SwiftUI  →  Supabase (PostgreSQL + Row-Level Security + Deno Edge Functions)  →  RevenueCat
```

- **Best for:** multi-platform, real-time collaboration, complex relational data, growing user cohorts.
- **Auth:** Supabase native auth with RLS. If you offer ANY third-party social login you MUST also offer Sign in with Apple (Guideline 4.8) — see the first-sign-in trap in `.claude/rules/ios-launch.md`.
- **Pros:** relational, predictable instance-based cost, self-hostable (no lock-in).
- **Cons:** you own migrations and RLS policies.

> **Firebase note:** viable at tiny scale and offline-first, but per-operation pricing spikes for feed/refresh-heavy apps and NoSQL denormalization adds complexity. Prefer Supabase when a real backend is needed, CloudKit when sync is all that's needed.

## Native vs cross-platform (the default is native)

| | Native SwiftUI | Flutter | React Native |
|---|---|---|---|
| Clean build | 15–30s | 45–90s | 4–7 min |
| Target FPS | 60–120 | 60–120 | 60 (drops under load) |
| Framework overhead | ~2–3 MB | ~10–15 MB | ~20–35 MB |
| Idle memory | 40–80 MB | 80–150 MB | 100–150 MB |
| Platform API access | zero-latency | plugin wrappers | native modules |

**Choose native SwiftUI** for anything touching HealthKit, ARKit, CoreML, widgets, Live Activities, watchOS, or wanting day-one new-OS compatibility. Only consider cross-platform when a single iOS+Android codebase is a hard product requirement and the team already lives in that ecosystem.

## Games

Game engine selection lives in the opt-in module `knowledge/game-design.md`. Do not pull it into a non-game app.

## What the Architect must record in the app's `docs/stack.md`

- Chosen stack (1, 2, or justified custom) + one-line rationale per major choice.
- Exact setup commands, the Xcode target/scheme, minimum iOS version.
- Required env vars / secrets (keys only, never values).
- "Alternatives Considered" — every major trade-off, explicitly.
- Distribution constraint: is the app already shipped (TestFlight/App Store) with real user data? If yes, mark it a **hard constraint** — every later persistence change must preserve data.
