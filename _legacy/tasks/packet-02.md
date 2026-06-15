# Packet 02: Local Data Models + Persistence

## Goal

Add local SwiftData models and persistence plumbing for exercises, targets, workout days, rep entries, debt, rounds, and app settings.

## Design Gate

- Designer must update `docs/ui-system.md` only if Settings UI structure changes materially.
- Designer must create `design/packet-02.html` and render `design/packet-02.png` for the Settings persistence surface.
- Yassine must approve `design/packet-02.png` before any Settings UI implementation begins.
- Backend/model work may proceed only after the approved packet scope is clear; any visible UI must match the approved mockup.

## Requirements

- Define SwiftData models for Exercise, DailyTarget, WorkoutDay, RepEntry, DebtBalance, RoundPlan, and AppSettings.
- Configure the app's SwiftData model container.
- Seed default exercises: push-ups, pull-ups, squats, with dips disabled by default.
- Add basic repository/service access for reading and writing local app state.
- Add a Settings screen section that shows persisted exercise enablement and default target values.
- Ensure data persists after app termination and relaunch.

## Acceptance Criteria

- [ ] Default exercises are created on first launch exactly once.
- [ ] Push-ups, pull-ups, and squats are enabled by default.
- [ ] Dips exist as an optional exercise and are disabled by default.
- [ ] Settings displays persisted exercise and target data.
- [ ] A changed setting remains changed after app restart.
- [ ] No cloud sync, auth, or remote database dependency exists.

## Test Cases

- [ ] Launch the app on a fresh simulator and verify default exercises exist.
- [ ] Change the dips enabled state, terminate the app, relaunch, and verify the state persisted.
- [ ] Run unit tests for default data seeding.
- [ ] Run app build/tests and verify no persistence errors occur.

## Files Expected

- `app/ios/GettingMoneyApp/Models/Exercise.swift`
- `app/ios/GettingMoneyApp/Models/DailyTarget.swift`
- `app/ios/GettingMoneyApp/Models/WorkoutDay.swift`
- `app/ios/GettingMoneyApp/Models/RepEntry.swift`
- `app/ios/GettingMoneyApp/Models/DebtBalance.swift`
- `app/ios/GettingMoneyApp/Models/RoundPlan.swift`
- `app/ios/GettingMoneyApp/Models/AppSettings.swift`
- `app/ios/GettingMoneyApp/Services/AppDataSeeder.swift`
- `app/ios/GettingMoneyApp/Services/LocalStore.swift`
- `app/ios/GettingMoneyApp/Views/Settings/SettingsView.swift`
- `app/ios/GettingMoneyAppTests/PersistenceTests.swift`
- `design/packet-02.html`
- `design/packet-02.png`

## Dependencies

Packet 01 must be complete.

## Out of Scope

- Target progression rules.
- Rep logging UI.
- Earnings calculation.
- Debt repayment.
- Charts or history visualizations.

## Retry Count

0
