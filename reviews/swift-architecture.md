# Swift Architecture / Data / Services Review Checklist

Used by the Code-Reviewer for models, repositories, services, networking, persistence, auth, and StoreKit. Mark each PASS / FAIL / N/A. Backed by `knowledge/ios-architecture.md`, `knowledge/ios-launch.md`, `knowledge/ios-testing.md`.

---

## Layer cake & dependency injection
- [ ] **Persistence behind Repositories** — `ModelContext`/queries live in repositories, never in views or ViewModels directly.
- [ ] **Dependencies injected** — ViewModels/services receive dependencies as `Sendable` protocols via `init`; nothing constructs its own dependencies internally.
- [ ] **Single responsibility** — each repository/service/function does one thing; no God objects.
- [ ] **ViewModels are @Observable @MainActor** and expose one screen's state.

## Concurrency (Swift 6)
- [ ] **Strict concurrency on** — no suppressed data-race warnings.
- [ ] **async/await, not Combine** — no new Combine pipelines; `AsyncSequence` for streams.
- [ ] **No blocking the main actor** — heavy work is off the main actor / awaited.

## Persistence & data safety
- [ ] **Migration safety** — any schema/model change on a shipped app has a `SchemaMigrationPlan` and a migration test (knowledge/ios-testing.md). New required fields are optional or store-defaulted.
- [ ] **CloudKit add-only respected** — no destructive rename/delete on synced models.
- [ ] **No silent data loss** — destructive operations are intentional and guarded.

## Security & secrets
- [ ] **No hardcoded secrets** — keys/tokens come from Keychain/build config, never source; nothing secret is logged.
- [ ] **Identity from the trusted source** — user identity from the authenticated session/Keychain, not from untrusted input.
- [ ] **Sign in with Apple first-sign-in** — name/email persisted on the FIRST authorization (knowledge/ios-launch.md).
- [ ] **StoreKit transactions verified** — JWS `VerificationResult` checked; entitlements via `Transaction.currentEntitlements`; transactions finished.
- [ ] **Input validated at boundaries** — external/network input validated before use; errors surfaced safely, not as raw internals.

## Privacy & launch (when relevant)
- [ ] **Privacy manifest** — required-reason APIs and collected data types declared (knowledge/ios-launch.md).
- [ ] **Account deletion path** exists if the app has registration.

## Code quality
- [ ] **Errors handled at boundaries** — async calls have do/catch; no swallowed errors, no force-unwraps on fallible calls.
- [ ] **No dead code** — no commented-out blocks, unused imports, unreachable branches.
