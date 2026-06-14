# Full UI / System QA — Getting Money (2026-06-14)

Phase: TESTER. Driven on iPhone 17 Pro (Sim), Xcode 26.5. Method: seeded launch-arg
states + `simctl` screenshots, with **compute-then-compare** (hand-computed each number
from the engine formula, then asserted the on-screen value matches). repValue = 1.

## Verdict: NOT shippable as "all features work" — 1 systemic gap needs a product decision.

- 2 display bugs found and **fixed + verified** (Bug 1, Bug 2).
- 1 core-feature gap found — **debt never accrues in production** (Gap 3). Surfaced as a
  gate; not fixed inline because *when a day closes* is an unspecified design decision.
- Unit suite: **68/68 green** (was 67; +1 new test, +1 new assertion).

---

## Bug 1 — Log status pill was hardcoded (FIXED, verified)
`LogView.swift:40` rendered `GMStatusPill(status: .onTrack)` — a static pill that always
said "On track" regardless of state. It contradicted the Dashboard ("Behind") for the
same 220/260 day.
- Fix: added a computed `status` to `RepLoggerViewModel` using the Dashboard's exact
  three-way rule (debt → behind → profit), incl. pending drafts; bound the pill to it.
- Test: `RepLoggingTests."Log status pill reflects real state and matches the dashboard"`.
- Visual: `qa/hist-log-fixed.png` → **Behind**; `qa/debt-log-fixed.png` → **Active debt**.

## Bug 2 — Dashboard hid debt behind a false empty state (FIXED, verified)
`DashboardView` gated the whole screen on `hasActivity = !snapshots.isEmpty` (rep entries
only). With debt but no logged reps, it showed the first-launch empty state reading
*"No reps logged yet, and nothing owed"* — while debt was actually owed.
- Fix: `hasActivity = !snapshots.isEmpty || totalDebt > 0` (the empty copy asserts both
  claims, so debt must count as activity).
- Test: assertion added to `DebtViewModelTests."Stored debt drives ... status"`.
- Visual: `qa/debt-dashboard-fixed.png` → populated dashboard with **Active debt** pill.
- Coupling: only user-reachable once debt can accrue (Gap 3); it's part of making the
  debt system correct end-to-end, not an independently-shipping fix.

## Gap 3 — Debt never accrues in the shipped app (NEEDS DECISION → gate)
Spec calls rep-debt *"the most important gamified feature"*: missed daily targets become
debt. The engine (`DebtEngine`) and the Debt/Payback/Rounds-payoff UI exist and are
unit-tested — but **nothing in production ever persists debt**:
- `applyDebtSettlements` / `setDebt` are called only from a test and the DEBUG fixture.
- No day-rollover / day-close exists. `GettingMoneyApp` has no scenePhase hook;
  `AppRootView.onChange` is tab-only; the Dashboard computes today's settlement live but
  never persists `debtAfterClose`.
- Result: persisted debt is seeded at 0 and stays 0 forever. Debt looks correct in
  screenshots only because the fixture injects it.

Precedent: `TargetProgressionEngine` already does an on-launch, elapsed-days catch-up
(advancing `lastProgressionDate`). Debt settlement is the **missing twin** of that pattern.

Proposed packet (for approval):
1. Add `lastSettledDate` to `AppSettings` (additive; quick migration test).
2. On launch, settle each *completed* calendar day between `lastSettledDate` and today
   (today stays live), chronologically, feeding that day's logged reps + target into
   `DebtEngine.settleDay` and persisting via `applyDebtSettlements`.
3. Tests: day-close unit tests + migration test.
4. **Decision only Yassine can make:** multi-day absence — does N days away create up to
   N days of debt (most faithful to spec), or cap/collapse it?

(App is not yet on TestFlight, so no real-user data to protect — the gate reason is the
design decision, not data safety.)

---

## Coverage (every tab, both empty + populated)
| Screen | States checked | Numbers verified |
|---|---|---|
| Dashboard | empty, populated (history), debt | balance $2,078, +$220 today, 10-day streak, 220/260, +$1,978 chart, status |
| Log | empty, history, debt | +$220, 220/260, per-exercise 100/100·0/10·120/150, status pill |
| Rounds | clean, history, debt-payoff | split 34/4/50 (260), payoff 42/5/54 (296) — target+payoff split independently then summed |
| Debt | no-debt, seeded | $36 owed, breakdown 24/2/10, 3-day plan sums exactly |
| Settings | clean | targets 100/10/150, dips off, auto +5/14d |

## Static-screenshot limits (not failures — stated for honesty)
- Charts: only **Balance** mode rendered; Daily/Streak need a segmented-control tap.
- Settings: **Export** (ShareLink) and **Reset** (confirmation dialog) need taps; Reset
  is unit-covered (reset → first-launch empty state).
- Button navigation (CTA wiring) is read in `AppRootView` (trivial closures) +
  covered by `CrossScreenRefreshTests`; not exercised by static shots.

Artifacts: `reports/artifacts/qa/*.png`. No commit made — awaiting direction on Gap 3.
