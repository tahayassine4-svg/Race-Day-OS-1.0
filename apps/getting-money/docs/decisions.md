# Decisions (ADR log) — Getting Money

> Append-only. Architect seeds it; Implementer appends any deviation immediately.

## 2026-06-13 — Native iOS, SwiftUI, local-only SwiftData
**Decision:** Build as a native iOS app (Swift 6 + SwiftUI), persist with SwiftData on-device only, no auth, no cloud. Target iOS 17, ship to TestFlight.
**Rationale:** Single-user, device-local data model; matches the requested TestFlight + local-storage goal; native polish fits the premium "bank" feel.
**Trade-offs:** No cross-device sync in v1 (CloudKit deferred). Apple-only.
**Status:** ACCEPTED

## 2026-06-13 — Money and rep-debt are separate systems
**Decision:** Earned money cannot reduce rep-debt; debt is repaid only by physically completing owed reps. Extra-rep priority: today's target → debt → bonus money.
**Rationale:** This separation is the product's core hook; it keeps the system physical and honest.
**Trade-offs:** Slightly less intuitive than "spend money to clear debt," but intentional.
**Status:** ACCEPTED

## 2026-06-13 — Core math lives in pure, injected Service engines
**Decision:** EarningsEngine, DebtEngine, TargetProgressionEngine, RoundPlanner, PaybackPlanner are pure services behind protocols, injected into ViewModels; no calculation in views.
**Rationale:** The economy math is the heart of the app and must be unit-tested in isolation (knowledge/ios-architecture.md, ios-testing.md).
**Trade-offs:** A little more upfront structure than inlining logic.
**Status:** ACCEPTED

## 2026-06-13 — Dark-mode design from the user's mockup (supersedes earlier light/amber draft)
**Decision:** The visual language is dark-first — graphite/black canvas, lime-green earnings/progress, coral-red debt/loss, soft glass cards, big tabular numbers — per `docs/spec.md` §24 and `design/reference-mockup.png`. An earlier (archived) light/white/amber ui-system draft is rejected.
**Rationale:** The user's written spec and provided mockup both specify dark + lime + coral; that is the canonical direction.
**Trade-offs:** None — aligns docs with the actual approved design intent.
**Status:** ACCEPTED

## 2026-06-13 — SwiftData models are CloudKit-compatible from day one (Packet 02)
**Decision:** Even with CloudKit OFF in v1, all `@Model`s follow CloudKit's automatic-sync rules: every stored property has a default value (or is optional), NO `@Attribute(.unique)`/`#Unique`, every relationship optional with an explicit `@Relationship(inverse:)`, no `.deny` delete rules. Uniqueness ("seed once", "one WorkoutDay per day") is enforced by **fetch-or-create in repositories/seeder**, not the schema. `WorkoutDay` stores a normalized `dayKey` (startOfDay). `DailyTarget` is a **dated record** (effectiveDate + reps) so progression has history. Models are wrapped in `SchemaV1: VersionedSchema`.
**Rationale:** Adding CloudKit later is then additive; retrofitting these rules would force a store reset that wipes TestFlight users. (Advisor-flagged.)
**Trade-offs:** Slightly more discipline now (defaults everywhere, repo-side uniqueness); a dated DailyTarget instead of a 1:1 field.
**Status:** ACCEPTED
