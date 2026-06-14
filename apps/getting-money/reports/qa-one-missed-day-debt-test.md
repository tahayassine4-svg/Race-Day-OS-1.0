# QA: One Missed Day Debt UI Test

## Status: PASSED

## Scenario
Boot the app as if yesterday was missed completely and today is a fresh day. The launch day-close path should create exactly one day of rep debt:

- Push-ups: 100 reps owed
- Pull-ups: 10 reps owed
- Squats: 150 reps owed
- Total: 260 reps owed

## Fixture
Added DEBUG-only launch argument:

`-GMSeedOneMissedDayFixture`

This backdates enabled default targets to yesterday, marks the app as last settled through yesterday, and lets the normal `DayCloseService.run()` on app launch create the debt. Production behavior is unchanged.

## Test Results
- Full Swift Testing suite: PASS — 90 tests in 20 suites.
- Existing backend debt test: PASS — `A single missed past day creates debt equal to the missed reps`.
- Dashboard UI screenshot: PASS — active debt is visible, balance is `$0`, today is `0 / 260 reps`, and the first-launch empty state does not hide the debt.
- Debt UI screenshot: PASS — shows `$260`, `260 reps owed`, finance plan split as 88 / 86 / 86 reps over 3 days, and breakdown begins with 100 push-ups owed.
- Rounds payoff UI screenshot: PASS — Full payoff folds `+260` into today's rounds; planned total becomes `520 / 260 reps · +260 payoff`; CTA is available to complete round 1.

## Artifacts
- `reports/artifacts/qa/p13-one-missed-day-dashboard.png`
- `reports/artifacts/qa/p13-one-missed-day-debt.png`
- `reports/artifacts/qa/p13-one-missed-day-rounds-payoff.png`

## Notes
The one-day debt loop behaves as designed in the UI: money cannot clear debt, the Debt tab gives a repayment plan, and the Rounds tab can fold the owed reps into today's workout.
