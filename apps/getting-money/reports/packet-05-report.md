# Packet 05 Report: DebtEngine + Debt Dashboard

## Status: PASSED

## What Was Built
- Added pure `DebtEngine` for missed-rep debt, matching-exercise repayment, and bonus-rep allocation.
- Added repository helpers for reading and writing per-exercise `DebtBalance` rows.
- Added `DebtViewModel` for total debt, per-exercise breakdown, and a three-day payoff plan.
- Updated `DashboardViewModel` and Dashboard UI to show active debt status, per-exercise debt labels, and current rep debt totals.
- Replaced the placeholder Debt tab with the approved Packet 05 debt surface.
- Added DEBUG-only `-GMSeedDebtFixture` launch support to visually verify the 36-rep active-debt state without changing release behavior.
- Added Packet 05 Swift Testing coverage for engine rules, persistence, Debt tab totals, and Dashboard active-debt status.

## Test Results
- Baseline before implementation: PASS — 23 existing tests passed.
- `xcodegen generate`: PASS.
- `xcodebuild -project GettingMoney.xcodeproj -scheme GettingMoney -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test`: PASS — 30 tests passed.
- Grep for money-to-debt payoff wording/actions: PASS — no prohibited payoff language found.
- Runtime visual verification with `-GMSeedDebtFixture`: PASS.

## Review Results
- Code quality: PASS — debt math is isolated in a pure service; persistence stays behind repositories; views read injected observable view models.
- Security: PASS — local SwiftData only, no secrets, no network, no money/payments integration.
- Architecture adherence: PASS — SwiftData does not leak into SwiftUI views.
- Regression check: PASS — Packets 01-04 tests still pass.
- Visual check: PASS — screenshots captured at `reports/artifacts/packet-05-dashboard-debt.jpg` and `reports/artifacts/packet-05-debt.jpg`; runtime snapshot confirmed the full debt breakdown and "only reps" rule.

## Acceptance Criteria
- [x] Missed reps become per-exercise debt at day close.
- [x] Total debt = sum of per-exercise debt.
- [x] Earned money never reduces debt.
- [x] Extra matching-exercise reps reduce that exercise's debt; priority rule honored.
- [x] Dashboard shows debt status when debt exists.

## Issues Found
- Fixed during testing: `GMRadius.card` was not a real design token; changed to `GMRadius.module`.
- Fixed during testing: one engine test expected the wrong total after partial debt repayment; corrected the expected debt to match the priority rule.
- Fixed during testing: new integration tests needed `Foundation` for `Date`.

## Trade-offs Made
- The Debt tab's "Add payoff to today's rounds" button is a disabled handoff surface for Packet 06/07 planning; it does not perform allocation yet.
- Day-close automation is not scheduled yet; Packet 05 provides the engine and repository persistence path, while future app lifecycle work can decide when to invoke it.

## Retry Count
0 of 3

## Git
- Branch: packet-05-debt-engine
- Feature commit: 03b4122
- Pushed: yes

## Next Packet Preview
Packet 06 — Rounds / Circles Planner: split daily targets into rounds and prepare the surface that will later absorb debt payoff reps.
