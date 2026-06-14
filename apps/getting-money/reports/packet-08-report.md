# Packet 08 Report: History, Polish + TestFlight Readiness

## Status: PASSED (signing/upload handoff to Yassine, as agreed)

## What Was Built
- **History charts (Swift Charts):** pure `HistoryEngine` builds a 14-day daily series (per-day reps/earnings + cumulative bank balance, with a baseline for entries older than the window) and a current-streak calc. `TrendChart` renders Balance (area+line), Daily (bars), and Streak (active/missed bars), switched by a segmented control on the Dashboard.
- **Designed states:** first-launch empty Dashboard ("Your bank is open"); Debt and Rounds already show no-debt states from earlier packets; Settings empty-data still functions.
- **Settings beta utilities:** new **Data** section — Export my data (JSON snapshot via `ShareLink`) and Reset all local data (destructive, behind a `confirmationDialog`). New **About** section (version + privacy). Backed by a `LocalDataAdmin` protocol on `LocalStore` (`hasAnyActivity` / `resetAllLocalData` / `exportSnapshotData`).
- **Accessibility pass:** `GMAccessibility` VoiceOver phrasing for balance/streak/debt/exercise rows; combined accessibility elements on key cards; Reduce-Motion-aware bank-balance count-up (numeric content transition that snaps under Reduce Motion).
- **App icon + accent:** branded 1024² icon (lime "$" coin on graphite) in `Assets.xcassets/AppIcon.appiconset`; `AccentColor` colorset; wired via `ASSETCATALOG_COMPILER_*` in `project.yml`. Launch screen uses the generated dark launch surface.
- **Privacy manifest:** `PrivacyInfo.xcprivacy` declares no tracking, no data collection, no required-reason APIs (app uses no UserDefaults / tracking / network).
- Version bumped to `1.0.0`.

## Test Results
- `xcodebuild ... test` on iPhone 17 Pro: PASS — **63 tests** (added 10 for Packet 08: history bucketing/baseline/streak, reset-clears-to-empty, export-decodable, dashboard history/empty flags).
- `xcodebuild archive ... CODE_SIGNING_ALLOWED=NO`: **ARCHIVE SUCCEEDED** — the app archives cleanly; only signing + upload remain.
- Visual verification on iPhone 17 Pro: PASS — Dashboard with charts `reports/artifacts/p08-dashboard.png`, first-launch empty state `p08-empty.png`, Settings `p08-settings.png`. Match `design/packet-08.png` / `design/packet-08-states.png`.

## Acceptance Criteria
- [x] Dashboard shows ≥1 history chart when data exists (Balance/Daily/Streak).
- [x] Empty states for no reps / first launch (no-debt states from prior packets).
- [x] Local data reset works after confirmation (unit-tested: reset → first-launch empty state; re-seeds defaults).
- [x] Core controls have VoiceOver labels; Reduce Motion disables the count-up animation.
- [x] App builds, all tests pass (63/63).
- [x] Project archives for TestFlight (unsigned archive verified); signing blocker documented below.

## TestFlight archive & upload steps (for Yassine)
The app is archive-ready; signing is intentionally off in `project.yml`
(`CODE_SIGNING_ALLOWED: NO`, empty `DEVELOPMENT_TEAM`). To ship to TestFlight:

1. In `project.yml`, set `DEVELOPMENT_TEAM: <your 10-char Team ID>`, remove/!set `CODE_SIGNING_ALLOWED: NO`, then `xcodegen generate`.
2. Open `GettingMoney.xcodeproj` in Xcode → target **GettingMoney** → Signing & Capabilities → check **Automatically manage signing**, pick your team. Bundle id `com.gettingmoney.GettingMoney` must be registered (Xcode will create it).
3. Confirm a unique build number each upload (`CURRENT_PROJECT_VERSION`).
4. Product → Destination → **Any iOS Device (arm64)** → Product → **Archive**.
5. In the Organizer: **Distribute App → TestFlight (Internal/External) → Upload**. Let Xcode handle the distribution signing.
6. In App Store Connect → TestFlight: complete export-compliance (no encryption beyond OS defaults → answer "No"), then add internal testers.

CLI alternative once signing is configured:
`xcodebuild -project GettingMoney.xcodeproj -scheme GettingMoney -destination 'generic/platform=iOS' -archivePath build/GettingMoney.xcarchive archive`
then `xcodebuild -exportArchive -archivePath build/GettingMoney.xcarchive -exportOptionsPlist ExportOptions.plist -exportPath build/export` with an App Store `ExportOptions.plist`.

## Issues Found
None blocking. SwiftData batch-delete in `resetAllLocalData()` re-seeds defaults so the app is never left empty of exercises.

## Trade-offs Made
- "Debt trend" from the spec is not historically reconstructed — debt isn't snapshotted per day in the local model — so the chart offers Balance/Daily/Streak (all derivable from logged reps). Faithful and honest given the data model; a stored daily-debt snapshot could be added later.
- Launch screen uses the system-generated dark surface rather than a custom branded storyboard (sufficient for beta; brand polish is a fast-follow).
