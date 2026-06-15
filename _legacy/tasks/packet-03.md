# Packet 03: Targets + Two-Week Progression

## Goal

Implement daily exercise targets, manual target editing, and automatic two-week progression rules.

## Design Gate

- Designer must create `design/packet-03.html` and render `design/packet-03.png` for the target/progression settings UI.
- Yassine must approve `design/packet-03.png` before any UI implementation begins.
- The implementation must preserve the approved hierarchy for manual targets, progression amount, and pull-up cap controls.

## Requirements

- Add a pure `TargetProgressionEngine`.
- Support individual daily targets for push-ups, pull-ups, squats, and optional dips.
- Increase targets every two weeks by a configurable amount between 5 and 10 reps.
- Cap automatic pull-up target progression at 10 reps.
- Allow the user to manually override any target.
- Treat manual target changes as authoritative for future calculations.
- Add Settings UI for editing targets and progression amount.

## Acceptance Criteria

- [ ] The user can edit each enabled exercise target in Settings.
- [ ] The progression amount can be set between 5 and 10 reps.
- [ ] Automatic progression increases eligible targets after 14 days.
- [ ] Pull-up automatic progression does not exceed 10 reps.
- [ ] Manual pull-up target changes can exceed 10 reps.
- [ ] Unit tests cover default progression, pull-up cap, and manual overrides.

## Test Cases

- [ ] Set push-up target to 50 and verify the saved value persists.
- [ ] Simulate a 14-day progression and verify push-ups/squats increase by the configured amount.
- [ ] Simulate pull-up progression from 8 with +5 and verify the result is 10.
- [ ] Manually set pull-ups to 12 and verify the app accepts the override.
- [ ] Run target progression unit tests.

## Files Expected

- `app/ios/GettingMoneyApp/Services/TargetProgressionEngine.swift`
- `app/ios/GettingMoneyApp/ViewModels/SettingsViewModel.swift`
- `app/ios/GettingMoneyApp/Views/Settings/SettingsView.swift`
- `app/ios/GettingMoneyAppTests/TargetProgressionEngineTests.swift`
- `design/packet-03.html`
- `design/packet-03.png`

## Dependencies

Packet 02 must be complete.

## Out of Scope

- Rep entry.
- Money calculation.
- Debt creation.
- Round splitting.
- Payback plan generation.

## Retry Count

0
