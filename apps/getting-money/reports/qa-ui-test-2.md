# Full UI / System QA #2 — Getting Money (2026-06-14)

Phase: TESTER. iPhone 17 Pro (Sim), Xcode 26.5. Method: seeded launch-arg states +
`simctl` screenshots, compute-then-compare. repValue = 1. Triggered by Yassine's Rounds +
Settings bug report.

## Verdict: SHIPPABLE. All reported issues fixed; full suite green; archives clean.

- 4 reported issues fixed (Rounds rework, dips toggle, pull-up cap, dead "Start round").
- Unit suite: **88/88 green** (was 80; +8 rounds-completion).
- No gaps requiring a decision. No regressions.

---

## Reported issues → fixes (all verified)

### 1. Rounds: counter not working, not tracked on dashboard, can't edit, "Start round" did nothing
Root cause: Rounds was a pure planner — "Start round" silently called `save()`; nothing
logged reps, `completedReps` was unused. **Reworked into an actionable workout (Packet 11):**
- **Tick off rounds → balance.** Each round has a "Mark done" button; completing it logs that
  round's reps as `RepEntry`s tagged with the round number → flows into balance, earnings,
  streak, live debt, and the dashboard. Completion is *derived from the tags*, so it survives
  reloads and `replaceRoundPlans`.
- **Tracked on dashboard:** completing round 1 (34+4+50) → Dashboard balance **$88**, daily
  target **88/260**, Push-ups **34/100**, streak 1. (`qa/p11-dashboard-rounds.png`)
- **Editable:** open rounds have +/− steppers; a completed round shows a clear green **Edit**
  button that un-ticks it (removing exactly its reps) to re-open for editing. (`qa/p11-rounds-done.png`)
- **"Start round" now works:** repurposed to "Complete round N" (ticks the next incomplete
  round); header shows "k / N done" and "+$X added from completed rounds".

### 2. New workflow: up to 10 rounds, tick off, edit after
- Round count is now a **1–10 stepper** (was a fixed 2–5). (`qa/p11-rounds-fresh.png`)
- Count **locks once a round is ticked** (changing it would orphan logged reps) — shown as
  "locked — undo a round to change".
- Completing a payoff round pays debt down (verified: 100 target + 30 payoff push-ups → 30
  surplus clears 30 debt).

### 3. Dips couldn't be turned off (`TargetSettingsList.swift`)
The optional-exercise toggle only rendered when *disabled*, so once dips was ON the toggle
vanished (replaced by the stepper). **Fix:** optional rows always keep a toggle; the stepper
shows alongside when enabled. Verified ON state shows stepper **+** toggle. (`qa/p11-settings-dips-on.png`)

### 4. Pull-up cap removed (didn't do anything useful)
Removed from Settings UI and `TargetProgressionEngine` — pull-ups now auto-progress like every
other exercise. `AppSettings.pullupCap` field kept (unused) to avoid migration churn.
(`qa/p11-settings.png`)

---

## Coverage (compute-then-compare)
| Screen | States | Verified |
|---|---|---|
| Rounds | fresh, 1-done, payoff | 1–10 stepper; round 1 = 34/4/50; "1/3 done" +$88; locked count; Edit affordance; payoff fold |
| Dashboard | empty, from-rounds, history, debt | $88 from round 1 (88/260); $2,078 / +$220 / 10-day streak (history); Active debt |
| Log | clean, history | Behind @ 0/260; +$220 @ 220/260 with live status |
| Debt | seeded, live-payback, capped | $36 breakdown; $20 after 30 paid live; $520 capped (day-close) |
| Settings | clean, dips-on | no pull-up cap; dips toggle on+off; targets 100/10/150 |

## Static-screenshot limits (stated for honesty)
- Round ticking, dips toggling, charts (Daily/Streak), export/reset dialogs are tap-driven;
  screenshots show seeded states, not the taps. All are covered by unit/integration tests
  (RoundsCompletionTests, LivePaybackTests, DayCloseTests, settings VM tests) + code read.
- Round completion is proven by 8 RoundsCompletionTests (tick→balance, untick, reload-survival,
  cap to 10, count-lock, edit-after-undo, payoff→debt, field persistence).

Archive: `xcodebuild archive CODE_SIGNING_ALLOWED=NO` → ARCHIVE SUCCEEDED (TestFlight-ready;
signing is Yassine's). Artifacts: `reports/artifacts/qa/p11-*.png`, `final-*.png`.
