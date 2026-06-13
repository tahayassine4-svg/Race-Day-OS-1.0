# Packet 01: Foundation + Premium Design System

## Goal
A runnable native iOS SwiftUI app shell with the Getting Money tab navigation, the dark design system from the mockup, and a premium (non-functional) Dashboard placeholder.

## UI?
**yes → Design Gate required.** This packet establishes the visual language; the Designer builds the design system + mockup first, grounded in `design/reference-mockup.png` and `knowledge/ios-design.md`.

## Requirements
- Create the Xcode project `apps/getting-money/GettingMoney.xcodeproj` (scheme `GettingMoney`, iOS 17+, Swift 6).
- SwiftUI app entry point `GettingMoneyApp`.
- Tab shell: Dashboard · Log · Rounds · Debt · Settings. Dashboard launches first.
- Design system in Swift from `docs/ui-system.md`: dark canvas, lime-green earnings/progress, coral-red debt/loss, color tokens, typography (tabular figures for numbers), spacing/radius scales, status styles, reusable primitives (card surface, status pill, progress visual).
- Non-functional Dashboard placeholder demonstrating the premium bank hierarchy (balance, debt, streak, exercise progress) with sample data only.

## Acceptance Criteria
- [ ] Builds and runs on an iPhone simulator.
- [ ] First screen is Dashboard; all five tabs open.
- [ ] Dashboard shows placeholder bank balance, debt, streak, and exercise progress using design-system tokens (not ad-hoc styling).
- [ ] Dark-mode palette matches the approved mockup; text contrast holds.
- [ ] No persistence, networking, or auth present.

## Test Cases
- [ ] Build via Xcode / `xcodebuild` from `docs/stack.md` → success.
- [ ] Launch simulator, open all five tabs.
- [ ] Visual verification: simulator screenshot matches approved `design/packet-01.png`.
- [ ] Grep project for network/auth deps → none.

## Files Expected
- `apps/getting-money/GettingMoney.xcodeproj`
- `apps/getting-money/GettingMoney/GettingMoneyApp.swift`
- `apps/getting-money/GettingMoney/DesignSystem/{GMColor,GMTypography,GMSpacing,GMRadius,GMStatusStyle}.swift`
- `apps/getting-money/GettingMoney/DesignSystem/Components/{GMCard,GMStatusPill,GMProgressRing}.swift`
- `apps/getting-money/GettingMoney/Views/AppRootView.swift`
- `apps/getting-money/GettingMoney/Views/{Dashboard/DashboardView,Logger/LogView,Rounds/RoundsView,Debt/DebtView,Settings/SettingsView}.swift`
- `apps/getting-money/GettingMoneyTests/SmokeTests.swift`
- `apps/getting-money/docs/ui-system.md`
- `apps/getting-money/design/packet-01.html` + `packet-01.png`

## Dependencies
None.

## Out of Scope
SwiftData persistence · real rep logging · money/debt math · editable targets · TestFlight archive.

## Retry Count
0
