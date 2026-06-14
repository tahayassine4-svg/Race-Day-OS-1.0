# Packet 07 Report: Dynamic Debt Payback Planner

## Status: PASSED

## What Was Built
- Added a pure, exercise-aware `PaybackPlanner` service:
  - `oneGoPlan(debts:)` — clear the whole debt today, per exercise.
  - `financePlan(debts:over:)` — spread each exercise's debt across D days, remainder to the earliest days (same convention as `RoundPlanner`).
  - `payoffAllocations(level:debts:)` — None / Small (~25%) / Half (~50%) / Full / Custom(total), capped per exercise.
- Refactored `DebtViewModel` to drive the plan from `PaybackPlanner`, with an interactive **Pay-in-one-go ⇄ Finance plan** mode and a **spread-over 2/3/4/5 days** selector; each plan day shows per-exercise reps and a day subtotal.
- Made the Debt screen's plan toggle and day selector live; the "Add payoff to today's rounds" CTA now navigates to Rounds and folds in the full owed amount.
- Extended `RoundsViewModel` + `RoundTarget`/`PlannedRound` to fold a chosen debt payoff into the round split, allocating to the matching exercises. Payoff reps are tracked separately so they never inflate the "extra money" bonus preview.
- Replaced the locked Rounds debt preview with a live **None / Small / Half / Full** payoff selector; round cards show a `+ payoff` tag and per-exercise `+N owed` portions.
- Added cross-screen refresh in `AppRootView` (`.onChange(of: selection)`) so Debt/Rounds/Dashboard reload when their tab becomes active — the plan stays in sync after reps are logged elsewhere.
- Added a DEBUG-only `-GMInitialTab` launch arg for deterministic screenshotting.

## Test Results
- Baseline before implementation: PASS — 36 tests.
- `xcodebuild ... test` on iPhone 17 Pro: PASS — **53 tests** (added 11 planner + 6 view-model tests for Packet 07).
- Coverage: one-go single/mixed debt; finance spread + exercise-aware independence + total conservation across 1–7 days; payoff levels (none/small/half/full/custom + clamp); debt VM mode switch + repayment-reduces-plan; rounds full-payoff folds to matching exercise, round-count change conserves total, no-debt → payoff None.
- Money-to-debt grep: PASS — no affordance pays debt with money; reassurance copy present ("paid back in reps, not money", "Money can't clear debt — only reps can", "repaid in reps").
- Visual verification on iPhone 17 Pro simulator (debt fixture): PASS — Debt screen at `reports/artifacts/p07-debt.png`, Rounds (default) at `reports/artifacts/p07-rounds.png`, Rounds with Full payoff folded in at `reports/artifacts/p07-rounds-payoff.png`; all match `design/packet-07.png` / `design/packet-07-rounds.png`.
- Post-review fix: the Debt "Add payoff to today's rounds" shortcut now uses `requestPayoff(.full)` so the chosen payoff survives the tab-switch reload (previously a saved plain plan reset it to None). Covered by `requestedPayoffSurvivesReload`.

## Acceptance Criteria
- [x] One-go and finance-plan options appear when debt exists.
- [x] Plans are generated from current per-exercise debt and allocate to matching exercises.
- [x] Changing round count / logging reps recalculates the plan and remaining debt.
- [x] UI never offers paying debt with money.

## Issues Found
None blocking.

## Trade-offs Made
- Saved round plans don't persist the base/payoff split, so on reload payoff reps are inferred from the total over the daily target (heuristic). Fresh planning is exact and fully tested.
- Visual verification captures the default Rounds payoff state (None); the fold-in math is verified by unit tests rather than a tapped screenshot (no UI-automation tooling installed).
