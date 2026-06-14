# Packet 12: Dashboard Daily Date Selector

## Goal
Let the Dashboard's Daily view move across recent days so Yassine can inspect logged reps, target progress, earned money, and balance for previous days without leaving the main screen.

## Requirements
- Add previous/next day controls to the Dashboard header.
- Keep Today as the default selected day and provide a direct jump back to Today.
- Reload Dashboard rows, daily totals, chart window, planned rounds, and balance for the selected date.
- Clamp navigation to the recent day-close window and never navigate into the future.
- Preserve the existing dark/lime visual system and avoid header text wrapping on iPhone width.

## Acceptance Criteria
- [x] Dashboard opens on Today.
- [x] Previous day reloads that day's completed reps and balance.
- [x] Next day returns toward Today and cannot go past Today.
- [x] Header controls fit cleanly on iPhone 17 Pro width.
- [x] Full test suite passes.

## Test Cases
- [x] `Dashboard daily selector reloads the selected day's reps and balance`.
- [x] Full `xcodebuild ... test` suite on iPhone 17 Pro simulator.
- [x] Simulator screenshot with history fixture.

## Files Expected
- `GettingMoney/ViewModels/DashboardViewModel.swift`
- `GettingMoney/Views/Dashboard/DashboardView.swift`
- `GettingMoneyTests/HistoryTests.swift`
- `reports/artifacts/qa/p12-dashboard-daily-toggle.png`

## Dependencies
Packets 08 (history), 09 (day-close), 10 (live payback), and 11 (actionable rounds) complete.

## Out of Scope
Calendar picker, infinite history browsing, historical debt reconstruction, new persistence fields, and Git push.

## Retry Count
0
