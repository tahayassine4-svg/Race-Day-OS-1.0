# Architecture Decisions — Getting Money App

## 2026-06-13 — Build Native iOS App

**Decision:** Getting Money App will be built as a native iOS app for TestFlight beta distribution.

**Rationale:** The requested deployment target is TestFlight, and native iOS gives the strongest path to a premium, app-native experience.

**Trade-offs:** No Android or web support in v1.

**Status:** ACCEPTED

## 2026-06-13 — Use Local-Only Data

**Decision:** All v1 data will be stored locally on device with no authentication, backend, or cloud sync.

**Rationale:** The app is primarily personal, privacy-friendly, and does not require accounts or shared data.

**Trade-offs:** Data will not sync across devices and will need a future migration plan if cloud sync is added.

**Status:** ACCEPTED

## 2026-06-13 — Use SwiftUI and SwiftData

**Decision:** The app will use SwiftUI for UI and SwiftData for local persistence.

**Rationale:** This is the simplest modern native Apple stack for a polished local-first iOS app.

**Trade-offs:** SwiftData requires modern iOS targets and gives less low-level control than direct SQLite.

**Status:** ACCEPTED

## 2026-06-13 — Keep Gamification Logic in Pure Services

**Decision:** Earnings, debt, target progression, round splitting, and payback planning will be implemented as pure Swift domain services.

**Rationale:** The money/debt rules are the product core and need to be easy to test independently from UI and persistence.

**Trade-offs:** Some view models may need mapping code between SwiftData models and pure calculation inputs.

**Status:** ACCEPTED

## 2026-06-13 — Money Cannot Pay Debt

**Decision:** Earned money is a motivational score and cannot be used to clear rep debt.

**Rationale:** This preserves the intended behavioral loop: missed reps must be paid back physically through reps.

**Trade-offs:** Some users may expect a finance metaphor to allow balance transfers, so UI copy must make the rule clear.

**Status:** ACCEPTED
