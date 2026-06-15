# App Vision — Getting Money App

## App Name

**Getting Money App**

## Summary

Getting Money App is a premium iOS calisthenics tracker built around a simple psychological hook: every rep earns money, every missed daily rep becomes debt, and the user’s goal is to keep the debt balance at zero. The app focuses on push-ups, pull-ups, and squats as the core exercises, with dips as an optional extra. It turns daily bodyweight training into a clean financial dashboard: bank balance, streak, daily target, over-target earnings, rep debt, and a dynamic payback plan that can be worked into today’s rounds or attacked in one session.

## Target Users

- **Primary:** Yassine, using the app personally to stay consistent with simple daily calisthenics.
- **Secondary:** Discipline-driven calisthenics users who want a premium, high-motivation tracker without complex workout programming, coaching content, or social features.

## Core Problem

People skip simple bodyweight workouts because the feedback loop is too weak; Getting Money App makes every rep feel financially meaningful and makes missed reps visible as debt that must be paid back.

## Core Features (v1)

1. **Daily rep targets**
   - Core exercises: push-ups, pull-ups, and squats.
   - Optional exercise: dips.
   - Each exercise has its own daily target.
   - Targets increase automatically every two weeks by a configurable amount.
   - Pull-up targets are capped at 10 reps unless the user manually changes them.
   - The user can manually adjust any target at any time.

2. **Rep logging and earning**
   - The user logs reps per exercise.
   - Every logged rep earns money.
   - Reps above the daily target count as extra money.
   - Money is a motivational score only; it cannot erase debt.

3. **Debt system**
   - At day end, missed reps become rep debt.
   - Debt is tracked per exercise and as a total debt balance.
   - The app clearly shows whether the user is under target, on target, over target, or carrying debt.
   - Rep debt can only be reduced by doing reps, not by spending earned money.

4. **Bank dashboard**
   - Premium dashboard visualization inspired by a bank account.
   - Shows total earned money, today’s earnings, streak, daily target progress, debt balance, and over/under status.
   - The central goal is to get rep debt back to zero.

5. **Rounds / circles**
   - The user chooses a number of rounds for the day.
   - The app automatically splits daily exercise targets across rounds.
   - Round calculations account for uneven splits.
   - The user can edit individual rounds to do more reps and earn more money.
   - Rounds can optionally include a debt payback allocation.

6. **Debt payback plan**
   - The app can generate a finance-plan-style repayment schedule based on current debt, daily targets, and selected rounds.
   - The user can choose to pay debt back in one go or spread it across future sessions.
   - Payback plans are dynamic: when reps are logged, targets change, or rounds change, the plan recalculates.
   - Debt repayment is exercise-aware where possible, so missed pull-ups are paid back with pull-ups, missed squats with squats, and so on.

7. **Local-first history**
   - All workout days, rep logs, money totals, debt balances, target changes, and streak data are stored locally on device.
   - No account, no cloud sync, and no backend in v1.

## Out of Scope (v1)

- Authentication or accounts.
- Cloud sync across devices.
- Social sharing, leaderboards, or friend challenges.
- Payment processing or real money.
- AI coaching.
- Camera-based rep counting.
- Apple Watch support.
- HealthKit integration.
- Android or web app.

## Success Criteria

- [ ] The user can open the app and understand today’s financial workout status within 5 seconds.
- [ ] The user can log reps for push-ups, pull-ups, squats, and optional dips in under 10 seconds.
- [ ] The app correctly converts missed daily reps into debt.
- [ ] The app correctly treats over-target reps as extra money without reducing debt.
- [ ] The app can split targets across any reasonable number of rounds.
- [ ] The app can generate and update a debt payback plan based on current debt and selected rounds.
- [ ] The app persists all data locally after app restart.
- [ ] The app is ready for TestFlight beta distribution.

## Key Constraints

- Native iOS app.
- TestFlight distribution.
- No authentication.
- Local data only.
- Premium design standard: polished, app-native, fast, and desirable beyond personal use.
- v1 must include the full money/debt/rounds loop because that is the product foundation.

## Resolved Decisions

- **Platform:** iOS native app.
- **Distribution:** TestFlight beta.
- **Persistence:** Local-only device storage.
- **Auth:** None.
- **Core exercise model:** Push-ups, pull-ups, squats as primary; dips optional.
- **Money model:** Money is earned by reps but cannot pay debt.
- **Debt model:** Missed reps become debt and must be repaid through future reps.
