# Stack — Getting Money

> Decision rules: `knowledge/ios-stack.md`. This is **Stack 1 (Rapid Solo Indie), local-only variant** — CloudKit deliberately deferred to a later version.

## Chosen stack
- **Stack:** 1 (Rapid Solo Indie) — local-only (no CloudKit in v1)
- **Language/UI:** Swift 6 (strict concurrency on), SwiftUI
- **Min deployment:** iOS 17
- **Persistence:** SwiftData, **local device only** — no cloud, no backend
- **Sync:** none (v1)
- **Auth:** none
- **Charts:** Swift Charts (bank/debt/streak visuals)
- **Monetization:** none in v1 (the "money" is in-app metaphor, not StoreKit)
- **Analytics/crash:** none in v1 (TestFlight crash telemetry only)
- **Architecture:** MVVM-C layer cake (`knowledge/ios-architecture.md`) — pure calculation engines as Services behind protocols
- **Testing:** Swift Testing (`knowledge/ios-testing.md`)
- **Game module:** ON for design/feel (gamified loop); no game engine — SwiftUI native
- **Distribution:** TestFlight

## Rationale
- **SwiftData local-only:** the data model is single-user and device-local; SwiftData gives native models with minimal setup and a clean migration path. CloudKit is a documented "nice-to-have later" — adding it later is additive (design models add-only to keep that door open).
- **Pure calculation engines as Services:** the money/debt/rounds/payback math is the heart of the app and must be unit-tested in isolation — keep it out of views and ViewModels.
- **Swift Charts:** native, no dependency, fits the "bank dashboard" visuals.

## Core calculation engines (Services, protocol-injected, fully unit-tested)
- `EarningsEngine` — money from completed reps ($1/rep), daily/total/bonus.
- `DebtEngine` — missed→debt per exercise; extra-reps priority: today's target → debt → bonus.
- `TargetProgressionEngine` — +5..10 every 2 weeks; pull-up cap at 10 unless overridden.
- `RoundPlanner` — split targets across N rounds (floor + distribute remainder to earliest rounds).
- `PaybackPlanner` — one-go vs finance-plan over D days; exercise-aware; recalculates dynamically.

## Setup
- Xcode project: `apps/getting-money/GettingMoney.xcodeproj`, scheme `GettingMoney`.
- Run: open in Xcode → iPhone simulator (latest Pro). Tests: Product ▸ Test.
- Command-line (once configured):
  ```bash
  xcodebuild -project apps/getting-money/GettingMoney.xcodeproj \
    -scheme GettingMoney \
    -destination 'platform=iOS Simulator,name=iPhone 16 Pro' test
  ```
- Archive for TestFlight: Product ▸ Archive → App Store Connect.

## Required env vars / secrets
None. No backend, no auth, no third-party API.

## Distribution
- Bundle ID: `com.yassine.gettingmoney`
- TestFlight/App Store status: not yet shipped
- Privacy manifest: minimal — declare UserDefaults required-reason (`CA92.1`) if used; no tracking, no data collection. Account-deletion path N/A (no accounts).

## Alternatives considered
| Option | Why rejected |
|---|---|
| SwiftData **+ CloudKit** now | Sync is out of scope for v1; adds add-only schema constraints and iCloud edge cases before the loop is validated. Defer. |
| Core Data directly | SwiftData is simpler and sufficient for local v1. |
| SQLite directly | Unnecessary control cost for this model. |
| React Native / Flutter | iOS-only TestFlight target benefits from native polish; no cross-platform need. |
| Firebase / Supabase | Cloud persistence out of scope; v1 is local-only. |
