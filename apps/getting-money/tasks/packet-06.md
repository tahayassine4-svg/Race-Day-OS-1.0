# Packet 06: Rounds / Circles Planner

## Goal
Auto-split daily targets across a chosen number of rounds, with editable rounds and live totals — driven by a pure, tested `RoundPlanner`.

## UI?
**yes → Design Gate.** Rounds screen (round-count control, split targets, editable round cards, total preview) → `design/packet-06.png`.

## Requirements
- Pure `RoundPlanner`: `base = floor(target / rounds)`, `remainder = target % rounds`; the first `remainder` rounds get +1. Splits preserve the exact daily total.
- User chooses round count; each enabled exercise target splits across rounds.
- Editable round cards: increase/decrease reps per round; daily total + extra-money preview recalculates.
- Persist today's `RoundPlan` via the repository.

## Acceptance Criteria
- [ ] User chooses a round count; targets split across all rounds.
- [ ] Uneven splits preserve the exact daily total (remainder to earliest rounds).
- [ ] Editing a round updates the daily preview.
- [ ] Round plan persists after restart.

## Test Cases
- [ ] Swift Testing: 60/3 → 20·20·20; 10/3 → 4·3·3; 50/3 sums to 50; edited round recomputes totals.
- [ ] Restart → saved round plan remains.
- [ ] Visual verification vs `design/packet-06.png`.

## Files Expected
- `apps/getting-money/GettingMoney/Services/RoundPlanner.swift`
- `apps/getting-money/GettingMoney/ViewModels/RoundsViewModel.swift`
- `apps/getting-money/GettingMoney/Views/Rounds/{RoundsView,RoundCircleCard}.swift`
- `apps/getting-money/GettingMoneyTests/RoundPlannerTests.swift`
- `apps/getting-money/design/packet-06.html` + `packet-06.png`

## Dependencies
Packet 05 complete.

## Out of Scope
Debt payback allocation (Packet 07) · history charts · notifications · watch.

## Retry Count
0
