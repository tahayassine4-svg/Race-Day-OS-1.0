# Packet 14 — Home-Screen Widget (Daily Targets)

UI? Yes (new WidgetKit extension). Backend? Small (App Group snapshot publisher).

## Goal
A home-screen widget that shows every daily exercise target and how much has been
done today, and opens the app when tapped. Built so the optional Dips row appears
automatically if it is ever enabled.

## Decision (vs. interactive "+1")
The user asked for a "+1 in the widget" if feasible, else a read-only deep-link
widget. An interactive (+1) widget would require either moving the live SwiftData
store into the App Group (a migration risk on the already-shipped TestFlight build)
or a fragile pending-write queue. Per the user's stated fallback, this packet ships
the **read-only, tap-to-open** widget. The app stays the single writer of data;
the widget only reads a snapshot.

## Architecture
- **No store move.** The app writes a small Codable `WidgetSnapshot` of *today's*
  targets to App Group `group.com.yassine.gettingmoney`; the widget reads it. The
  live SwiftData store is untouched (TestFlight data safe).
- `Shared/WidgetShared.swift` (compiled into both targets): `WidgetSnapshot` /
  `WidgetExercise`, the App Group read/write bridge, inline palette, and the pure
  `DailyTargetsContent` SwiftUI view (screenshot-verifiable in-app).
- `GettingMoney/Services/WidgetSnapshotPublisher.swift`: pure `buildSnapshot`
  (filters `.isEnabled`, so Dips appears once enabled) + `publish()` (save + reload).
- `GettingMoneyWidget/`: WidgetBundle + StaticConfiguration + TimelineProvider,
  families `.systemMedium` / `.systemLarge`, midnight refresh fallback.
- Publisher wired into `AppRootView` (`.task`, tab-switch, foreground) — always
  publishes *today*, regardless of the dashboard's selected day.

## Acceptance criteria
- [x] Widget lists each enabled exercise with `completed/target` and a progress bar.
- [x] Tapping the widget opens the app (StaticConfiguration default deep-link).
- [x] Enabling the optional Dips exercise makes it appear in the widget — no code change.
- [x] App writes the snapshot to the App Group; widget reads it (verified on disk).
- [x] Live SwiftData store is NOT moved into the App Group (TestFlight data safe).
- [x] App + widget targets build; full unit suite stays green.

## Provisioning (Yassine — required before TestFlight)
The App Group + widget extension need App Store Connect / Developer Portal setup
that cannot be done from code. See `reports/packet-14-report.md` → "Provisioning".
