# Vision — Getting Money

> Source spec: `docs/spec.md` (your full explanation). This is the agent-facing summary the Planner decomposes.

## One-paragraph summary
Getting Money is a premium native-iOS calisthenics tracker built on one psychological hook: **every rep earns money, every missed daily rep becomes debt, and the goal is to keep rep-debt at zero.** It turns simple bodyweight training (push-ups, pull-ups, squats; dips optional) into a clean personal "bank" — balance, streak, daily targets, over-target earnings, and a dynamic payback plan you can fold into today's rounds. The money is a metaphor, never real currency.

## Target user
- **Who:** Yassine first (personal daily use), then discipline-driven calisthenics users who want a high-motivation tracker without programs, coaching, or social features.
- **Technical level:** consumer; expects native iOS polish.
- **Primary context:** quick daily logging at home/gym, often one-handed — fast in, fast out.

## Core problem (one sentence)
Simple bodyweight workouts get skipped because the feedback loop is too weak — Getting Money makes every rep financially meaningful and every missed rep a visible debt to pay back.

## Core loop (the 10-second "what they do")
Open app → see today's targets + bank/debt status → start rounds (targets auto-split) → log reps → completed reps add money, missed reps become debt, extra reps pay debt then bank → dashboard updates → "I just need to pay today's reps."

## v1 must-have features (MoSCoW — Must)
1. Daily rep targets per exercise (push-ups, pull-ups, squats; optional dips) with manual edit + auto-progression every 2 weeks (pull-ups capped at 10 by default).
2. Rep logging → earnings ($1/rep), missed → per-exercise rep debt, extra → debt-first then bonus (priority rule).
3. Bank dashboard: balance, total earned, total lost, current rep debt, streak, today's progress, status (green/yellow/red).
4. Rounds/circles: choose N rounds, auto-split targets (even/uneven remainder rule), editable rounds, optional debt payoff folded in.
5. Dynamic debt payback plan: pay-in-one-go or finance plan over D days, exercise-aware, recalculates on changes.
6. Local-first persistence of all days/logs/totals/debt/targets/streak.

## Explicitly out of scope for v1
Auth/accounts, iCloud/cloud sync, social/leaderboards, real money, AI coaching, camera rep-counting, Apple Watch, HealthKit, widgets/Live Activities, Android/web. (All are "nice-to-have later.")

## Platform & integration
- iOS native (SwiftUI). Min iOS: 17. System integration: none in v1.

## Auth & data
- Auth: **none.**
- Persistence: **SwiftData, local-only** (no CloudKit in v1).

## Distribution constraint (HARD if shipped)
- Not yet shipped — fresh build. Goal: **TestFlight beta.** (Once on TestFlight with real data, schema changes require migration tests.)

## Game module
- **Gamified: yes** — the money/debt economy IS the core loop. Apply the game-design delight principles (calibrated friction, juice/feedback, the loop is the product) from `knowledge/game-design.md`. Stack stays the normal SwiftUI stack; no game engine.

## The concept that makes it not generic
A **personal bodyweight bank with rep-debt that can only be repaid in reps** — bank balance and debt are deliberately separate systems, so money can't buy your way out of missed work. Calm, premium, "serious bank for your training," never a childish game.
