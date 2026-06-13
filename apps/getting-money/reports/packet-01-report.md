# Packet 01 Report: Foundation + Premium Design System

## Status: PASSED

## What was built
Native iOS app (Swift 6, SwiftUI, iOS 17+) generated via XcodeGen, with the dark/lime/coral design system and a working 5-tab shell.

- `project.yml` + generated `GettingMoney.xcodeproj` (XcodeGen)
- `GettingMoney/GettingMoneyApp.swift` — `@main`, dark-first
- DesignSystem: `Color+Hex`, `GMTheme` (tokens), `GMTypography`, `GMSpacing`/`GMRadius`, `NumberFormatting` (deterministic grouping)
- Components: `GMCard`, `GMStatusPill`, `GMProgressBar`, `ExerciseProgressRow`, `ScreenBackground`, `ComingSoonScreen`
- `Models/DashboardSample.swift` — sample data only (no persistence)
- Views: `AppRootView` (TabView), `DashboardView` (matches mockup), `LogView`/`RoundsView`/`DebtView`/`SettingsView` (on-brand placeholders)
- `GettingMoneyTests/SmokeTests.swift`

## Test results
- Build (iPhone 17 Pro simulator): **PASS** (`** BUILD SUCCEEDED **`)
- Swift Testing suite: **3/3 PASS** (sample-data consistency, exercise math, status labels)
- Migration/data-safety test: **N/A** (no persistence in this packet)
- Visual verification vs `design/packet-01.png`: **PASS** — running-app screenshot (`design/build-packet-01-dashboard.png`) matches the approved mockup (balance, streak, daily-target bar, exercise rows with coral "2 owed" tag, debt strip, lime CTA, 5-tab bar, "On track" pill).

## Review results
- SwiftUI/UI quality: PASS — views are dumb, tokens not magic values, components <200 lines, no debug output.
- Architecture: PASS — no persistence/logic in views; DI/Repository deferred to Packet 02 as planned.
- Security: PASS — no secrets, no network, no auth.
- Regression check: N/A — first packet.

## Acceptance criteria
- [x] Builds and runs on an iPhone simulator.
- [x] First screen is Dashboard; tab bar has Dashboard, Log, Rounds, Debt, Settings (all wired into the TabView).
- [x] Dashboard shows balance, debt, streak, and exercise progress using design-system tokens.
- [x] Dark palette matches the approved mockup; contrast holds.
- [x] No persistence, networking, or auth present.

## Issues found
None blocking.

## Trade-offs / advisories
- **Dynamic Type:** type roles use fixed `.system(size:)` to match the mockup precisely. Full Dynamic Type scaling (e.g. `relativeTo:`) is deferred to the accessibility pass in Packet 08 — flagged so it isn't forgotten.
- **Light mode:** app is locked to dark (`.preferredColorScheme(.dark)`) for v1 per the dark-first spec; the light token mirror in `ui-system.md` is unused until a later polish packet.
- **Per-tab visuals:** Dashboard verified against its mockup; the other four tabs are on-brand placeholders and get full screens (and their own visual verification) in their packets (03–07).
- **XcodeGen note:** after adding/removing Swift files, re-run `xcodegen generate` before building (files are listed at generation time).

## Git
- Branch: not yet committed (awaiting Yassine's go).
- Commit: —
- TestFlight: not yet.

## Retry count
0 of 3

## Next packet preview
Packet 02 — Local Data Models + Persistence: SwiftData `@Model`s behind Repositories, versioned schema, seed defaults (dips off), no `@Query` in views.
