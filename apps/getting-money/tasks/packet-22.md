# Packet 22 — Dynamic Rounds + Guided Exercise Sessions

UI? Yes (Rounds tab becomes a guided session tracker). Backend? Yes (dynamic
round computation in a new pure engine; RoundsViewModel rework).

## Goal
Rounds stop being a manually-chosen split. The app *computes* how many rounds are
left from (a) the chosen depth (reps per round), (b) the daily target, and
(c) the reps already done today — updating live as individual reps get logged.
The user picks which exercise(s) to train (maybe only push-ups, only pull-ups,
or the full circuit) and the app walks them through the rounds with an animated,
alive session flow.

## Dynamic round model (pure, testable)
For each selected exercise:
- `remaining = max(0, currentTarget + debtPayoffFolded − completedToday)`
- `roundsLeft = ceil(remaining / depth)` — the last round may be short; being one
  round above the theoretical minimum is acceptable, never more.
- Recomputed on every load and after every log, so +10 quick reps on the
  dashboard immediately shrink the session. Depth options per exercise scale off
  the target (e.g. target/10 … target/4, sensible presets like 10/15/20/25 for
  push-ups, 2/3/5 for pull-ups).
- Circuit mode ("All exercises") interleaves the per-exercise rounds like today's
  planner, but with counts derived from the same remaining-based math.
- Completed rounds keep logging tagged rep entries exactly as today
  (`sourceRoundNumber`), so reconciliation/earnings/debt engines are untouched.

## Session flow (the animated part)
1. **Setup** — exercise chips (Push-ups / Pull-ups / Squats / … / Full circuit),
   depth selector, live "N rounds left · M reps to go" summary that re-counts as
   settings change; big lime **Start session** CTA.
2. **Active round** — full-screen focus card: huge rep count for this round,
   exercise glyph pulsing at a workout cadence, round i/N progress ring, money
   earned so far ticking up; **Done** logs the round (haptic + coin burst +
   count-up), auto-advances with a spring card transition; optional skip/edit.
3. **Between rounds** — brief rest card with a breathing ring, next-round
   preview, tap to continue early.
4. **Finish** — session summary (reps, $ earned, debt paid, bonus), confetti-level
   moment (single, motivated), returns to Rounds overview which now shows
   0 rounds left / completed state.
- Every animation motivated (feedback/continuity), spring-based, Reduce Motion
  fallbacks (cross-fades, no pulse).

## Scope guards
- No schema change: reuse `RepEntry.sourceRoundNumber` + `RoundPlan` persistence.
  If the saved-plan shape can't express "per-exercise session", persist the day's
  session as round plans exactly as today (data-safe on TestFlight).
- DebtEngine / EarningsEngine / reconciliation untouched.

## Acceptance criteria
- [ ] With target 100 push-ups, depth 20, 0 done → 5 rounds. Log 10 loose reps →
      session shows 5 rounds (90 left, ceil = 5) → log 30 → 4 rounds. Never more
      than one round above `ceil(remaining/depth)`.
- [ ] Raising/lowering the daily target or logging reps anywhere (dashboard
      quick-log, widget-day, rounds) recounts rounds on next appearance without
      user action.
- [ ] Single-exercise session logs only that exercise; circuit session covers all
      enabled exercises.
- [ ] Completing all rounds fills the exercise's daily target within +depth reps
      (one short last round allowed, no overshoot beyond it) and pays folded debt.
- [ ] Session flow animates (entrance, round transition, count-ups, completion)
      and is fully usable with Reduce Motion.
- [ ] New pure engine has Swift Testing coverage incl. boundary table
      (remaining 0, remainder rounds, depth > remaining, debt folded).
- [ ] Existing reconciliation/earnings tests stay green.
