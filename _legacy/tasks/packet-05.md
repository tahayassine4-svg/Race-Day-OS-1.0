# Packet 05: Debt Engine + Debt Dashboard

## Goal

Convert missed daily reps into debt, track debt per exercise, and expose debt status clearly in the app.

## Design Gate

- Designer must create `design/packet-05.html` and render `design/packet-05.png` for the Debt screen and Dashboard debt state.
- Yassine must approve `design/packet-05.png` before any UI implementation begins.
- The approved mockup must make debt actionable and must not offer any money-to-debt payoff action.

## Requirements

- Add a pure `DebtEngine`.
- Calculate missed reps for each enabled exercise at day close.
- Convert missed reps into per-exercise debt.
- Track total debt and per-exercise debt locally.
- Ensure money cannot reduce debt.
- Allow completed reps beyond today's target to reduce existing debt for the same exercise.
- Add a Debt screen with total debt, per-exercise debt, and next action.
- Update Dashboard to show on-track, over-target, or debt status.

## Acceptance Criteria

- [ ] Missed reps become debt when a workout day closes.
- [ ] Debt is tracked separately for each exercise.
- [ ] Total debt equals the sum of per-exercise debt.
- [ ] Earned money never reduces debt.
- [ ] Extra completed reps can reduce matching exercise debt.
- [ ] Dashboard displays debt status when debt exists.
- [ ] Unit tests cover debt creation, debt repayment, and money/debt separation.

## Test Cases

- [ ] Create a day with target 50 push-ups and 30 logged reps, then verify 20 push-up debt is created.
- [ ] Log extra push-ups on a later day and verify push-up debt decreases.
- [ ] Earn money without extra matching reps and verify debt does not decrease.
- [ ] Verify total debt equals per-exercise debt sum.
- [ ] Run debt engine unit tests.

## Files Expected

- `app/ios/GettingMoneyApp/Services/DebtEngine.swift`
- `app/ios/GettingMoneyApp/ViewModels/DebtViewModel.swift`
- `app/ios/GettingMoneyApp/ViewModels/DashboardViewModel.swift`
- `app/ios/GettingMoneyApp/Views/Debt/DebtView.swift`
- `app/ios/GettingMoneyApp/Views/Dashboard/DashboardView.swift`
- `app/ios/GettingMoneyAppTests/DebtEngineTests.swift`
- `design/packet-05.html`
- `design/packet-05.png`

## Dependencies

Packet 04 must be complete.

## Out of Scope

- Multi-day finance-style payback plans.
- Rounds allocation.
- Charts and long-term history.
- Notifications.

## Retry Count

0
