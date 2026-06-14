# Packet 09 Report: Debt Day-Close Engine

## Status: PASSED — 75/75 tests green; verified end-to-end in Simulator; archives clean.

## Why this packet existed
The full UI/system QA pass (`reports/qa-full-ui-test.md`, Gap 3) found that rep-debt — the
spec's *"most important gamified feature"* — **never accrued in production**. The `DebtEngine`
and all debt/payback/rounds-payoff UI existed and were unit-tested, but nothing ever closed a
day to turn missed targets into persisted debt (`applyDebtSettlements` had no production
caller). Debt only appeared via the DEBUG fixture. This packet wires the missing trigger — the
twin of `TargetProgressionEngine`'s on-launch elapsed-days catch-up.

## What was built
- **`DayCloseService`** (pure, `@MainActor`): settles every completed day from the
  `lastSettledDate` watermark up to — but not including — today, chronologically, so a strong
  day's surplus repays earlier debt. Bounded lookback (60 days) since the cap is reached within
  a couple of fully-missed days. Returns the number of days settled.
- **2-Day Debt Ceiling:** each exercise's debt is clamped to `debtCapMultiplier × that day's
  target` (default 2). Approved with Yassine to keep a long absence recoverable, not a wall —
  serves the spec's "does not shame the user" while keeping real stakes.
- **`AppSettings`:** added `lastSettledDate: Date?` watermark and `debtCapMultiplier: Int = 2`
  (additive; defaults clean).
- **`ExerciseRepository`:** `applyDebtSettlements` gained an optional `capMultiplier` (applied
  only when the day had a target, so a zero-target day never wipes owed debt); new
  `markDayClosed(through:)` watermark setter.
- **Triggers:** `GettingMoneyApp.init` (cold launch) and `AppRootView` on
  `scenePhase → .active` (foreground), the latter followed by a full VM refresh so debt/status
  are consistent on whatever tab is visible.
- **`-GMSeedMissedDaysFixture`** (DEBUG): backdates targets + a 5-day gap so the launch
  day-close accrues capped debt for visual verification.

## Design decisions (approved by Yassine)
- Trigger on **launch + foreground** (no background task).
- Multi-day absence → **2-day cap per exercise**.
- Chronological settlement; **today stays live**; **bank balance untouched** (bank vs debt
  stay separate); **no rest-day concept** (the cap is the fairness mechanism).

## Test results
- `xcodebuild test` on iPhone 17 Pro: **PASS — 75 tests** (+7 day-close: single missed day,
  multi-day cap, chronological surplus repay, today-stays-live, first-launch-no-debt,
  idempotency, on-disk field survival).
- **Data safety:** `newFieldsSurviveReopen` writes data + the new fields to an on-disk store,
  reopens, and asserts records survive and the additive fields default cleanly. (App is not yet
  on TestFlight → no live users; the new fields are additive regardless.)
- **Visual (Simulator):** `-GMSeedMissedDaysFixture` → Debt tab shows **$520** = 200 push +
  20 pull + 300 squat (5 missed days clamped to 2× each target); payback plan sums to 520 over
  3 days; Dashboard shows **Active debt**. Artifacts: `reports/artifacts/qa/p09-*.png`.
- **Regression:** clean dashboard still the first-launch empty state; history dashboard still
  $2,078 / +$220 / 10-day streak / Behind — day-close correctly no-ops when there is no gap.
- **Archive:** `xcodebuild archive ... CODE_SIGNING_ALLOWED=NO` → **ARCHIVE SUCCEEDED**.

## Acceptance criteria
- [x] Missing a past day's target persists per-exercise debt equal to the missed reps.
- [x] Surplus on a later in-window day reduces earlier debt (chronological repay).
- [x] N fully-missed days never exceed 2× target per exercise (cap holds).
- [x] Today is never settled; only completed past days are.
- [x] Day-close runs on launch and on foreground; views reflect new debt without manual reload.
- [x] First launch creates no debt.
- [x] App builds; full suite green; archives for TestFlight.

## Bundled in this branch
- `fix(packet-08)`: the two QA display bugs (Log status pill hardcoded; dashboard hid debt).
- `chore`: `resume-app` and `ui-test` orchestration skills.

## Trade-offs / notes
- Optional "Capped at 2 days" caption on the Debt hero was left out to avoid unreviewed UI;
  the payback planner already frames the debt as actionable (e.g. 174 reps/day). Easy polish later.
- No background/midnight settlement (out of scope); debt simply appears next time the app opens.

## TestFlight
Unchanged from Packet 08: the app archives unsigned. Signing + upload require an Apple
Developer Team ID and remain Yassine's step (full steps in `reports/packet-08-report.md`).
