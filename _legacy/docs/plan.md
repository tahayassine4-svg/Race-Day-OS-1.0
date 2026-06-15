# Architecture Plan — Getting Money App

## App Summary

Getting Money App is a native iOS calisthenics tracker where reps behave like income and missed reps behave like debt. The product turns simple daily exercises into a premium banking-style dashboard: users set daily targets for push-ups, pull-ups, squats, and optional dips; log reps; earn motivational money; build streaks; and pay down rep debt through dynamic repayment plans. The app is local-first, requires no authentication, and is built for TestFlight beta distribution.

## Recommended Tech Stack

| Layer | Technology | Rationale |
|---|---|---|
| App platform | Native iOS | Matches the requested TestFlight distribution path and gives the best app-native feel. |
| UI framework | SwiftUI | Fast iteration, modern iOS patterns, strong fit for dashboard, cards, charts, forms, and responsive layouts. |
| Language | Swift | Native Apple platform language with strong type safety and excellent local persistence support. |
| Architecture | MVVM with small domain services | Keeps UI state, local data, and calculation engines separated without over-engineering a personal beta app. |
| Persistence | SwiftData | Local-first persistence with native Swift models, no backend, and low setup cost. |
| Charts | Swift Charts | Native, polished visualizations for progress, debt, streaks, and bank-style history. |
| Testing | XCTest + Swift Testing where available | Covers calculation engines, persistence behavior, and critical money/debt rules. |
| Distribution | Xcode archive to TestFlight | Standard beta path for iOS apps. |

## Folder and Architecture Structure

```text
GettingMoneyApp/
├── AGENTS.md
├── docs/
│   ├── plan.md
│   ├── vision.md
│   ├── stack.md
│   ├── decisions.md
│   └── state.md
├── tasks/
│   ├── packet-index.md
│   └── packet-01.md ...
├── reports/
├── app/
│   ├── ios/
│   │   ├── GettingMoneyApp.xcodeproj
│   │   ├── GettingMoneyApp/
│   │   │   ├── GettingMoneyApp.swift
│   │   │   ├── Models/
│   │   │   │   ├── Exercise.swift
│   │   │   │   ├── DailyTarget.swift
│   │   │   │   ├── WorkoutDay.swift
│   │   │   │   ├── RepEntry.swift
│   │   │   │   ├── DebtBalance.swift
│   │   │   │   └── RoundPlan.swift
│   │   │   ├── Services/
│   │   │   │   ├── EarningsEngine.swift
│   │   │   │   ├── DebtEngine.swift
│   │   │   │   ├── TargetProgressionEngine.swift
│   │   │   │   ├── RoundPlanner.swift
│   │   │   │   └── PaybackPlanner.swift
│   │   │   ├── ViewModels/
│   │   │   │   ├── DashboardViewModel.swift
│   │   │   │   ├── RepLoggerViewModel.swift
│   │   │   │   ├── RoundsViewModel.swift
│   │   │   │   └── DebtViewModel.swift
│   │   │   ├── Views/
│   │   │   │   ├── Dashboard/
│   │   │   │   ├── Logger/
│   │   │   │   ├── Rounds/
│   │   │   │   ├── Debt/
│   │   │   │   └── Settings/
│   │   │   ├── DesignSystem/
│   │   │   └── Utilities/
│   │   └── GettingMoneyAppTests/
│   └── shared/
├── tests/
└── .env.example
```

## Module Breakdown

1. **iOS Foundation + Design System**
   - Create the SwiftUI app shell, navigation, local SwiftData container, base models, and premium visual system.

2. **Exercise Targets + Progression**
   - Add daily targets for push-ups, pull-ups, squats, and optional dips, including manual edits and two-week automatic target progression.

3. **Rep Logging + Earnings Engine**
   - Build fast rep entry, daily progress tracking, and money calculation for all logged reps and over-target reps.

4. **Debt Engine**
   - Convert missed daily reps into per-exercise debt, track total debt, and keep money separate from debt repayment.

5. **Rounds / Circles Planner**
   - Split daily targets across chosen rounds, handle uneven splits, support editable rounds, and recalculate totals.

6. **Dynamic Debt Payback Planner**
   - Generate debt repayment plans that can be added to rounds or completed in one go, recalculating when reps, rounds, or debt changes.

7. **Premium Dashboard + History**
   - Build the bank-style dashboard with earnings, streaks, debt status, daily progress, historical trends, and app-level polish.

8. **TestFlight Readiness**
   - Add app icon placeholders, beta-safe settings, local data reset/export tools, final testing, archive readiness, and TestFlight checklist.

## Key Technical Decisions and Trade-offs

- **SwiftData over SQLite/Core Data directly:** SwiftData is faster to build with and fits the local-only requirement. Direct SQLite would give more control but slow v1 development.
- **No backend:** This keeps v1 private, fast, and TestFlight-friendly. The trade-off is no cross-device sync.
- **MVVM over heavier modular architecture:** MVVM is enough for this app’s current complexity. A heavier architecture would add ceremony before the product loop is proven.
- **Pure calculation services:** Earnings, debt, target progression, rounds, and payback plans should be pure Swift services with tests. This reduces bugs in the core gamification rules.
- **Money as motivational points:** The app must avoid implying real financial value. UI copy should make it feel like a game/bank metaphor while keeping the logic internal and clear.

## Product Rules

- Every rep earns money.
- Money cannot pay debt.
- Missed reps become debt after a day closes.
- Debt can only be reduced by additional completed reps.
- Over-target reps earn additional money.
- Pull-up auto-progression caps at 10 reps by default.
- Manual target changes always override automatic progression.
- Payback plans must recalculate from current debt, targets, round count, and completed reps.
