# Packet 02: Local Data Models + Persistence (SwiftData)

## Goal
Local SwiftData models + persistence plumbing for exercises, targets, workout days, rep entries, debt, rounds, and app settings, behind Repositories.

## UI?
**Mostly backend** — only a small Settings section to prove persistence. If that section is materially new, the Designer adds `design/packet-02.png`; otherwise it follows the Packet 01 design system and skips a new Design Gate.

## Requirements
- SwiftData `@Model`s: `Exercise`, `DailyTarget`, `WorkoutDay`, `RepEntry`, `DebtBalance`, `RoundPlan`, `AppSettings`.
- Configure the `ModelContainer` at the app entry point.
- A `LocalStore` / repository layer for all reads/writes — **no `ModelContext`/`@Query` in views** (`knowledge/ios-architecture.md`).
- Seed defaults once on first launch: push-ups, pull-ups, squats enabled; **dips present but disabled by default**.
- Settings section shows persisted exercise enablement + default targets.
- **Schema versioning from day one:** wrap models in a `VersionedSchema` so future changes (incl. eventual CloudKit) are additive/migratable.

## Acceptance Criteria
- [ ] Default exercises seeded exactly once on a fresh install.
- [ ] Push-ups/pull-ups/squats enabled; dips exist and are disabled by default.
- [ ] Settings displays persisted data; a changed setting survives app restart.
- [ ] Views never touch `ModelContext`/`@Query` directly — access is via the repository.
- [ ] No cloud/auth/remote dependency.

## Test Cases
- [ ] Swift Testing: seeding creates defaults once (not duplicated on second launch).
- [ ] Toggle dips, terminate, relaunch → state persisted (use an in-memory container in tests; manual relaunch for the real store).
- [ ] Repository read/write round-trip test.
- [ ] (Migration test N/A until shipped — but assert the `VersionedSchema` is in place so a future migration test can build a v1 store.)

## Files Expected
- `apps/getting-money/GettingMoney/Models/{Exercise,DailyTarget,WorkoutDay,RepEntry,DebtBalance,RoundPlan,AppSettings}.swift`
- `apps/getting-money/GettingMoney/Models/SchemaV1.swift`
- `apps/getting-money/GettingMoney/Services/{AppDataSeeder,LocalStore}.swift`
- `apps/getting-money/GettingMoney/Repositories/{ExerciseRepository,WorkoutRepository}.swift`
- `apps/getting-money/GettingMoney/Views/Settings/SettingsView.swift`
- `apps/getting-money/GettingMoneyTests/PersistenceTests.swift`

## Dependencies
Packet 01 complete.

## Out of Scope
Target progression rules · rep logging UI · earnings/debt math · charts/history.

## Retry Count
0
