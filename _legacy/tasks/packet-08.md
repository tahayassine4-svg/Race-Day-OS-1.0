# Packet 08: History, Polish + TestFlight Readiness

## Goal

Finish the app with history visualizations, premium UI polish, beta utilities, and TestFlight readiness checks.

## Design Gate

- Designer must create `design/packet-08.html` and render `design/packet-08.png` for the final polished dashboard/history/settings state.
- Yassine must approve `design/packet-08.png` before any UI polish implementation begins.
- The approved mockup must include final empty states, history chart direction, and beta utility placement.

## Requirements

- Add Swift Charts visualizations for bank balance, debt trend, and streak history.
- Add empty states for first launch, no debt, no reps today, and disabled optional dips.
- Add local data reset/export controls for beta testing.
- Polish Dashboard, Log, Rounds, Debt, and Settings according to `DESIGN.md`.
- Add accessibility labels for core actions and status components.
- Verify Dynamic Type and Reduce Motion behavior for major screens.
- Add app icon placeholder and launch screen configuration if needed.
- Document TestFlight archive steps in the report.

## Acceptance Criteria

- [ ] Dashboard shows at least one history chart when history data exists.
- [ ] Empty states exist for no reps, no debt, and first launch.
- [ ] Local data can be reset from Settings after confirmation.
- [ ] Core controls have VoiceOver labels.
- [ ] Reduce Motion disables nonessential animations.
- [ ] The app builds and tests cleanly.
- [ ] The project can be archived for TestFlight.

## Test Cases

- [ ] Add sample history and verify charts render.
- [ ] Clear local data and verify first-launch empty state appears.
- [ ] Enable VoiceOver inspection and verify core actions have labels.
- [ ] Enable Reduce Motion and verify count-up or transition animations are disabled.
- [ ] Run all unit tests.
- [ ] Run Xcode archive validation or document any local signing blocker.

## Files Expected

- `app/ios/GettingMoneyApp/Views/Dashboard/DashboardView.swift`
- `app/ios/GettingMoneyApp/Views/Dashboard/TrendChart.swift`
- `app/ios/GettingMoneyApp/Views/Settings/SettingsView.swift`
- `app/ios/GettingMoneyApp/Utilities/AccessibilityLabels.swift`
- `app/ios/GettingMoneyApp/Utilities/ExportLocalData.swift`
- `app/ios/GettingMoneyApp/Assets.xcassets`
- `app/ios/GettingMoneyAppTests/HistoryTests.swift`
- `reports/packet-08-report.md`
- `design/packet-08.html`
- `design/packet-08.png`

## Dependencies

Packet 07 must be complete.

## Out of Scope

- Production App Store submission.
- App Store screenshots.
- Cloud sync.
- Paid subscriptions.
- Apple Watch app.

## Retry Count

0
