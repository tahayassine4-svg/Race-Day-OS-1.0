# Tech Stack — Getting Money App

## Recommended Stack

| Layer | Technology | Rationale |
|---|---|---|
| Platform | iOS 17+ | Modern iPhone target for TestFlight beta with access to SwiftData and polished SwiftUI APIs. |
| Language | Swift | Native, type-safe, and best supported for Apple platform apps. |
| UI | SwiftUI | App-native UI, fast iteration, strong support for dashboard and form-heavy flows. |
| Persistence | SwiftData | Local-only persistence with native models and minimal setup. |
| Charts | Swift Charts | Native visualizations for bank balance, debt, progress, and streak history. |
| Architecture | MVVM + domain services | Keeps UI, persistence, and core calculations cleanly separated. |
| Testing | XCTest / Swift Testing | Unit tests for money, debt, target progression, round splitting, and payback planning. |
| Distribution | TestFlight | Requested beta distribution path. |

## Setup Commands

```bash
# 1. Open the iOS project in Xcode
open app/ios/GettingMoneyApp.xcodeproj

# 2. Select an iPhone simulator
# Recommended: latest available iPhone Pro simulator

# 3. Run tests from Xcode
# Product > Test

# 4. Archive for TestFlight
# Product > Archive
```

If command-line builds are configured:

```bash
xcodebuild \
  -project app/ios/GettingMoneyApp.xcodeproj \
  -scheme GettingMoneyApp \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  test
```

## Required Environment Variables

None for v1.

The app has no authentication, no backend, and no third-party API dependency.

## Dev Server Start Command

Not applicable. This is a native iOS app.

Run locally through Xcode:

```bash
open app/ios/GettingMoneyApp.xcodeproj
```

## Project Structure

```text
GettingMoneyApp/
├── AGENTS.md
├── .env.example
├── docs/
│   ├── plan.md
│   ├── vision.md
│   ├── stack.md
│   ├── decisions.md
│   └── state.md
├── tasks/
├── reports/
├── app/
│   ├── ios/
│   │   ├── GettingMoneyApp.xcodeproj
│   │   ├── GettingMoneyApp/
│   │   └── GettingMoneyAppTests/
│   ├── backend/
│   └── shared/
└── tests/
```

## Alternatives Considered

| Option | Why rejected |
|---|---|
| React Native | Useful for cross-platform apps, but this project is iOS/TestFlight only and benefits from native Apple polish. |
| Flutter | Strong UI toolkit, but adds non-native build complexity for an iOS-only app. |
| Web app / PWA | Faster to ship in some cases, but does not match the requested TestFlight beta path. |
| Core Data directly | Powerful, but SwiftData is simpler and sufficient for local v1 storage. |
| SQLite directly | Maximum control, but unnecessary for the current data model and slower to build. |
| Firebase / Supabase | Cloud persistence is out of scope; v1 is local-only. |

## Architecture Notes

### Local persistence

SwiftData stores:

- Exercise definitions and whether optional dips are enabled.
- Daily targets and manual target overrides.
- Workout days.
- Rep entries.
- Daily money totals.
- Per-exercise and total debt balances.
- Round plans and payback preferences.

### Core calculation engines

Core rules live in pure services:

- `EarningsEngine`: calculates money earned from reps.
- `DebtEngine`: calculates missed reps, debt creation, and debt repayment.
- `TargetProgressionEngine`: applies two-week target increases and pull-up cap rules.
- `RoundPlanner`: splits target reps across selected rounds.
- `PaybackPlanner`: distributes existing debt into one-go or finance-plan repayment options.

### UI principles

- The first screen is the dashboard, not onboarding or marketing.
- Dashboard should feel like a premium personal finance app applied to calisthenics.
- Primary surfaces: Dashboard, Log Reps, Rounds, Debt, Settings.
- Use dense but calm status cards, strong numbers, progress rings, and native charts.
- Avoid clutter: no social feed, no coaching library, no real-money implication.
