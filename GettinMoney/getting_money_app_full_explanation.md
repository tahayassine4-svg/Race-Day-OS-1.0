# Getting Money App — Full App Explanation

## 1. App Summary

**Getting Money App** is a simple calisthenics tracking app that turns daily bodyweight training into a finance-inspired game.

The app is **not actually about making real money**. The money system is a metaphor. Every repetition becomes “money earned,” while missed daily targets become “rep debt.” The goal is to make basic calisthenics feel more rewarding, measurable, and addictive without making the workout app too complex.

The app focuses on simple exercises:

- Push-ups
- Pull-ups
- Squats
- Optional: Dips

The core idea is:

> Every rep earns. Missed targets become debt. Extra reps build your bank.

The user trains through daily repetition targets, rounds/circles, and a debt payoff system that helps them stay consistent without feeling like they failed permanently.

---

## 2. Core Concept

Most workout apps track sets, reps, weight, rest time, and programs. This app does something simpler:

It tracks **daily repetitions**.

Instead of asking the user to follow a complicated workout plan, the app gives them a daily target for each exercise. The user can complete those reps however they want during the day.

For example:

| Exercise | Daily Target |
|---|---:|
| Push-ups | 100 |
| Pull-ups | 10 |
| Squats | 150 |

When the user completes reps, they earn money inside the app.

When the user misses reps, the missing reps become debt.

If the user does extra reps above the daily target, those extra reps create additional earnings.

The app creates a simple mental model:

- Completed reps = money earned
- Missed reps = debt created
- Extra reps = bonus money
- Debt must be paid back with future extra reps
- Bank balance and rep debt are separate

This separation is important because the user cannot simply use earned money to erase debt. The debt has to be paid back with physical reps.

---

## 3. Main User Goal

The user’s main goal is to reach and maintain:

> **Zero rep debt**

The app should make the user feel like they are managing a personal calisthenics bank.

When debt appears, the app does not shame the user. It gives them a clear plan to get back to zero.

The app should feel like:

- A workout tracker
- A bank dashboard
- A simple game
- A debt payoff system
- A consistency coach

---

## 4. The Core Loop

The daily loop is very simple.

1. The user opens the app.
2. The app shows today’s daily rep targets.
3. The app shows whether the user is on track, under target, or over target.
4. The user chooses how many rounds/circles they want to do.
5. The app automatically splits the daily reps into those rounds.
6. The user completes reps.
7. The app adds money for completed reps.
8. If the user misses the daily target, the missing reps become debt.
9. If the user does extra reps, they earn bonus money.
10. The dashboard updates the user’s bank, debt, streak, earnings, and losses.

The app should feel satisfying after every rep is logged.

---

## 5. Money System

The app uses fake in-app money as a reward system.

A simple starting rule:

```text
1 completed rep = $1 earned
```

This can be adjusted later, but the MVP should keep it simple.

Example:

```text
50 push-ups = $50 earned
10 pull-ups = $10 earned
100 squats = $100 earned
```

The money exists only as a progress visualization. It is not real currency.

### Total Earned

Total earned is the sum of all completed reps converted into money.

```text
Total Earned = all completed reps × rep value
```

### Daily Earnings

Daily earnings are the money earned from today’s logged reps.

```text
Daily Earnings = today’s completed reps × rep value
```

### Bonus Earnings

Bonus earnings come from reps completed above the daily target.

```text
Bonus Reps = completed reps - daily target
Bonus Earnings = bonus reps × rep value
```

If the user does not exceed the target, bonus earnings are zero.

---

## 6. Loss System

Losses are created when the user misses their daily rep target.

Example:

```text
Daily push-up target: 100
Completed push-ups: 70
Missing push-ups: 30
Loss: $30
Debt created: 30 push-up reps
```

Losses are shown as negative values on the dashboard.

```text
Losses = missed reps × rep value
```

Losses should appear visually in red.

Losses do not remove money from the bank in a way that clears debt. Instead, they represent the cost of missed consistency.

---

## 7. Bank Balance

The bank balance shows how much the user has earned overall after subtracting losses.

```text
Bank Balance = Total Earnings - Total Losses
```

Example:

```text
Total Earned: $2,456
Total Lost: -$1,172
Bank Balance: $1,284
```

The bank balance is a motivational number. It shows the user’s accumulated training value.

Important rule:

> Bank balance does not pay off rep debt.

This keeps the system physical. The user has to pay back missed reps by doing reps.

---

## 8. Rep Debt System

Rep debt is the most important gamified feature.

Rep debt is created when the user misses daily targets.

Example:

| Exercise | Target | Completed | Debt Created |
|---|---:|---:|---:|
| Push-ups | 100 | 76 | 24 |
| Pull-ups | 10 | 8 | 2 |
| Squats | 150 | 140 | 10 |

Total rep debt:

```text
24 push-ups
2 pull-ups
10 squats
```

The dashboard may show this as:

```text
Current Rep Debt: $36
```

But the app should also show the real exercise breakdown:

```text
Push-ups: 24 reps owed
Pull-ups: 2 reps owed
Squats: 10 reps owed
```

This matters because a push-up debt should be paid with push-ups, a squat debt with squats, and a pull-up debt with pull-ups.

### Debt Rules

- Debt is created from missed daily targets.
- Debt is tracked per exercise.
- Debt can only be reduced by extra reps.
- Completed reps first count toward today’s daily target.
- Reps above today’s target can pay debt.
- Money earned cannot erase debt directly.
- Debt reaches zero only when owed reps are physically completed.

---

## 9. Debt Payoff System

The debt payoff system helps the user return to zero debt.

The user should be able to choose between:

1. **Pay off in one go**
2. **Finance plan**

### 9.1 Pay Off in One Go

The app shows how many extra reps are needed to clear debt immediately.

Example:

```text
To clear your debt today:
+24 push-ups
+2 pull-ups
+10 squats
```

The user can add this debt payoff to today’s workout rounds.

### 9.2 Finance Plan

The finance plan spreads the debt across multiple days.

Example:

```text
Current Debt:
Push-ups: 24
Pull-ups: 2
Squats: 10

Payoff Plan:
3 days
```

The app calculates:

```text
Day 1: +8 push-ups, +1 pull-up, +4 squats
Day 2: +8 push-ups, +1 pull-up, +3 squats
Day 3: +8 push-ups, +0 pull-ups, +3 squats
```

The finance plan should be dynamic.

If the user completes extra reps early, the plan adjusts.

If the user misses another target, the debt increases and the plan recalculates.

---

## 10. Daily Rep Targets

Each user has personalized daily targets for each exercise.

The default MVP exercises are:

- Push-ups
- Pull-ups
- Squats

Dips can exist as an optional extra exercise.

### Target Progression

Every two weeks, the app suggests increasing the daily targets.

The increase should be:

```text
+5 to +10 reps per exercise every 2 weeks
```

But pull-ups are different.

Pull-ups should not automatically increase beyond 10 reps unless the user manually chooses to increase them.

Example progression:

| Exercise | Starting Target | After 2 Weeks | After 4 Weeks |
|---|---:|---:|---:|
| Push-ups | 50 | 60 | 70 |
| Pull-ups | 5 | 8 | 10 |
| Squats | 80 | 90 | 100 |

Pull-ups stop at 10 by default.

The user should always be able to manually adjust daily targets.

### Manual Target Editing

The user can edit:

- Push-up target
- Pull-up target
- Squat target
- Dip target if enabled
- Progression amount
- Progression frequency
- Whether auto-progression is enabled

The app should never force progression if the user is not ready.

---

## 11. Rounds / Circles System

Rounds, also called circles, are how the app makes the workout easier to execute.

Instead of showing one big target, the app splits the daily target into smaller rounds.

Example daily target:

```text
Push-ups: 120
Pull-ups: 9
Squats: 180
```

User chooses:

```text
3 rounds
```

The app calculates:

```text
Round 1:
40 push-ups
3 pull-ups
60 squats

Round 2:
40 push-ups
3 pull-ups
60 squats

Round 3:
40 push-ups
3 pull-ups
60 squats
```

### Uneven Splits

If the target does not divide evenly, the app distributes the remaining reps across the earliest rounds.

Example:

```text
Pull-ups: 10
Rounds: 3
```

The app calculates:

```text
Round 1: 4 pull-ups
Round 2: 3 pull-ups
Round 3: 3 pull-ups
```

### Round Calculation Formula

For each exercise:

```text
base reps per round = floor(total target / number of rounds)
remaining reps = total target % number of rounds
```

Then:

```text
First remaining rounds get +1 rep
```

Example:

```text
Target: 10
Rounds: 3

Base: 3
Remainder: 1

Round 1: 4
Round 2: 3
Round 3: 3
```

---

## 12. Rounds With Debt Payoff

The rounds system should also include debt payoff if the user chooses.

Example:

```text
Daily target:
Push-ups: 90
Pull-ups: 9
Squats: 150

Debt:
Push-ups: 24
Pull-ups: 2
Squats: 10

Rounds:
3
```

If the user chooses to pay all debt today, the app calculates:

```text
Total push-ups today: 114
Total pull-ups today: 11
Total squats today: 160
```

Then splits those totals into rounds:

```text
Round 1:
38 push-ups
4 pull-ups
54 squats

Round 2:
38 push-ups
4 pull-ups
53 squats

Round 3:
38 push-ups
3 pull-ups
53 squats
```

### Dynamic Debt Payoff in Rounds

The user can choose:

- No debt payoff today
- Small payoff
- Medium payoff
- Full payoff
- Custom payoff

The rounds update automatically.

---

## 13. Editing Individual Rounds

The user should be able to modify individual rounds.

Example:

The app creates:

```text
Round 1:
40 push-ups
3 pull-ups
60 squats
```

The user changes it to:

```text
Round 1:
50 push-ups
3 pull-ups
60 squats
```

That extra 10 push-ups should be treated as extra money earned or debt repayment depending on the user’s current state.

### Priority Rule

When extra reps are logged:

1. First complete today’s daily target.
2. Then pay off debt.
3. Then count as bonus money.

This prevents the user from earning “bonus money” while still owing rep debt.

---

## 14. Dashboard

The dashboard is the emotional center of the app.

It should show the user their current state at a glance.

Main dashboard elements:

- Bank balance
- Total earned
- Total lost
- Current rep debt
- Day streak
- Reps completed today
- Under / over target status
- Earnings vs losses chart
- Quick action to start today’s rounds
- Debt payoff status

The dashboard should feel like a clean personal bank account for training.

### Dashboard Status Examples

If the user is on track:

```text
Good work. Your bank is active.
```

If the user is behind:

```text
You’re behind today. Small payment fixes it.
```

If the user has no debt:

```text
Debt cleared. Stay at zero.
```

If the user is over target:

```text
Profit day. Extra reps added to your bank.
```

---

## 15. Bank / Analytics Screen

The bank screen gives the user a deeper view of their performance.

It should include:

- Net balance
- Total earnings
- Total losses
- Earnings vs losses chart
- Rep flow breakdown
- Today / This week / All time filter
- Debt progress toward zero

Example:

```text
Net Balance: $1,284
Earnings: +$2,456
Losses: -$1,172
Rep Debt: $36
```

The purpose of this screen is to make progress feel visible.

---

## 16. Debt Plan Screen

The debt plan screen shows the user exactly what they owe and how to fix it.

It should include:

- Current rep debt
- Debt breakdown by exercise
- Payoff plan
- Payoff timeline
- Option to add payoff reps to today’s rounds
- History of missed targets
- History of debt payments

Example:

```text
Current Rep Debt:
$36

Breakdown:
Push-ups: 24
Pull-ups: 2
Squats: 10

Plan:
Today: +12 reps
Tomorrow: +12 reps
Day 3: +12 reps
```

This screen should feel calm and practical, not punishing.

---

## 17. Workout / Rounds Screen

The workout screen is where the user actually trains.

It should show:

- Today’s target
- Number of rounds
- Auto-split reps per round
- Start round button
- Complete round button
- Edit round option
- Add extra reps option
- Debt payoff included or not included
- Simple progress state

Example screen:

```text
3 Rounds Today

Round 1:
48 push-ups
4 pull-ups
74 squats

Round 2:
48 push-ups
3 pull-ups
73 squats

Round 3:
48 push-ups
3 pull-ups
73 squats
```

The workout screen should avoid gym-style complexity.

No need for:

- Set timers in MVP
- Rest timers in MVP
- Weight tracking in MVP
- Complicated exercise library in MVP

The focus is reps.

---

## 18. Target Screen

The target screen lets the user control their daily goals.

It should include:

- Push-up daily target
- Pull-up daily target
- Squat daily target
- Optional dip target
- Auto progression toggle
- Progression frequency
- Progression amount
- Pull-up cap setting
- Manual override

Example:

```text
Push-ups: 100 per day
Pull-ups: 10 per day
Squats: 150 per day

Auto increase:
Every 2 weeks

Increase amount:
+5 to +10 reps

Pull-up cap:
10 reps
```

---

## 19. Streak System

The streak should reward consistency.

A streak continues when the user completes the daily target or follows the debt plan.

Possible MVP rule:

```text
Streak continues if the user completes at least 80% of today’s total target.
```

Better long-term rule:

```text
Streak continues if the user either:
1. Completes the daily target, or
2. Completes the scheduled debt payment for the day
```

This makes the app more forgiving and sustainable.

---

## 20. Status System

The app should have simple status states.

### Green

The user is on track or ahead.

```text
On Track
Profit Day
Debt Cleared
```

### Yellow

The user is slightly behind but still recoverable.

```text
Behind Target
Payment Needed
Close to Goal
```

### Red

The user missed targets or debt increased.

```text
Debt Created
Target Missed
Rep Debt Increased
```

This makes the app easy to understand without requiring the user to analyze numbers all the time.

---

## 21. User Workflow

### First-Time Setup

1. User opens app.
2. App explains the concept:
   - Reps earn money.
   - Missed reps create debt.
   - Extra reps pay debt or increase bank.
3. User sets daily targets:
   - Push-ups
   - Pull-ups
   - Squats
   - Optional dips
4. User chooses progression:
   - Auto increase every 2 weeks
   - Manual progression
5. User lands on the dashboard.

### Daily Use

1. User opens dashboard.
2. App shows today’s target and bank state.
3. User taps “Start Rounds.”
4. User selects number of rounds.
5. App splits reps automatically.
6. User completes rounds.
7. App updates reps, earnings, losses, and debt.
8. At the end of the day, app calculates missed reps.
9. Debt is created if needed.
10. Next day, app adjusts the debt plan.

### Debt Payoff Workflow

1. User sees debt on dashboard.
2. User taps “Debt Plan.”
3. App shows exact debt by exercise.
4. User chooses:
   - Pay now
   - Finance plan
   - Custom plan
5. App adds extra reps into future rounds.
6. User completes extra reps.
7. Debt decreases.
8. When debt reaches zero, the app celebrates.

---

## 22. MVP Feature List

The first version should include only the essential features.

### Must-Have

- Daily rep targets
- Push-ups, pull-ups, squats
- Optional dips
- Rep logging
- Fake money earned from reps
- Missed reps become debt
- Debt tracked per exercise
- Bank dashboard
- Earnings and losses
- Rounds/circles auto-split
- Manual round editing
- Debt payoff plan
- Manual target editing
- Auto progression every 2 weeks
- Pull-up cap at 10 by default
- Local data storage
- Simple streak

### Nice-to-Have Later

- iCloud sync
- Widgets
- Apple Health integration
- Live Activities
- Leaderboards
- Achievements
- Levels
- Multipliers
- Weighted reps
- Exercise variants
- Rest timers
- AI coaching
- Social sharing
- Export reports

---

## 23. Suggested App Tabs

The app can use four main tabs:

### 1. Dashboard

Purpose: show the current state.

Includes:

- Bank balance
- Today’s target status
- Earnings
- Losses
- Debt
- Streak
- Reps today

### 2. Rounds

Purpose: execute the workout.

Includes:

- Number of rounds
- Auto-split reps
- Start round
- Complete round
- Edit reps
- Add debt payoff

### 3. Bank

Purpose: analytics and progress.

Includes:

- Net balance
- Total earned
- Total lost
- Charts
- Rep flow
- Time filters

### 4. Debt Plan

Purpose: get back to zero.

Includes:

- Current rep debt
- Debt breakdown
- Payoff plan
- Payoff history
- Add payoff to rounds

---

## 24. Design Direction

The app should feel like a premium iOS finance app mixed with a workout app.

Visual direction:

- Dark mode first
- Black / graphite background
- Lime green for earnings and progress
- Coral red for debt and losses
- Soft glass cards
- Big readable numbers
- Minimal UI
- Few words
- Strong hierarchy
- Rounded iOS-native components
- Calm premium feeling

The app should not feel like a childish game.

It should feel like:

> A serious personal bank for your bodyweight training.

---

## 25. Key UX Principles

### 1. Simplicity First

The user should not have to think too much.

The app should answer:

```text
What do I owe?
What did I earn?
What do I do today?
How do I get back to zero?
```

### 2. No Shame

Debt should not feel like failure.

Debt should feel like:

```text
A number you can fix.
```

### 3. Reps Over Programs

The app is not a complicated workout plan.

It is a repetition economy.

### 4. Make Progress Visible

Every rep should feel like it matters.

### 5. Keep Control With the User

The user can always:

- Change targets
- Change rounds
- Ignore auto progression
- Edit payoff plan
- Do extra reps

---

## 26. Example Day

User’s daily target:

```text
Push-ups: 100
Pull-ups: 10
Squats: 150
```

User chooses:

```text
3 rounds
```

App calculates:

```text
Round 1:
34 push-ups
4 pull-ups
50 squats

Round 2:
33 push-ups
3 pull-ups
50 squats

Round 3:
33 push-ups
3 pull-ups
50 squats
```

User completes:

```text
Push-ups: 110
Pull-ups: 10
Squats: 150
```

Result:

```text
Target completed.
Extra push-ups: 10
Money earned: $270
Bonus money: $10
Debt created: $0
```

---

## 27. Example Debt Day

User’s daily target:

```text
Push-ups: 100
Pull-ups: 10
Squats: 150
```

User completes:

```text
Push-ups: 76
Pull-ups: 8
Squats: 140
```

Debt created:

```text
Push-ups: 24
Pull-ups: 2
Squats: 10
```

Dashboard shows:

```text
Current Rep Debt: $36
```

Debt Plan shows:

```text
Push-ups owed: 24
Pull-ups owed: 2
Squats owed: 10
```

The next day, the user chooses a 3-day finance plan.

The app adds:

```text
+8 push-ups per day
+1 pull-up for 2 days
+3 or +4 squats per day
```

---

## 28. Core Calculation Rules

### Completed Rep Value

```text
money earned = completed reps × value per rep
```

### Missed Rep Loss

```text
loss = missed reps × value per rep
```

### Bank Balance

```text
bank balance = total earnings - total losses
```

### Debt Created

```text
debt reps = daily target reps - completed reps
```

Only if completed reps are below target.

### Extra Reps

```text
extra reps = completed reps - daily target reps
```

Only if completed reps are above target.

### Debt Payment Priority

```text
extra reps first reduce debt
remaining extra reps become bonus earnings
```

---

## 29. Data Model

A basic MVP data model could include:

### User Settings

```text
user_id
rep_value
auto_progression_enabled
progression_interval_days
progression_amount
pullup_cap
```

### Exercise Target

```text
exercise_id
exercise_name
daily_target
is_optional
is_active
```

### Daily Log

```text
date
exercise_id
target_reps
completed_reps
missed_reps
extra_reps
money_earned
loss_created
```

### Debt

```text
exercise_id
reps_owed
created_at
updated_at
status
```

### Round

```text
date
round_number
exercise_id
planned_reps
completed_reps
is_debt_payoff_included
```

### Bank Summary

```text
total_earned
total_lost
net_balance
current_debt_value
streak_count
```

---

## 30. MVP App Personality

The app should speak in short, clear, motivating lines.

Examples:

```text
Good work. Your bank is active.
Every rep counts.
You’re close to zero.
Debt is fixable.
Small payment today.
Profit day.
Target cleared.
Extra reps added to your bank.
```

Avoid:

```text
You failed.
You were lazy.
You broke your streak.
You are behind again.
```

The tone should be:

- Direct
- Calm
- Slightly playful
- Premium
- Not childish
- Not overly motivational

---

## 31. What Makes This App Different

Most fitness apps measure workouts.

This app measures consistency as an economy.

The unique features are:

- Reps become money
- Missed reps become debt
- Debt can be paid back
- Payoff plans are calculated dynamically
- Rounds automatically split daily targets
- Bank and debt are separate systems
- The user always knows what to do next

The emotional hook is strong because the user is not just checking off workouts.

They are managing a personal bodyweight bank.

---

## 32. Final Product Vision

Getting Money App is a simple but addictive calisthenics habit app.

It should help the user become consistent with basic bodyweight training by turning reps into visible value.

The goal is not to create the most advanced fitness app.

The goal is to create the most satisfying simple calisthenics tracker.

The app should make the user think:

> “I just need to pay today’s reps.”

And then:

> “I want to get my debt back to zero.”

And eventually:

> “I’m building my bank every day.”

That is the core feeling of the app.
