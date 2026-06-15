# iOS MVP, Monetization & Launch

> The **Architect** (scoping, monetization), **Implementer** (StoreKit, auth, privacy), and **Reporter/Deployer** (launch readiness) draw on this.

## The roadmap (where any packet sits)

```
Idea validation → MVP scoping (core loop) → Architecture/stack → Internal alpha (Simulator)
→ External beta (feedback) → TestFlight staged rollout → Release candidate + App Review → App Store + ASO
```

## MVP scope — MoSCoW (prevent over-building before validation)

Categorize the backlog. Ship only what proves the core loop.

- **Must have** — features critical to the core value loop.
- **Should have** — important but not critical (e.g. profiles).
- **Could have** — deferrable (custom themes).
- **Won't have (now)** — complex/expensive (advanced AI, multi-provider auth).

Common fatal mistake: complex cloud architecture / custom engines / multi-tier monetization **before** the loop is validated. Don't.

## The "Aha moment" / onboarding

Get the user to the core value as fast as possible. Don't gate it behind a paywall or heavy registration. Example: a task app lets you create tasks locally first, *then* offers an account for cloud sync.

## Monetization (align model to category)

- **Productivity** → subscription (compounding recurring revenue funds development).
- **Fitness** → weekly subscription + free trial (high intent, watch churn).
- **Personal development** → hybrid: subscription + consumable IAP for standalone content.
- **Games** → consumable IAP (currency, lives) and/or hybrid ads.

Metrics: **MRR**, monthly **churn** (target < 8%), **LTV = ARPU / churn**.

**Enroll in the Apple Small Business Program** → 15% commission instead of 30%. Skipping it is leaving money on the table.

### StoreKit 2 (the implementation spine)

- Fetch with `Product.products(for:)`; purchase with `product.purchase(...)`.
- Verify every transaction's JWS (`VerificationResult` → `.verified` / `.unverified`); finish with `transaction.finish()`.
- Use `Transaction.currentEntitlements` for active entitlements and a background `Transaction.updates` listener for renewals/refunds.
- Prefer **RevenueCat** over raw StoreKit for paywalls/entitlement state unless there's a reason to go serverless-native.

## Sign in with Apple — the first-sign-in trap

If the app offers ANY third-party social login it MUST also offer Sign in with Apple (Guideline 4.8).

**Apple returns the user's name + email ONLY on the very first authorization.** Subsequent auths return only the stable user ID (`sub`). → **Persist name/email to Keychain/DB immediately on first sign-in.** If a network failure happens after auth but before account creation, that profile data is lost forever. Use a hashed nonce (`SecRandomCopyBytes` → SHA256) to bind the request.

## App Store launch requirements

- **Privacy manifest** (`PrivacyInfo.xcprivacy`) — declare tracking, tracking domains, collected data types + purposes, and required-reason API usage (for first-party AND third-party SDKs). Common reason codes: UserDefaults `CA92.1`, File timestamp `C617.1`.
- **Account deletion** — any app with registration must offer an in-app path to delete the account and revoke linked tokens.
- **ASO** — high-fidelity screenshots per required device size; clear description + target keywords in App Store Connect.

## Post-launch loop

- Telemetry: track cohorts, retention, drop-off points.
- Crash diagnostics (e.g. Crashlytics / TestFlight) prioritized by user impact.
- **In-app review** via `RequestReviewAction` — prompt only after a positive milestone (a completed task/flow), never mid-critical-task or on first launch.
