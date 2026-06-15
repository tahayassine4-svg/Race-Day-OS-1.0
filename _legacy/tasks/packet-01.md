# Packet 01: iOS Foundation + Premium Design System

## Goal

Create a runnable native iOS SwiftUI app shell with the Getting Money App navigation, design system, and premium dashboard placeholder.

## Design Gate

- Designer must create or update `docs/ui-system.md`.
- Designer must create `design/packet-01.html` and render `design/packet-01.png`.
- Yassine must approve `design/packet-01.png` before any SwiftUI implementation begins.
- The HTML mockup is a visual spec only; the shipped app must be native SwiftUI matching the approved image.

## Requirements

- Create the iOS project under `app/ios/GettingMoneyApp`.
- Configure a SwiftUI app entry point named `GettingMoneyApp`.
- Add a tab-based app shell with Dashboard, Log, Rounds, Debt, and Settings tabs.
- Add a design system with color tokens, typography helpers, spacing constants, status styles, and reusable primitive components.
- Build a non-functional Dashboard placeholder that demonstrates the intended premium bank-style UI hierarchy.
- Include local preview/sample data only; no persistence or business logic yet.

## Acceptance Criteria

- [ ] The app builds successfully for an iPhone simulator.
- [ ] The first launched screen is Dashboard.
- [ ] The tab bar contains Dashboard, Log, Rounds, Debt, and Settings.
- [ ] Dashboard displays placeholder bank balance, debt balance, streak, and exercise progress sections.
- [ ] Design tokens from `DESIGN.md` are represented in Swift code.
- [ ] No authentication, network calls, or backend configuration exists.
- [ ] All visible UI text has sufficient contrast in light mode.

## Test Cases

- [ ] Run the app in an iPhone simulator and verify all five tabs can be opened.
- [ ] Run the build command from `docs/stack.md` or Xcode Product > Build and verify success.
- [ ] Inspect the project for network/auth dependencies and verify none are present.
- [ ] Verify Dashboard uses the design system colors/components rather than ad hoc styling.

## Files Expected

- `app/ios/GettingMoneyApp.xcodeproj`
- `app/ios/GettingMoneyApp/GettingMoneyApp.swift`
- `app/ios/GettingMoneyApp/DesignSystem/GMColor.swift`
- `app/ios/GettingMoneyApp/DesignSystem/GMTypography.swift`
- `app/ios/GettingMoneyApp/DesignSystem/GMSpacing.swift`
- `app/ios/GettingMoneyApp/DesignSystem/GMStatusStyle.swift`
- `app/ios/GettingMoneyApp/Views/AppRootView.swift`
- `app/ios/GettingMoneyApp/Views/Dashboard/DashboardView.swift`
- `app/ios/GettingMoneyApp/Views/Logger/LogView.swift`
- `app/ios/GettingMoneyApp/Views/Rounds/RoundsView.swift`
- `app/ios/GettingMoneyApp/Views/Debt/DebtView.swift`
- `app/ios/GettingMoneyApp/Views/Settings/SettingsView.swift`
- `app/ios/GettingMoneyAppTests/GettingMoneyAppTests.swift`
- `docs/ui-system.md`
- `design/packet-01.html`
- `design/packet-01.png`

## Dependencies

None.

## Out of Scope

- SwiftData persistence.
- Real rep logging.
- Money calculation.
- Debt calculation.
- Editable targets.
- TestFlight archive setup.

## Retry Count

0
