# iOS Testing & Data Safety

> The **Tester** reads this. Two jobs: prove the acceptance criteria with Swift Testing, and prove that persistence changes never wipe real user data.

## Swift Testing (the framework, iOS 18+)

Use the native **Swift Testing** framework, not legacy XCTest, for new tests.

- `@Suite` groups tests; `@Test` marks a test function.
- `#expect(...)` for assertions; `#require(...)` for optional-safe unwrap that **halts** on failure (prevents cascading failures).
- `async`/`await` supported out of the box; tests run in parallel by default.
- Prefer value-type `struct` suites — a fresh instance per test gives clean state isolation. Use `class` only when `deinit` cleanup is required.
- `.tags(...)` and parameterized `arguments:` for boundary tables.

```swift
import Testing
@testable import MyApp

@Suite("Username validation")
struct UsernameTests {
    @Test("rejects too-short, accepts valid", arguments: [
        ("a", false), ("ab", false), ("abc", true), ("", false)
    ])
    func validate(name: String, ok: Bool) {
        #expect(UsernameValidator.validate(name) == ok)
    }
}
```

**Every acceptance criterion maps to at least one test. An untested criterion is FAILED.** Test pure logic (validators, calculations, ViewModel state transitions) and service boundaries. Inject mock repositories via the DI protocols (see `knowledge/ios-architecture.md`).

## Data-safety / migration test (MANDATORY when persistence/schema/migrations change on a shipped app)

If the app is live on TestFlight/App Store with real data, a schema change is **guilty until proven innocent**. A passing build does NOT prove data safety. A Swift default value is NOT a store-level default.

For the full recipe (old-schema store → insert real data → migrate → assert no loss), load `.claude/skills/swiftdata-migration-test` — it only needs to be in context for packets that actually touch the schema.

## Visual verification (MANDATORY when UI changed)

UI frameworks fail silently in source — reading the code does not prove the screen is right.

1. Boot the iOS Simulator, build & run the app (or the relevant view in a preview/UI test host).
2. Capture a real screenshot (`xcrun simctl io booted screenshot out.png`).
3. Compare against the approved `design/packet-NN.png`.

A view that compiles but doesn't match the approved mockup is a **FAIL** → back to Implementer.

## Reporting

Report exact output — never summarize away a failure message. Map each criterion to PASS/FAIL. Verdict is PASSED, FAILED, or PARTIAL (core works but ≥1 criterion unmet → treated as FAILED). On the 3rd consecutive failure of the same packet, stop and escalate with a full diagnosis instead of proposing more fixes.
