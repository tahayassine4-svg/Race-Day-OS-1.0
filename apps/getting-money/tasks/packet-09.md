# Packet 09: Debt Day-Close Engine (make rep-debt actually accrue)

## Goal
Wire up the missing core mechanic: missed daily targets become persisted rep-debt. The
`DebtEngine` and all debt/payback/rounds-payoff UI already exist and are unit-tested, but
nothing in production ever closes a day — so persisted debt is always 0. This packet adds
the day-close that settles each completed past day on launch/foreground, with a gamified,
recoverable **2-day debt ceiling**. It is the missing twin of `TargetProgressionEngine`'s
on-launch elapsed-days catch-up.

(Discovered by the full UI/system QA pass — see `reports/qa-full-ui-test.md`, Gap 3.)

## UI?
**Backend-first → no Design Gate.** Debt already renders on the existing Dashboard debt
strip + status pill and the Debt tab; this packet only makes those numbers non-zero in real
use. One small optional copy addition (a "Capped at 2 days" caption on the Debt hero when at
the ceiling) — if it grows beyond a caption, produce a design addendum first.

## Design decisions (approved by Yassine 2026-06-14)
- **Trigger:** settle on app launch **and** on `scenePhase → .active` (no background task).
- **Multi-day absence → 2-Day Debt Ceiling:** each exercise's persisted debt is clamped to
  `capMultiplier × that exercise's current target` (default `capMultiplier = 2`). A long
  absence can never pile debt past 2 days of targets — keeps it recoverable and on-spec
  ("does not shame the user") while still having teeth.
- **Chronological settlement:** settle each completed calendar day from `lastSettledDate`
  up to (but not including) today, oldest first, so a strong day's surplus repays earlier
  debt (existing `DebtEngine` per-day rule).
- **Today stays live:** today is never settled until it becomes a past day.
- **Bank untouched:** day-close writes only debt; bank balance stays the sum of logged reps
  (bank and debt remain separate, per spec).
- **No rest-day concept:** the cap is the fairness mechanism; rest days are out of scope.

## Requirements
- Add `lastSettledDate: Date?` and `debtCapMultiplier: Int = 2` to `AppSettings` (additive).
- New `DayCloseService` (pure/testable): given `lastSettledDate`, today, per-exercise targets
  and that day's logged reps + existing debt, produce the chronological settlements with the
  cap applied; advance `lastSettledDate` to the start of today.
- Persist via existing `ExerciseRepository.applyDebtSettlements`, extended to clamp each
  exercise's `debtAfterClose` to `debtCapMultiplier × target`.
- Call the day-close from the app entry on launch and on `scenePhase` becoming `.active`,
  then refresh the visible tab's ViewModel (reuse `AppRootView`'s reload path).
- First launch ever: set `lastSettledDate = startOfDay(today)` → nothing to settle.
- Optional: "Capped at 2 days" caption on the Debt hero when any exercise is at the ceiling.

## Acceptance Criteria
- [ ] Missing a past day's target persists per-exercise debt equal to the missed reps.
- [ ] Logging surplus on a later in-window day reduces earlier debt (chronological repay).
- [ ] N days fully missed never produces more than `2 × target` debt per exercise (cap holds).
- [ ] Today is never settled; only completed past days are.
- [ ] Day-close runs on launch and on foreground; the Dashboard/Debt/Rounds reflect the
      new debt without a manual reload.
- [ ] First launch creates no debt.
- [ ] App builds; full test suite green.

## Test Cases
- [ ] Swift Testing: single missed day → correct per-exercise debt.
- [ ] Multi-day absence (e.g. 5 days) → debt clamped at the 2-day ceiling per exercise.
- [ ] Surplus day inside the window repays prior debt; chronological order respected.
- [ ] `lastSettledDate` advances to today's start and is idempotent (re-running settles nothing).
- [ ] **Migration test:** open an old-schema store (no `lastSettledDate`/`debtCapMultiplier`)
      WITH data, migrate, assert records survive and new fields default cleanly.
- [ ] Visual: launch a state with a settled past-day deficit → Debt tab + Dashboard show the
      accrued (and capped) debt.

## Files Expected
- `apps/getting-money/GettingMoney/Models/AppSettings.swift` (+ `Models/SchemaV1.swift`/migration if versioned)
- `apps/getting-money/GettingMoney/Services/DayCloseService.swift` (new)
- `apps/getting-money/GettingMoney/Repositories/ExerciseRepository.swift` (cap in `applyDebtSettlements`)
- `apps/getting-money/GettingMoney/GettingMoneyApp.swift` + `Views/AppRootView.swift` (launch/foreground trigger)
- `apps/getting-money/GettingMoneyTests/DayCloseTests.swift` (new) + migration test
- (optional) `apps/getting-money/GettingMoney/Views/Debt/DebtView.swift` (cap caption)

## Dependencies
Packet 08 complete. Builds on `DebtEngine` (P05), payback (P07), and the two QA display
fixes (Bug 1 Log status pill, Bug 2 dashboard empty-state-hides-debt) already on disk.

## Out of Scope
Background/midnight settlement (BGTask) · rest days · a "losses" ledger · cloud sync ·
production App Store submission.

## Retry Count
0
