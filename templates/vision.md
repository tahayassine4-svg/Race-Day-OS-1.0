# Vision — {{App Name}}

> Architect output. The shared, unambiguous picture of what we're building and why. Copied to `apps/{{app-name}}/docs/vision.md`.

## One-paragraph summary
{{What the app is, for whom, and the single core value.}}

## Target user
- **Who:** {{role / context of use}}
- **Technical level:** {{}}
- **Primary context:** {{where/when they use it — informs ergonomics & design}}

## Core problem (one sentence)
{{}}

## Core loop (the 10-second "what they do")
{{do → see → value → repeat}}

## v1 must-have features (MoSCoW — Must only)
1. {{}}
2. {{}}
3. {{}}

## Explicitly out of scope for v1 (Should/Could/Won't)
- {{}}

## Platform & integration
- Platform: iOS (SwiftUI). Min iOS: {{}}
- System integration considered: {{widgets / Live Activities / App Intents / watchOS / HealthKit / none}}

## Auth & data
- Auth: {{none / Sign in with Apple / Supabase / ...}}
- Persistence: {{SwiftData local / + CloudKit sync / Supabase}}

## Distribution constraint (HARD if shipped)
- Already shipped with real user data? {{no / yes — TestFlight / App Store}}. If yes: every persistence change must preserve data (migration test required).

## Game module
- Gamified? {{no / yes}} — if yes, see `knowledge/game-design.md`.

## The concept that makes it not generic
{{The one specific idea — like an ADA winner — driving the design. Not "a clean modern app."}}
