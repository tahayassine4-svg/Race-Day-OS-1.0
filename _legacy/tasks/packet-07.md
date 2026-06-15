# Packet 07: Dynamic Debt Payback Planner

## Goal

Generate dynamic debt repayment plans that can be completed in one go or distributed across workout rounds.

## Design Gate

- Designer must create `design/packet-07.html` and render `design/packet-07.png` for the debt payback planner UI.
- Yassine must approve `design/packet-07.png` before any UI implementation begins.
- The approved mockup must show one-go payoff, finance-plan payoff, and round allocation without implying real-money repayment.

## Requirements

- Add a pure `PaybackPlanner`.
- Generate a one-go payoff plan from current per-exercise debt.
- Generate a finance-plan-style payoff schedule based on debt, target reps, and selected rounds.
- Allocate debt repayment to matching exercises where possible.
- Update the plan when reps are logged, debt changes, targets change, or round count changes.
- Show the plan in the Debt screen.
- Show optional debt allocation in the Rounds screen.
- Ensure money cannot be applied to debt in the UI or logic.

## Acceptance Criteria

- [ ] The Debt screen offers one-go and finance-plan payoff options when debt exists.
- [ ] Payback plans are generated from current debt balances.
- [ ] Payback plans allocate reps to matching exercise debt.
- [ ] Changing round count recalculates the finance plan.
- [ ] Logging reps recalculates remaining debt and payoff plan.
- [ ] The UI never offers an option to pay debt with money.
- [ ] Unit tests cover one-go payoff, round-based payoff, and recalculation.

## Test Cases

- [ ] Create 30 push-up debt and verify one-go plan asks for 30 push-ups.
- [ ] Create mixed exercise debt and verify per-exercise payoff allocations.
- [ ] Change round count from 3 to 5 and verify per-round debt allocation changes.
- [ ] Log repayment reps and verify remaining plan decreases.
- [ ] Search UI text/actions and verify no money-to-debt payoff exists.
- [ ] Run payback planner unit tests.

## Files Expected

- `app/ios/GettingMoneyApp/Services/PaybackPlanner.swift`
- `app/ios/GettingMoneyApp/ViewModels/DebtViewModel.swift`
- `app/ios/GettingMoneyApp/ViewModels/RoundsViewModel.swift`
- `app/ios/GettingMoneyApp/Views/Debt/DebtView.swift`
- `app/ios/GettingMoneyApp/Views/Debt/DebtPayoffCard.swift`
- `app/ios/GettingMoneyApp/Views/Rounds/RoundsView.swift`
- `app/ios/GettingMoneyAppTests/PaybackPlannerTests.swift`
- `design/packet-07.html`
- `design/packet-07.png`

## Dependencies

Packet 06 must be complete.

## Out of Scope

- Push notifications.
- Calendar scheduling.
- Cloud sync.
- Apple Health integration.

## Retry Count

0
