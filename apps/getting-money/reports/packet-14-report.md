# Packet 14 Report: Home-Screen Widget (Daily Targets)

## Status: PASSED (simulator-verified) — provisioning steps required before TestFlight

## What Was Built
A WidgetKit home-screen widget ("Daily Targets") that shows every enabled exercise
with today's `completed / target` and a lime progress bar, plus an overall percent.
Tapping it opens Getting Money. Supports `.systemMedium` and `.systemLarge`.

The widget never touches SwiftData. The app writes a small Codable `WidgetSnapshot`
of *today's* targets into the shared App Group (`group.com.yassine.gettingmoney`);
the widget reads it back. This deliberately keeps the live SwiftData store out of the
App Group, so the already-shipped TestFlight store is not migrated or moved.

### Read-only (tap-to-open), not interactive "+1"
The request allowed a fallback: *"if it's too complicated, just create a widget where
you see your daily target and then you can click on it and it goes to the app."* A
true interactive +1 would require moving the live store into the App Group (migration
risk on shipped data) or a fragile pending-write queue. This packet ships the safe
read-only deep-link widget. An interactive version can be a later packet once a
store-sharing strategy is proven safe.

### Future-proofed for Dips
`buildSnapshot` filters `.isEnabled`, so the optional Dips exercise appears in the
widget automatically the moment it is enabled — no widget code change. Verified.

## Files
- `Shared/WidgetShared.swift` — `WidgetSnapshot` / `WidgetExercise` (Codable), App
  Group read/write bridge, inline palette, pure `DailyTargetsContent` view + placeholder.
- `GettingMoney/Services/WidgetSnapshotPublisher.swift` — pure `buildSnapshot` +
  `publish()` (save + `WidgetCenter.reloadAllTimelines()`).
- `GettingMoneyWidget/GettingMoneyWidgetBundle.swift` — bundle, `DailyTargetsWidget`
  (StaticConfiguration), `DailyTargetsProvider` (timeline + midnight refresh).
- `GettingMoney/GettingMoney.entitlements`, `GettingMoneyWidget/GettingMoneyWidget.entitlements`
  — App Group entitlement on both targets.
- `GettingMoney/Views/AppRootView.swift` — publishes today's snapshot on appear,
  tab switch, and foreground.
- `GettingMoney/GettingMoneyApp.swift` — DEBUG `-GMWidgetPreview` screenshot harness.
- `project.yml` — widget app-extension target, App Group entitlements, embed widget,
  generated extension `Info.plist` (NSExtensionPointIdentifier=widgetkit-extension).
- `GettingMoneyTests/WidgetSnapshotTests.swift` — 4 new tests.

## Test Results
- `xcodebuild test ... -scheme GettingMoney`: PASS — **96/96** tests (92 prior + 4 new).
  - Fresh snapshot lists the 3 default targets, no reps, Dips hidden.
  - Logged reps reflected as completed; `isMet`/fraction correct.
  - Enabling Dips makes it appear in the snapshot (target 30).
  - Snapshot round-trips through the App Group Codable encoding.
- Build: PASS — app + embedded widget extension build for the simulator.
- Widget UI (in-app harness, `simctl` screenshots):
  - `reports/artifacts/qa/p14-widget-preview-default.png` — 3 rows, partial progress.
  - `reports/artifacts/qa/p14-widget-preview-dips-progress.png` — 4 rows incl. Dips;
    31% = (37+4+50+0)/(100+10+150+30) = 91/290, matches displayed value.
- App Group end-to-end: PASS — launching the real app wrote
  `dailyTargetsSnapshot.v1` (all 4 exercises incl. Dips) to the shared container at
  `…/Containers/Shared/AppGroup/…/Library/Preferences/group.com.yassine.gettingmoney.plist`.

## Static-screenshot limits
`simctl` cannot render a live home-screen WidgetKit timeline, so the widget's *visual*
output is verified via the in-app `DailyTargetsContent` harness (the exact same view
the widget renders) and its *data path* via the App Group on-disk write + the snapshot
unit tests. The TimelineProvider wiring (placeholder/getSnapshot/getTimeline) is thin
and reads the same `WidgetShared.load()` that the round-trip test covers.

## Provisioning — REQUIRED before TestFlight (Yassine, in Apple Developer / Xcode)
This cannot be done from code; the App Group + extension need portal registration:
1. **Apple Developer → Identifiers → App Groups:** create `group.com.yassine.gettingmoney`.
2. **App ID `com.yassine.gettingmoney`:** enable the **App Groups** capability and
   add that group. Do the same for a new App ID
   **`com.yassine.gettingmoney.widget`** (the widget extension) — enable App Groups,
   add the same group.
3. **App Store Connect:** the widget ships *inside* the app — no separate ASC record,
   but the extension bundle ID must have a matching provisioning profile (automatic
   signing in Xcode handles this once the App IDs + group exist).
4. **Archive from Xcode** (Product → Archive) with automatic signing so both the app
   and the `.appex` get profiles that include the App Group, then upload. Bump the
   build number (`CURRENT_PROJECT_VERSION`) for the new TestFlight build.

Until step 1–2 are done, the App Group write is a silent no-op on device (works on the
simulator without portal setup), so the widget would show placeholder data.

## Review
- Code quality: PASS — pure builder isolated and unit-tested; widget has no SwiftData
  dependency; publisher is best-effort and never throws into the app.
- Security: PASS — local App Group only; no secrets, no network.
- Architecture: PASS — app is the single writer; widget is read-only; live store untouched.
- Data safety: PASS — SwiftData store NOT moved to the App Group; no schema/migration change.

## Retry Count
0 of 3
