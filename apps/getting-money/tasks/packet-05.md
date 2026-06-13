# Packet 05: DebtEngine + Debt Dashboard

## Goal
Convert missed daily reps into per-exercise rep-debt, enforce the money≠debt separation, and surface debt clearly.

## UI?
**yes → Design Gate.** Debt screen + Dashboard debt state → `design/packet-05.png`. The mockup must make debt actionable and must NOT offer any money-to-debt payoff.

## Requirements
- Pure `DebtEngine`: at day close, `debt = max(0, target − completed)` per exercise; track per-exercise + total debt.
- **Money can never reduce debt.** Extra completed reps (beyond today's target) reduce matching-exercise debt — priority: today's target → debt → bonus money.
- Debt screen: total debt, per-exercise breakdown (reps owed), next action.
- Dashboard status: green (on track/over) / yellow (behind) / red (debt) with label+icon, never color alone.

## Acceptance Criteria
- [ ] Missed reps become per-exercise debt at day close.
- [ ] Total debt = sum of per-exercise debt.
- [ ] Earned money never reduces debt.
- [ ] Extra matching-exercise reps reduce that exercise's debt (priority rule honored).
- [ ] Dashboard shows debt status when debt exists.

## Test Cases
- [ ] Swift Testing: debt creation (target 50, done 30 → 20 owed), repayment via extra reps, money-does-not-pay-debt, priority order, total = sum.
- [ ] Grep UI for any "pay with money" action → none.
- [ ] Visual verification vs `design/packet-05.png`.

## Files Expected
- `apps/getting-money/GettingMoney/Services/DebtEngine.swift`
- `apps/getting-money/GettingMoney/ViewModels/{DebtViewModel,DashboardViewModel}.swift`
- `apps/getting-money/GettingMoney/Views/Debt/DebtView.swift`
- `apps/getting-money/GettingMoney/Views/Dashboard/DashboardView.swift`
- `apps/getting-money/GettingMoneyTests/DebtEngineTests.swift`
- `apps/getting-money/design/packet-05.html` + `packet-05.png`

## Dependencies
Packet 04 complete.

## Out of Scope
Multi-day finance payback plans · rounds allocation · charts/history · notifications.

## Retry Count
0
