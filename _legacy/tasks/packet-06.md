# Packet 06: Rounds / Circles Planner

## Goal

Add rounds/circles that automatically split daily exercise targets across a selected number of workout rounds.

## Design Gate

- Designer must create `design/packet-06.html` and render `design/packet-06.png` for the Rounds screen.
- Yassine must approve `design/packet-06.png` before any UI implementation begins.
- The approved mockup must show round count control, split targets, editable rounds, and total preview.

## Requirements

- Add a pure `RoundPlanner`.
- Let the user choose the number of rounds for today's workout.
- Split each enabled exercise target across the selected rounds.
- Handle uneven splits predictably, with earlier rounds receiving the remainder.
- Display each round as an editable circle/round plan.
- Allow the user to increase or decrease reps inside individual rounds.
- Recalculate daily totals and extra money preview when round edits change.
- Persist today's round plan locally.

## Acceptance Criteria

- [ ] The user can choose a round count.
- [ ] Daily targets are split across all selected rounds.
- [ ] Uneven target splits preserve the exact daily target total.
- [ ] The user can edit individual round reps.
- [ ] Edited round totals update the daily preview.
- [ ] Round plans persist after app restart.
- [ ] Unit tests cover even splits, uneven splits, and edited rounds.

## Test Cases

- [ ] Split 60 push-ups across 3 rounds and verify 20/20/20.
- [ ] Split 50 push-ups across 3 rounds and verify the total remains 50.
- [ ] Edit a round upward and verify the app previews extra reps/money.
- [ ] Restart the app and verify the saved round plan remains.
- [ ] Run round planner unit tests.

## Files Expected

- `app/ios/GettingMoneyApp/Services/RoundPlanner.swift`
- `app/ios/GettingMoneyApp/ViewModels/RoundsViewModel.swift`
- `app/ios/GettingMoneyApp/Views/Rounds/RoundsView.swift`
- `app/ios/GettingMoneyApp/Views/Rounds/RoundCircleCard.swift`
- `app/ios/GettingMoneyAppTests/RoundPlannerTests.swift`
- `design/packet-06.html`
- `design/packet-06.png`

## Dependencies

Packet 05 must be complete.

## Out of Scope

- Debt payback plan allocation.
- Long-term history charts.
- Notifications.
- Apple Watch support.

## Retry Count

0
