# Packet 08: History, Polish + TestFlight Readiness

## Goal
Finish v1: history charts, designed empty/loading/error states, beta utilities, accessibility pass, and a TestFlight-ready archive.

## UI?
**yes → Design Gate.** Final polished Dashboard/history/Settings + empty states → `design/packet-08.png`.

## Requirements
- Swift Charts: bank balance, debt trend, streak history.
- Designed states: first launch, no debt, no reps today, dips disabled.
- Settings: local data reset (with confirmation) and a simple export, for beta testing.
- Accessibility pass: VoiceOver labels on core actions/status; Dynamic Type and Reduce Motion verified on major screens (count-up/transitions disabled under Reduce Motion).
- App icon placeholder + launch screen.
- Privacy manifest (`PrivacyInfo.xcprivacy`): no tracking, no data collection; declare UserDefaults required-reason (`CA92.1`) if used.
- Document the TestFlight archive/upload steps in the report.

## Acceptance Criteria
- [ ] Dashboard shows ≥1 history chart when data exists.
- [ ] Empty states for no reps / no debt / first launch.
- [ ] Local data reset works after confirmation.
- [ ] Core controls have VoiceOver labels; Reduce Motion disables nonessential animation.
- [ ] App builds, all tests pass.
- [ ] Project archives for TestFlight (or any signing blocker is documented).

## Test Cases
- [ ] Swift Testing: history aggregation feeds charts; reset clears local data → first-launch empty state.
- [ ] VoiceOver inspection: core actions labeled.
- [ ] Reduce Motion on → no count-up/transition animation.
- [ ] `xcodebuild` test pass; archive validation (or documented signing blocker).
- [ ] Visual verification vs `design/packet-08.png`.

## Files Expected
- `apps/getting-money/GettingMoney/Views/Dashboard/{DashboardView,TrendChart}.swift`
- `apps/getting-money/GettingMoney/Views/Settings/SettingsView.swift`
- `apps/getting-money/GettingMoney/Utilities/{AccessibilityLabels,ExportLocalData}.swift`
- `apps/getting-money/GettingMoney/Assets.xcassets`
- `apps/getting-money/GettingMoney/PrivacyInfo.xcprivacy`
- `apps/getting-money/GettingMoneyTests/HistoryTests.swift`
- `apps/getting-money/design/packet-08.html` + `packet-08.png`

## Dependencies
Packet 07 complete.

## Out of Scope
Production App Store submission · App Store screenshots · cloud sync · subscriptions · watch app.

## Retry Count
0
