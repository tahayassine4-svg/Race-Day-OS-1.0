# TestFlight Signing Fix

## Status: PASSED

## Problem
App Store Connect did not show a usable Getting Money bundle ID when creating a new app. The local Xcode project was still using the scaffold bundle ID:

`com.gettingmoney.GettingMoney`

That ID was not aligned with Yassine's Apple Developer namespace, while Project Tracker uses `com.yassine.projecttracker` and its widget uses `com.yassine.projecttracker.CaptureWidget`.

## Fix
Updated Getting Money signing and bundle settings:

- App bundle ID: `com.yassine.gettingmoney`
- Test bundle ID: `com.yassine.gettingmoney.tests`
- Team ID: `X8W4Z2A6JN`
- Signing style: Automatic
- Signing allowed: enabled
- `project.yml` updated so future XcodeGen regeneration keeps the same values.

## Verification
- Resolved build settings show:
  - `PRODUCT_BUNDLE_IDENTIFIER = com.yassine.gettingmoney`
  - `DEVELOPMENT_TEAM = X8W4Z2A6JN`
  - `CODE_SIGN_STYLE = Automatic`
  - `CODE_SIGNING_ALLOWED = YES`
- Full simulator tests: PASS — 90 tests in 20 suites.
- iOS archive: PASS
  - `apps/getting-money/build/GettingMoney.xcarchive`
- App Store Connect export: PASS
  - `apps/getting-money/build/export/GettingMoney.ipa`
- Exported IPA metadata:
  - Bundle ID: `com.yassine.gettingmoney`
  - Display name: `Getting Money`
  - Version: `1.0.0`
  - Build: `1`

## Next Step
In App Store Connect, create the new app and choose bundle ID:

`com.yassine.gettingmoney`

If the browser was already open, refresh App Store Connect or sign out/in. The export succeeded, so Xcode has usable signing/provisioning for this ID locally.
