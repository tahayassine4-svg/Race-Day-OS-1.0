# Stack — {{App Name}}

> Architect output. Exact technical choices + setup. See `knowledge/ios-stack.md` for the decision rules.

## Chosen stack
- **Stack:** {{1 Rapid Solo Indie / 2 Scalable Full-Stack / custom}}
- **Language/UI:** Swift 6, SwiftUI (strict concurrency on)
- **Persistence:** {{SwiftData / + CloudKit / Supabase}}
- **Sync:** {{CloudKit automatic / Supabase realtime / none}}
- **Auth:** {{none / Sign in with Apple / Supabase}}
- **Monetization:** {{none / RevenueCat + StoreKit 2 / ...}}
- **Analytics/crash:** {{TelemetryDeck / Crashlytics / none}}
- **Game module:** {{off / on — engine: ...}}

## Rationale (one line per major choice)
- {{}}

## Alternatives considered
- {{option — why rejected}}

## Setup
- Xcode project / scheme: {{}}
- Min deployment target: iOS {{}}
- Build: {{xcodebuild ... / open in Xcode}}
- Run: {{simulator + scheme}}

## Required env vars / secrets (keys only — never values)
- {{KEY_NAME}} — {{purpose}}

## Distribution
- Bundle ID: {{}}
- TestFlight / App Store status: {{}}
- Privacy manifest needed: {{yes/no — see knowledge/ios-launch.md}}
