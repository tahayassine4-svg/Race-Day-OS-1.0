# Packet 04: Rep Logging + EarningsEngine

## Goal
Fast rep logging for enabled exercises, with money-earning logic driven by a pure, tested `EarningsEngine`, and live Dashboard progress.

## UI?
**yes → Design Gate.** Log screen + Dashboard progress update → `design/packet-04.png`. Logging must be completable in under 10 seconds (thumb-reachable quick-add + stepper).

## Requirements
- Pure `EarningsEngine`: `money = completed reps × repValue` ($1 default); daily, total, and over-target (bonus) earnings computed separately.
- Log screen: quick-add and stepper rep entry per enabled exercise; dips appear only when enabled.
- Persist `RepEntry` (exercise, count, timestamp, workout day) via the repository.
- Dashboard daily progress and earned amount update from real logged reps.
- Haptic + count-up feedback on log (respect Reduce Motion).

## Acceptance Criteria
- [ ] Log reps for push-ups/pull-ups/squats; dips only when enabled.
- [ ] Logged reps persist after restart.
- [ ] Dashboard daily progress + earnings update after logging.
- [ ] Every logged rep increases total money; over-target reps reported separately.

## Test Cases
- [ ] Swift Testing: base earnings, over-target earnings split, repValue math.
- [ ] Log 10 push-ups → today's push-up progress +10; restart → entries remain.
- [ ] Disable dips → hidden from Log; enable → loggable.
- [ ] Visual verification vs `design/packet-04.png`.

## Files Expected
- `apps/getting-money/GettingMoney/Services/EarningsEngine.swift`
- `apps/getting-money/GettingMoney/ViewModels/{RepLoggerViewModel,DashboardViewModel}.swift`
- `apps/getting-money/GettingMoney/Views/Logger/LogView.swift`
- `apps/getting-money/GettingMoney/Views/Dashboard/DashboardView.swift`
- `apps/getting-money/GettingMoneyTests/{EarningsEngineTests,RepLoggingTests}.swift`
- `apps/getting-money/design/packet-04.html` + `packet-04.png`

## Dependencies
Packet 03 complete.

## Out of Scope
Debt creation/repayment · rounds planner · history charts · TestFlight archive.

## Retry Count
0
