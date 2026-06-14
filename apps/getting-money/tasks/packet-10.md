# Packet 10: Live Debt Payback (immediate feedback on the core loop)

## Goal
Make today's surplus reps pay debt down **immediately** on screen, instead of only at the
next day-close. Closes the asymmetry found after Packet 09: debt *accrual* is correctly
deferred to day-close (you can't un-miss a past day), but debt *repayment* was also deferred —
so logging payback reps today didn't move the displayed debt until the next launch. That
breaks the spec's core loop ("extra reps pay debt then bonus → dashboard updates → 'I just
need to pay today's reps.'"). Fully compatible with "today stays live": today's *misses* still
don't count as debt until day-close.

## UI?
**Backend/VM-only → no Design Gate.** No new screens; the existing Dashboard, Debt, and Rounds
surfaces simply bind to a live (reduced) debt number.

## What was built
- **`DebtEngineProtocol.liveDebt(...)`**: debt remaining for an exercise after today's surplus
  repayment only (`persisted − today's repaid`); today's misses are excluded (deferred to
  day-close). Single source of truth used by all three view models.
- **DashboardViewModel**: per-exercise `debtOwed` and `totalDebt`/status now reflect live
  repayment.
- **DebtViewModel**: now takes `workoutRepository`; the debt number, breakdown rows, payback
  plan, and status all use live debt — clears to **"Paid off"** when today's reps zero it out.
- **RoundsViewModel**: payoff folds only the debt that remains after today's reps.
- Persisted debt is **untouched** during the day; day-close still reconciles it (no double
  count: when no misses, day-close lands on exactly the live value).
- DEBUG `-GMSeedPaybackFixture` for visual verification.

## Acceptance Criteria
- [x] Logging reps above target today immediately reduces shown debt (Dashboard + Debt).
- [x] Clearing all debt today flips the Debt screen to "Paid off".
- [x] Being under target today does NOT raise debt live (today stays live).
- [x] Rounds payoff folds only the remaining (post-today) debt.
- [x] Persisted debt is unchanged until day-close (no double counting).
- [x] App builds; full suite green; archives for TestFlight.

## Test Cases
- [x] Dashboard live payback → totalDebt 0, status not activeDebt.
- [x] Debt screen shrinks (50 → 20 after 30 payback reps).
- [x] Clearing debt → Paid off, no rows.
- [x] Under target → debt unchanged (no live accrual).
- [x] Persisted debt unchanged after live payback.
- [x] Visual: `-GMSeedPaybackFixture` → Debt reads $20 (`reports/artifacts/qa/p10-debt-livepayback.png`).

## Files
- `GettingMoney/Services/DebtEngine.swift` (liveDebt) · `Services/LocalStore.swift` (fixture)
- `GettingMoney/ViewModels/{Dashboard,Debt,Rounds}ViewModel.swift`
- `GettingMoney/Views/AppRootView.swift` (DebtViewModel wiring)
- `GettingMoneyTests/LivePaybackTests.swift` (+ constructor updates in 3 test files)

## Dependencies
Packet 09 (day-close) complete.

## Out of Scope
Background settlement · animated count-down on the debt number (possible juice polish later).

## Retry Count
0
