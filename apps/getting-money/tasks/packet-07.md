# Packet 07: Dynamic Debt Payback Planner

## Goal
Generate dynamic, exercise-aware debt repayment plans — pay-in-one-go or a finance plan over D days — that fold into rounds and recalculate live. Driven by a pure, tested `PaybackPlanner`.

## UI?
**yes → Design Gate.** Payback planner in Debt screen + optional debt allocation in Rounds → `design/packet-07.png`. Must show one-go, finance-plan, and round allocation — never implying real-money repayment.

## Requirements
- Pure `PaybackPlanner`: one-go plan from current per-exercise debt; finance plan distributing debt over D days (exercise-aware, remainder to earliest days).
- Plan recalculates when reps are logged, debt changes, targets change, or round count changes.
- Debt screen offers one-go / finance-plan when debt exists; Rounds screen can include a chosen payoff (none/small/medium/full/custom) folded into the round split.
- **No money-to-debt option anywhere** in logic or UI.

## Acceptance Criteria
- [ ] One-go and finance-plan options appear when debt exists.
- [ ] Plans are generated from current per-exercise debt and allocate to matching exercises.
- [ ] Changing round count / logging reps recalculates the plan and remaining debt.
- [ ] UI never offers paying debt with money.

## Test Cases
- [ ] Swift Testing: 30 push-up debt → one-go asks 30 push-ups; mixed debt → per-exercise allocation; rounds 3→5 changes per-round allocation; logging repayment decreases remaining.
- [ ] Grep UI text/actions for money-to-debt → none.
- [ ] Visual verification vs `design/packet-07.png`.

## Files Expected
- `apps/getting-money/GettingMoney/Services/PaybackPlanner.swift`
- `apps/getting-money/GettingMoney/ViewModels/{DebtViewModel,RoundsViewModel}.swift`
- `apps/getting-money/GettingMoney/Views/Debt/{DebtView,DebtPayoffCard}.swift`
- `apps/getting-money/GettingMoney/Views/Rounds/RoundsView.swift`
- `apps/getting-money/GettingMoneyTests/PaybackPlannerTests.swift`
- `apps/getting-money/design/packet-07.html` + `packet-07.png`

## Dependencies
Packet 06 complete.

## Out of Scope
Notifications · calendar scheduling · cloud sync · HealthKit.

## Retry Count
0
