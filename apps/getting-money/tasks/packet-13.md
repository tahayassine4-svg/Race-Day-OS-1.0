# Packet 13: Past-Day Rep Corrections

## Goal
Let past days be corrected from the Dashboard and Log flow, with debt recalculated from the corrected historical totals.

## Requirements
- Dashboard past-day exercise rows and the Log action open the Log tab for the selected day.
- Log supports editing historical totals, including reducing previously logged reps down to zero.
- Today's Log behavior remains append-only.
- Saving a past-day correction replaces manual entries for that day while preserving completed-round entries.
- Current debt is reconciled from the old-vs-new past-day completion totals.
- Returning to Dashboard after a correction preserves the selected past day.

## Acceptance Criteria
- [x] A past Dashboard day can open Log for that date.
- [x] Past Log shows date-specific copy and a Save corrections CTA.
- [x] Increasing a missed past day to target clears matching debt.
- [x] Reducing a completed past day below target adds matching debt back.
- [x] Dashboard shows corrected past-day reps after saving.
- [x] Existing today logging and live debt tests still pass.

## Test Cases
- [x] `Past-day corrections replace logged totals and clear matching debt`
- [x] `Past-day corrections can lower reps and add debt back`
- [x] Full `xcodebuild test` suite on iPhone 17 Pro simulator.
- [x] Simulator UI: select yesterday on Dashboard, open Log, edit reps, save, return to Dashboard.

## Files Expected
- `GettingMoney/Repositories/WorkoutRepository.swift`
- `GettingMoney/ViewModels/RepLoggerViewModel.swift`
- `GettingMoney/ViewModels/DashboardViewModel.swift`
- `GettingMoney/Views/AppRootView.swift`
- `GettingMoney/Views/Dashboard/DashboardView.swift`
- `GettingMoney/Views/Logger/LogView.swift`
- `GettingMoneyTests/RepLoggingTests.swift`
- `reports/packet-13-report.md`
- `reports/artifacts/qa/p13-past-day-log-editable.jpg`
- `reports/artifacts/qa/p13-past-day-dashboard-after-correction.jpg`

## Dependencies
Packet 12 Dashboard daily selector must exist.

## Out of Scope
- Editing round-tagged completed reps directly from historical Log.
- Calendar-style date picker.
- Re-archiving or uploading a TestFlight build.

## Retry Count
0
