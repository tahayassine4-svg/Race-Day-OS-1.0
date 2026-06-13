# Packet 03: Targets + Two-Week Progression

## Goal
Daily per-exercise targets, manual editing, and automatic two-week progression — driven by a pure, tested `TargetProgressionEngine`.

## UI?
**yes → Design Gate.** Targets/progression Settings UI → `design/packet-03.png` (follows the Packet 01 system).

## Requirements
- Pure `TargetProgressionEngine` (protocol-injected service, no persistence inside it).
- Individual daily targets: push-ups, pull-ups, squats, optional dips.
- Auto-increase eligible targets every 14 days by a configurable +5..+10.
- **Pull-up auto-progression capped at 10**; manual pull-up overrides may exceed 10.
- Manual target edits are authoritative for future calculations.
- Settings UI to edit targets, progression amount, frequency, pull-up cap, and an auto-progression toggle.

## Acceptance Criteria
- [ ] User can edit each enabled exercise target; values persist.
- [ ] Progression amount settable 5–10.
- [ ] After 14 days, eligible targets increase by the configured amount.
- [ ] Pull-up auto-progression never exceeds 10; manual override can.
- [ ] Auto-progression can be turned off and is never forced.

## Test Cases
- [ ] Swift Testing (parameterized): default progression, pull-up cap at 10, manual override >10, auto-off.
- [ ] Set push-ups to 50 → persists.
- [ ] Simulate 14-day progression from pull-ups 8 with +5 → result 10 (not 13).

## Files Expected
- `apps/getting-money/GettingMoney/Services/TargetProgressionEngine.swift`
- `apps/getting-money/GettingMoney/ViewModels/SettingsViewModel.swift`
- `apps/getting-money/GettingMoney/Views/Settings/SettingsView.swift`
- `apps/getting-money/GettingMoneyTests/TargetProgressionEngineTests.swift`
- `apps/getting-money/design/packet-03.html` + `packet-03.png`

## Dependencies
Packet 02 complete.

## Out of Scope
Rep entry · money/debt math · round splitting · payback plans.

## Retry Count
0
