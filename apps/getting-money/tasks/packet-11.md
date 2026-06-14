# Packet 11: Actionable Rounds + Settings Fixes

## Goal
Fix the Rounds feature (a passive planner that tracked nothing) and two Settings bugs, from
Yassine's report. Rounds becomes a workout you complete: tick off circles → reps land in the
daily balance; edit anytime; up to 10 rounds.

## UI?
Reworks the existing Rounds screen + a Settings row tweak. No new screens — verified via
`/ui-test` screenshots.

## Requirements (from Yassine)
- Rounds counter works and is tracked on the daily dashboard.
- Rounds are editable (before and after completing).
- "Start round" does something (was a dead button).
- Create up to **10** rounds; tick them off; completing adds reps to the Daily Balance.
- Dips (optional) can be turned **off** again after being turned on.
- Remove the Pull-up cap.

## What was built
- `RepEntry.sourceRoundNumber` (additive) tags reps logged by a round.
- `RoundsViewModel`: tick/untick (log/remove tagged reps), completion derived from tags,
  1–10 round stepper, count-lock once ticked, `completeNextRound`, money-from-rounds.
- `RoundsView`/`RoundCircleCard`: stepper, "Mark done", completed visual + Edit, progress, CTA.
- `WorkoutRepository.deleteRoundEntries`; `addRepEntry(sourceRoundNumber:)`.
- Settings: optional rows always keep a toggle (dips off-able); pull-up cap removed from UI +
  `TargetProgressionEngine`.

## Acceptance Criteria
- [x] Ticking a round logs its reps to the balance/dashboard.
- [x] Un-ticking removes exactly those reps.
- [x] Completion survives reload; edit via Edit (un-tick) works.
- [x] Up to 10 rounds; count locks after a tick.
- [x] Completing payoff rounds pays debt down.
- [x] Dips can be toggled off; pull-up cap gone.
- [x] Build green (88/88); archives for TestFlight.

## Test Cases
- [x] RoundsCompletionTests (8): tick→balance, untick, reload-survival, 10-cap, count-lock,
  edit-after-undo, payoff→debt, sourceRoundNumber persistence.
- [x] Settings: dips enable→disable round-trip; progression tests updated (pull-ups uncapped).

## Files
- `Models/RepEntry.swift` · `Repositories/WorkoutRepository.swift`
- `ViewModels/{Rounds,RepLogger,Settings}ViewModel.swift` · `Services/{TargetProgressionEngine,LocalStore}.swift`
- `Repositories/ExerciseRepository.swift` · `Views/Rounds/*` · `Views/Settings/{TargetSettingsList,ProgressionSettingsCard}.swift`
- `GettingMoneyTests/RoundsCompletionTests.swift` (+ updated progression/cross-screen/payback tests)

## Dependencies
Packets 09 (day-close) + 10 (live payback) complete.

## Out of Scope
Multi-select batch completion · animated rep count-up · per-round timers.

## Retry Count
0
