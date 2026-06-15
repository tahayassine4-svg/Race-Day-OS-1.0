# Packet 04: Rep Logging + Earnings Engine

## Goal

Build fast rep logging and money earning logic for all enabled exercises.

## Design Gate

- Designer must create `design/packet-04.html` and render `design/packet-04.png` for the Log screen and Dashboard progress update.
- Yassine must approve `design/packet-04.png` before any UI implementation begins.
- The approved mockup must show how reps can be logged quickly and how earnings feedback appears.

## Requirements

- Add a pure `EarningsEngine`.
- Create a Log screen where the user can add reps for each enabled exercise in under 10 seconds.
- Support quick-add and stepper-style rep entry.
- Save rep entries locally with exercise, count, timestamp, and workout day.
- Calculate money earned for every logged rep.
- Calculate over-target earnings separately from base daily target progress.
- Update Dashboard progress from real logged reps.

## Acceptance Criteria

- [ ] The user can log reps for push-ups, pull-ups, and squats.
- [ ] Dips appear in Log only when enabled.
- [ ] Logged reps persist after app restart.
- [ ] Dashboard daily progress updates after logging reps.
- [ ] Every logged rep increases total money.
- [ ] Over-target reps are identified separately in calculation output.
- [ ] Unit tests cover base earnings and over-target earnings.

## Test Cases

- [ ] Log 10 push-ups and verify today's push-up progress increases by 10.
- [ ] Log reps, restart the app, and verify the entries still exist.
- [ ] Log reps beyond a target and verify over-target earnings are calculated.
- [ ] Disable dips and verify dips are hidden from Log.
- [ ] Enable dips and verify dips can be logged.
- [ ] Run earnings unit tests.

## Files Expected

- `app/ios/GettingMoneyApp/Services/EarningsEngine.swift`
- `app/ios/GettingMoneyApp/ViewModels/RepLoggerViewModel.swift`
- `app/ios/GettingMoneyApp/ViewModels/DashboardViewModel.swift`
- `app/ios/GettingMoneyApp/Views/Logger/LogView.swift`
- `app/ios/GettingMoneyApp/Views/Dashboard/DashboardView.swift`
- `app/ios/GettingMoneyAppTests/EarningsEngineTests.swift`
- `app/ios/GettingMoneyAppTests/RepLoggingTests.swift`
- `design/packet-04.html`
- `design/packet-04.png`

## Dependencies

Packet 03 must be complete.

## Out of Scope

- Debt creation for missed reps.
- Debt repayment.
- Rounds planner.
- Historical charts.
- TestFlight archive setup.

## Retry Count

0
